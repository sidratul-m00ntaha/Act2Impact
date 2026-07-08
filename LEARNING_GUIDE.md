# Learning Flutter through Act2Impact

You said you want to *learn by building* — this guide maps each Flutter concept to the
exact file where this project uses it. Read the code in this order.

## 1. Everything is a widget — `lib/main.dart`

The whole app is a tree of widgets. `Act2ImpactApp` wraps `MaterialApp`, which wraps a
`_Gate` widget that decides what to show. Notice there are **no** if-statements changing
the UI imperatively — the build method just *returns different widgets* based on state.
That's the core Flutter mindset: **UI = f(state)**.

## 2. Stateless vs Stateful — compare two files

- `lib/screens/today_screen.dart` — **StatelessWidget**: it has no memory of its own;
  everything it shows comes from `AppState`.
- `lib/screens/onboarding_screen.dart` — **StatefulWidget**: the selected chips and the
  shuffled handle live inside the screen itself (`setState`). Rule of thumb: state that
  only one screen cares about → StatefulWidget; state the whole app cares about → Provider.

## 3. Provider and ChangeNotifier — `lib/state/app_state.dart`

The single most important file. `AppState` holds the profile, the feed, and today's prompt.
Every mutation ends with `notifyListeners()`, and every screen that calls
`context.watch<AppState>()` rebuilds automatically. Try it: hot-reload the app, log an act,
and watch three screens update from one method call.

- `context.watch<T>()` — rebuild me when T changes (use in `build`)
- `context.read<T>()` — just give me T, don't rebuild (use in callbacks)

## 4. The repository pattern — `lib/repositories/`

`ActsRepository` is an abstract class with two methods. The UI never knows *where* data
lives. Today it's `LocalActsRepository` (device storage); swapping in Firestore later means
writing one new class and changing one line in `AppState`. This is how real production
apps are structured.

## 5. Async Dart — `lib/services/gemini_service.dart`

`Future`, `async`/`await`, timeouts, and graceful fallbacks (return `null`, let the caller
decide). Notice the try/catch swallows *network* errors on purpose — the app must never
show an error where kindness should be.

## 6. Layout — `lib/screens/feed_screen.dart`

`ListView`, `Row`, `Column`, `Expanded`, `Spacer`, `Wrap` — 90% of all Flutter layout.
One gotcha you already hit: `ListView` builds children **lazily**, so off-screen widgets
don't exist yet (that's why the widget test scrolls before asserting — see
`test/widget_test.dart`).

## 7. Dialogs and navigation — `lib/screens/today_screen.dart` + `home_shell.dart`

`showDialog<bool>` returns what you pop: `Navigator.pop(context, true)`. The bottom
`NavigationBar` in `home_shell.dart` is the standard multi-tab pattern — an index in
`setState` picking from a list of screens.

## 8. Theming — `lib/theme.dart`

One place defines the palette, fonts, and button shapes for the whole app. `SoftCard`
shows how to build your own reusable widget instead of repeating a `Container` decoration
eight times.

## 9. Streams — the real-time engine — `lib/repositories/`

A `Future` answers once; a `Stream` keeps answering. `ActsRepository.watchActs()`
returns a `Stream<List<KindAct>>`, and `AppState` just listens:

```dart
_repo.watchActs().listen((list) { acts = list; notifyListeners(); });
```

- `LocalActsRepository` feeds that stream by hand with a `StreamController`.
- `FirestoreActsRepository` gets it for free: Firestore's `snapshots()` pushes every
  database change to every connected device within about a second. That one method is
  why the feed updates live when *someone else* logs an act.

## 10. Authentication — `lib/services/auth_service.dart` + `lib/screens/auth_screen.dart`

`FirebaseAuth.authStateChanges` is also a stream — sign in or out anywhere and the
`_Gate` in main.dart flips screens automatically. Notice `AuthScreen` never navigates
after a successful login; it doesn't have to, because state drives the UI (the same
UI = f(state) idea from lesson 1). Also study how `AuthService` converts
`FirebaseAuthException` codes into friendly sentences — error handling users can read
is a real skill.

## Exercises (in rising difficulty)

1. Add a 4th interest prompt category (e.g. "students") to `PromptEngine._bank`.
2. Add a streak counter to `AppState` (persist it in shared_preferences).
3. Make the Echoes screen show a tiny garden: one 🌱 emoji per act, growing to 🌿 → 🌳 as
   echoes accumulate. (This is the "growth metaphor" from your original notes!)
4. Add the Firebase backend by following FIREBASE_SETUP.md.

## Daily workflow

```bash
flutter run -d chrome    # then press r for hot reload, R for hot restart
flutter analyze          # your compiler-teacher: read every message
flutter test             # keep the test green as you refactor
```
