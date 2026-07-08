# Act2Impact 🦋

**One small act of kindness a day. No likes, no leaderboards — just echoes.**

Act2Impact is an anti-doomscrolling app: instead of feeding you outrage, it hands you one
small, doable act of kindness each day — shaped by *your* real context (time of day, day of
week, and the causes you care about). You do it, log it anonymously, and move on.

When your act quietly inspires someone else, you hear its **echo** — sometimes days later.
That delayed, unpredictable reward is the whole point: kindness that spreads, not kindness
that performs.

## The core loop

```
AI daily prompt  →  you do the act  →  log it anonymously  →  it echoes in someone else
```

## Features

- **Context-aware daily acts** — suggestions adapt to morning/afternoon/evening, weekday,
  and your chosen causes (people, animals, environment, community, wellbeing).
  Add a Gemini API key in Settings for live AI-generated suggestions; without one, a
  curated offline bank keeps the app fully functional.
- **Anonymous by design** — everyone gets a "butterfly handle" like *Gentle Ember 83*.
  No profiles, no followers, no showing off.
- **The Butterfly feed** — anonymous acts drifting by, with exactly one reaction:
  *"This inspired me."* No likes, no comments, no toxicity to moderate.
- **Echoes, not points** — your only metric is how many times your kindness echoed in
  someone else. No streaks to lose, no leaderboard to climb.
- **Real accounts, real-time feed** — email sign-up/login via Firebase Auth, and a
  shared Firestore feed that updates live on every device the moment anyone logs an
  act or echoes one. (Runs in a zero-setup local demo mode until Firebase is
  configured — see below.)

## Tech stack

- **Flutter** (web + Android from one codebase)
- **Firebase** — Auth (email/password) + Cloud Firestore (real-time feed)
- **Provider** for state management
- **shared_preferences** for local-mode persistence and settings
- **Gemini API** (optional) for live prompt generation
- Google Fonts: Fraunces + Nunito

## Two backends, one switch

The UI talks to storage only through the `ActsRepository` interface. A single flag in
`lib/firebase_config.dart` picks the implementation:

| `kUseFirebase` | Backend | Auth | Feed |
|---|---|---|---|
| `false` (default) | device storage | none (anonymous handle only) | local, echoes simulated |
| `true` | Cloud Firestore | email sign-up / login | shared + real-time |

To go live, follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md) (~15 minutes).

## Run it

```bash
flutter pub get
flutter run -d chrome        # web (no Android setup needed)
flutter test                 # run tests
flutter build web            # production web build
```

## Project structure

```
lib/
  models/         # KindAct, UserProfile — plain data classes
  services/       # PromptEngine, GeminiService, AuthService
  repositories/   # ActsRepository interface + local & Firestore implementations
  state/          # AppState (ChangeNotifier) — single source of truth
  screens/        # Auth, Onboarding, Today, Feed, Echoes
  firebase_config.dart   # the local ↔ Firebase switch
  theme.dart      # palette + shared widgets
```

## Roadmap

- [x] Firebase backend: email auth + real-time shared feed (flip the switch via [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
- [ ] Push notifications for echoes, batched 1–3 days later
- [ ] Weather-aware prompts (OpenWeatherMap)
- [ ] Collaborative constellations: campus-wide kindness goals
- [ ] Android release

## Why no points or leaderboards?

Extrinsic rewards make kindness transactional. Act2Impact uses only intrinsic motivators:
growth, surprise, and the quiet knowledge that your small act rippled outward. The echo you
get three days later beats any badge.
