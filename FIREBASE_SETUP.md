# Going live: Firebase setup (~15 minutes)

> **STATUS (2026-07-08): steps 1–4 are DONE.** Project `act2impact-c866c` is created,
> `flutterfire configure` has run, `kUseFirebase` is `true`, security rules are
> deployed (`firestore.rules`), and sign-up + Firestore writes + echoes were
> verified end-to-end. Only step 5 (hosting deploy for a public link) remains:
> `firebase deploy --only hosting` after a fresh `flutter build web`.

All the Firebase code is **already written and wired in**:

- Email + password sign up / sign in ([auth_service.dart](lib/services/auth_service.dart), [auth_screen.dart](lib/screens/auth_screen.dart))
- Real-time shared feed via Firestore streams ([firestore_acts_repository.dart](lib/repositories/firestore_acts_repository.dart))
- Profiles stored per-account in a `users` collection

The app currently runs in local mode because Firebase needs *your* Google account.
Follow these steps once and flip one flag.

> **No billing needed.** Everything below runs on Firebase's free **Spark plan** —
> no credit card, no billing account. If the console suggests upgrading to Blaze,
> skip it. Free limits (50k reads + 20k writes per day, 50k auth users, hosting
> included) are far beyond what this app needs. Only Cloud Functions would need
> billing, and we don't use them.

## 1. Create the Firebase project (in the browser)

1. Go to https://console.firebase.google.com → **Add project** → name it `act2impact`
   (Google Analytics: off is fine).
2. **Build → Authentication → Get started → Email/Password → Enable → Save.**
3. **Build → Firestore Database → Create database → Start in test mode** (we lock it
   down in step 4) → pick a region near you (e.g. `asia-south1`).

## 2. Connect your Flutter app (in the terminal)

```powershell
cd E:\Act2Impact
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login                      # opens browser, log in with the same Google account
flutterfire configure               # pick the act2impact project, select web + android
```

`flutterfire configure` **overwrites `lib/firebase_options.dart`** with your real keys —
that's expected, the current file is a placeholder.

## 3. Flip the switch

In [lib/firebase_config.dart](lib/firebase_config.dart):

```dart
const bool kUseFirebase = true;
```

Run it: `flutter run -d chrome`. You'll see the sign-up screen. Create two accounts in
two different browser windows, log an act in one — **watch it appear instantly in the
other**. That's the real-time demo for your hackathon video.

## 4. Security rules (do this before sharing any link)

Firestore → Rules tab → paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }
    match /acts/{actId} {
      allow read: if request.auth != null;
      // You may only create acts as yourself.
      allow create: if request.auth != null
                    && request.resource.data.authorUid == request.auth.uid;
      // Updates may only add an echo: +1 and your own uid appended.
      allow update: if request.auth != null
        && request.resource.data.echoes == resource.data.echoes + 1
        && request.resource.data.echoedBy.size() == resource.data.echoedBy.size() + 1
        && request.resource.data.echoedBy.hasAll(resource.data.echoedBy)
        && !(resource.data.echoedBy.hasAny([request.auth.uid]))
        && request.resource.data.echoedBy.hasAny([request.auth.uid])
        && request.resource.data.authorUid == resource.data.authorUid
        && request.resource.data.text == resource.data.text
        && request.resource.data.authorHandle == resource.data.authorHandle;
    }
  }
}
```

## 5. Deploy the web app (your hackathon demo link)

```powershell
flutter build web
firebase init hosting        # public directory: build/web, single-page app: yes
firebase deploy
```

You get a free `https://act2impact-xxxx.web.app` URL judges can open.

## Later (not needed for the hackathon)

- Move the Gemini call into a Cloud Function so the key never ships in the client
  (same lesson as `st.secrets` on Streamlit).
- Firebase Cloud Messaging for push notifications when your act echoes —
  batch them 1–3 days later; the delay is the psychology.
