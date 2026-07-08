import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Email + password sign in / sign up (Firebase mode only).
///
/// Your account is just a key to your echoes — the feed itself stays
/// anonymous: only your butterfly handle is ever shown to others.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUpMode = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final auth = context.read<AppState>().auth;
    if (auth == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = _signUpMode
        ? await auth.signUp(_email.text, _password.text)
        : await auth.signIn(_email.text, _password.text);
    // On success the auth stream flips the screen automatically;
    // we only need to handle failure here.
    if (mounted) {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                const Text('🦋',
                    style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  _signUpMode ? 'Join Act2Impact' : 'Welcome back',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your email is only your key — on the feed you\'re always '
                  'just an anonymous butterfly.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: kMuted),
                ),
                const SizedBox(height: 28),
                SoftCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _busy ? null : _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Password (6+ characters)',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_signUpMode
                                  ? 'Create account'
                                  : 'Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _signUpMode = !_signUpMode;
                            _error = null;
                          }),
                  child: Text(
                    _signUpMode
                        ? 'Already have an account? Sign in'
                        : 'New here? Create an account',
                    style: const TextStyle(color: kPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
