import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_config.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  runApp(const Act2ImpactApp());
}

class Act2ImpactApp extends StatelessWidget {
  const Act2ImpactApp({super.key, this.useFirebase = kUseFirebase});

  /// Overridable so tests can run without a Firebase environment.
  final bool useFirebase;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider makes one shared AppState available to every
    // screen below it. `..init()` connects Firebase (or local storage) and
    // starts listening to auth + the live feed.
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(useFirebase: useFirebase),
      child: MaterialApp(
        title: 'Act2Impact',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Gate(),
      ),
    );
  }
}

/// Decides which screen to show: splash while loading, sign-in when Firebase
/// is on and nobody is logged in, onboarding for new users, then the app.
class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.isLoading) {
      return const Scaffold(
        body: Center(child: Text('🦋', style: TextStyle(fontSize: 56))),
      );
    }
    if (app.needsAuth) return const AuthScreen();
    if (app.profile == null) return const OnboardingScreen();
    return const HomeShell();
  }
}
