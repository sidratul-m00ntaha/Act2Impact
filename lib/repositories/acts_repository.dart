import '../models/kind_act.dart';

/// The app talks to storage only through this interface.
///
/// Two implementations exist:
///  - LocalActsRepository: device storage, single user, simulated echoes.
///  - FirestoreActsRepository: shared cloud feed, real-time updates.
/// AppState picks one at startup based on `kUseFirebase` — no screen code
/// knows or cares which is active. This is the repository pattern.
abstract class ActsRepository {
  /// A live stream of the feed. Emits a fresh list whenever anything
  /// changes — this is what makes the UI update in real time.
  Stream<List<KindAct>> watchActs();

  Future<void> addAct(KindAct act);

  /// Record that [uid] was inspired by act [actId].
  Future<void> echo(String actId, String uid);

  /// Release any resources (stream controllers, listeners).
  void dispose() {}
}
