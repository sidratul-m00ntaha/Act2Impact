import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/kind_act.dart';
import 'acts_repository.dart';

/// Uid used for the device owner when running without Firebase.
const kLocalUid = 'local-user';

/// Stores the feed as JSON on the device (browser localStorage on web).
///
/// On first launch it seeds a handful of community acts so the Butterfly
/// feed never looks empty. In Firebase mode these become real people.
class LocalActsRepository implements ActsRepository {
  static const _key = 'acts_v2';

  final _controller = StreamController<List<KindAct>>.broadcast();
  List<KindAct> _cache = [];
  bool _loaded = false;

  @override
  Stream<List<KindAct>> watchActs() async* {
    if (!_loaded) await _load();
    yield List.unmodifiable(_cache);
    yield* _controller.stream;
  }

  @override
  Future<void> addAct(KindAct act) async {
    _cache.insert(0, act);
    await _persistAndEmit();
  }

  @override
  Future<void> echo(String actId, String uid) async {
    final i = _cache.indexWhere((a) => a.id == actId);
    if (i < 0) return;
    final act = _cache[i];
    if (act.wasEchoedBy(uid)) return;
    _cache[i] = act.copyWith(
      echoes: act.echoes + 1,
      echoedBy: [...act.echoedBy, uid],
    );
    await _persistAndEmit();
  }

  @override
  void dispose() => _controller.close();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _cache = _seedActs();
    } else {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _cache = list.map(KindAct.fromJson).toList();
      _simulateDemoEchoes();
    }
    _loaded = true;
    await _persist();
  }

  Future<void> _persistAndEmit() async {
    await _persist();
    _controller.add(List.unmodifiable(_cache));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_cache.map((a) => a.toJson()).toList()),
    );
  }

  /// DEMO-MODE ONLY: with local storage there are no other users, so on each
  /// launch, older acts of yours may gain an echo — a stand-in for the real
  /// community. Firebase mode never calls this: echoes there come from real
  /// people tapping "This inspired me".
  void _simulateDemoEchoes() {
    final random = Random();
    for (var i = 0; i < _cache.length; i++) {
      final act = _cache[i];
      if (!act.isMine(kLocalUid)) continue;
      final ageMinutes = DateTime.now().difference(act.createdAt).inMinutes;
      if (ageMinutes > 2 && act.echoes < 12 && random.nextDouble() < 0.5) {
        _cache[i] = act.copyWith(
          echoes: act.echoes + 1,
          echoedBy: [...act.echoedBy, 'demo-${act.echoes}'],
        );
      }
    }
  }

  List<KindAct> _seedActs() {
    final now = DateTime.now();
    KindAct seed(int n, String handle, String text, int hoursAgo, int echoes) =>
        KindAct(
          id: 'seed-$n',
          authorUid: 'seed-$n',
          authorHandle: handle,
          text: text,
          createdAt: now.subtract(Duration(hours: hoursAgo)),
          echoes: echoes,
        );
    return [
      seed(1, 'Quiet Lantern 8',
          'Paid for the tea of the person behind me at the campus stall.', 2, 4),
      seed(2, 'Gentle River 44',
          'Helped an auntie carry her bags up four flights of stairs.', 5, 7),
      seed(3, 'Bright Clover 3',
          'Left a bowl of water out for the street cats near my hall.', 9, 12),
      seed(4, 'Warm Breeze 61',
          'Texted a friend before his exam. He said it calmed him down.', 14, 3),
      seed(5, 'Kind Ember 19',
          'Picked up litter along my walk to class. Five pieces, two minutes.',
          22, 6),
      seed(6, 'Soft Sparrow 77',
          'Told the canteen cleaner thank you, by name. His whole face lit up.',
          30, 15),
    ];
  }
}
