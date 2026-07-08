import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_config.dart';
import '../firebase_options.dart';
import '../models/kind_act.dart';
import '../models/user_profile.dart';
import '../repositories/acts_repository.dart';
import '../repositories/firestore_acts_repository.dart';
import '../repositories/local_acts_repository.dart';
import '../services/auth_service.dart';
import '../services/prompt_engine.dart';

/// One shared object that holds everything the UI needs.
///
/// Screens `watch` this with Provider; whenever notifyListeners() runs,
/// every watching widget rebuilds. The feed itself arrives through the
/// repository's stream, so in Firebase mode changes made by *other people*
/// land here in real time too.
class AppState extends ChangeNotifier {
  late ActsRepository _repo;
  final PromptEngine _promptEngine = PromptEngine();
  AuthService? auth;

  bool firebaseActive = false;
  bool isLoading = true;
  String? uid;
  UserProfile? profile;
  List<KindAct> acts = [];
  DailyPrompt? today;
  bool promptLoading = false;
  String? geminiKey;
  int _refreshCount = 0;

  StreamSubscription<List<KindAct>>? _actsSub;
  StreamSubscription<User?>? _authSub;

  /// True when Firebase mode is on but nobody is signed in → show AuthScreen.
  bool get needsAuth => firebaseActive && uid == null;

  List<KindAct> get myActs => acts.where((a) => a.isMine(uid)).toList();
  int get totalEchoes => myActs.fold(0, (total, a) => total + a.echoes);

  /// Derived from the feed instead of stored: works across devices, and in
  /// Firebase mode survives sign-out/sign-in.
  bool get todayDone {
    final now = DateTime.now();
    return myActs.any((a) =>
        a.createdAt.year == now.year &&
        a.createdAt.month == now.month &&
        a.createdAt.day == now.day);
  }

  /// [useFirebase] is overridable so widget tests can force local mode.
  Future<void> init({bool useFirebase = kUseFirebase}) async {
    final prefs = await SharedPreferences.getInstance();
    geminiKey = prefs.getString('gemini_key');

    if (useFirebase) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseActive = true;
      } catch (e) {
        // Not configured (or unavailable in tests) → fall back to local mode
        // so the app always works.
        debugPrint('Firebase unavailable, running locally: $e');
      }
    }

    if (firebaseActive) {
      _repo = FirestoreActsRepository();
      auth = AuthService();
      _authSub = auth!.authStateChanges.listen(_onAuthChanged);
      // _onAuthChanged fires immediately with the current user (or null)
      // and finishes the loading state.
    } else {
      _repo = LocalActsRepository();
      uid = kLocalUid;
      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        profile = UserProfile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
      }
      _subscribeActs();
      isLoading = false;
      notifyListeners();
      if (profile != null) await _generatePrompt();
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    uid = user?.uid;
    if (user == null) {
      // Signed out: clear personal state, stop listening to the feed.
      profile = null;
      today = null;
      await _actsSub?.cancel();
      _actsSub = null;
      acts = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    profile =
        doc.exists ? UserProfile.fromJson(doc.data()!) : null;
    _subscribeActs();
    isLoading = false;
    notifyListeners();
    if (profile != null) await _generatePrompt();
  }

  void _subscribeActs() {
    _actsSub?.cancel();
    _actsSub = _repo.watchActs().listen((list) {
      acts = list;
      notifyListeners();
    });
  }

  Future<void> completeOnboarding(String handle, List<String> interests) async {
    profile = UserProfile(
      handle: handle,
      interests: interests,
      joinedOn: DateTime.now(),
    );
    if (firebaseActive && uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(profile!.toJson());
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile', jsonEncode(profile!.toJson()));
    }
    notifyListeners();
    await _generatePrompt();
  }

  /// "Show me another" — cycles to the next suggestion.
  Future<void> anotherPrompt() async {
    _refreshCount++;
    await _generatePrompt();
  }

  Future<void> _generatePrompt() async {
    if (profile == null) return;
    promptLoading = true;
    notifyListeners();
    today = await _promptEngine.dailyPrompt(
      profile: profile!,
      refreshCount: _refreshCount,
      geminiKey: geminiKey,
    );
    promptLoading = false;
    notifyListeners();
  }

  /// The user did today's suggested act — log it to the feed.
  /// The new act comes back to us through the repository stream.
  Future<void> logAct({String? note}) async {
    if (today == null) return;
    final text = (note != null && note.trim().isNotEmpty) ? note : today!.text;
    await logCustomAct(text);
  }

  /// Log any act of kindness in the user's own words — the AI prompt is a
  /// suggestion, not a limit.
  Future<void> logCustomAct(String text) async {
    if (profile == null || uid == null) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final act = KindAct(
      id: 'act-$uid-${DateTime.now().millisecondsSinceEpoch}',
      authorUid: uid!,
      authorHandle: profile!.handle,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    await _repo.addAct(act);
  }

  /// Tap "This inspired me" on someone else's act → their echo count grows,
  /// live on every device watching the feed.
  Future<void> inspire(KindAct act) async {
    if (uid == null || act.isMine(uid) || act.wasEchoedBy(uid)) return;
    await _repo.echo(act.id, uid!);
  }

  Future<void> signOut() async => auth?.signOut();

  Future<void> setGeminiKey(String key) async {
    geminiKey = key.trim().isEmpty ? null : key.trim();
    final prefs = await SharedPreferences.getInstance();
    if (geminiKey == null) {
      await prefs.remove('gemini_key');
    } else {
      await prefs.setString('gemini_key', geminiKey!);
    }
    notifyListeners();
    await _generatePrompt();
  }

  /// Local mode only: wipe everything and return to onboarding.
  Future<void> resetApp() async {
    if (firebaseActive) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    profile = null;
    today = null;
    _refreshCount = 0;
    geminiKey = null;
    // Fresh repository so the feed re-seeds from scratch.
    await _actsSub?.cancel();
    _repo.dispose();
    _repo = LocalActsRepository();
    _subscribeActs();
    notifyListeners();
  }

  @override
  void dispose() {
    _actsSub?.cancel();
    _authSub?.cancel();
    _repo.dispose();
    super.dispose();
  }
}
