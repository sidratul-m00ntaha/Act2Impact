/// Backend switch.
///
/// The app runs in two modes:
///  - `false` (default): local mode — everything stored on this device,
///    echoes simulated. Works with zero setup.
///  - `true`: Firebase mode — real accounts (email + password), a shared
///    Firestore feed with live real-time updates, and real echoes.
///
/// To go live, follow FIREBASE_SETUP.md (create the Firebase project, run
/// `flutterfire configure`), then flip this to true.
const bool kUseFirebase = true;
