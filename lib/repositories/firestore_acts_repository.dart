import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/kind_act.dart';
import 'acts_repository.dart';

/// The real backend: a shared `acts` collection in Firestore.
///
/// `snapshots()` is the magic — Firestore pushes every change to every
/// connected device, so when anyone logs an act or echoes one, all open
/// apps update within a second. No polling, no refresh button.
class FirestoreActsRepository implements ActsRepository {
  CollectionReference<Map<String, dynamic>> get _acts =>
      FirebaseFirestore.instance.collection('acts');

  @override
  Stream<List<KindAct>> watchActs() => _acts
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());

  @override
  Future<void> addAct(KindAct act) => _acts.doc(act.id).set({
        'authorUid': act.authorUid,
        'authorHandle': act.authorHandle,
        'text': act.text,
        'createdAt': Timestamp.fromDate(act.createdAt),
        'echoes': 0,
        'echoedBy': <String>[],
      });

  @override
  Future<void> echo(String actId, String uid) => _acts.doc(actId).update({
        'echoes': FieldValue.increment(1),
        'echoedBy': FieldValue.arrayUnion([uid]),
      });

  @override
  void dispose() {
    // Firestore snapshot listeners are cancelled by AppState's subscription.
  }

  KindAct _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return KindAct(
      id: doc.id,
      authorUid: d['authorUid'] as String? ?? 'unknown',
      authorHandle: d['authorHandle'] as String? ?? 'Anonymous Butterfly',
      text: d['text'] as String? ?? '',
      // Firestore may briefly report a null timestamp for a write this
      // client just made (latency compensation) — treat it as "now".
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      echoes: d['echoes'] as int? ?? 0,
      echoedBy: (d['echoedBy'] as List?)?.cast<String>() ?? const [],
    );
  }
}
