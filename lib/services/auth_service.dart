import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth that turns its exceptions into
/// human-readable messages. Methods return `null` on success or an error
/// string to show the user.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendly(e);
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendly(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _friendly(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'That email address doesn\'t look right.',
        'email-already-in-use' =>
          'An account with this email already exists — try signing in.',
        'weak-password' => 'Password needs at least 6 characters.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Email or password is incorrect.',
        'too-many-requests' =>
          'Too many attempts — please wait a minute and try again.',
        'network-request-failed' => 'No internet connection.',
        _ => 'Something went wrong (${e.code}). Please try again.',
      };
}
