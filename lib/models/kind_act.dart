/// One logged act of kindness — the core unit of the whole app.
///
/// `echoes` counts how many people tapped "This inspired me" on it, and
/// `echoedBy` remembers who, so nobody can echo the same act twice.
/// Instances are immutable: when something changes, the repository emits a
/// fresh list and the UI rebuilds — no hidden mutation to chase.
class KindAct {
  const KindAct({
    required this.id,
    required this.authorUid,
    required this.authorHandle,
    required this.text,
    required this.createdAt,
    this.echoes = 0,
    this.echoedBy = const [],
  });

  final String id;
  final String authorUid;
  final String authorHandle;
  final String text;
  final DateTime createdAt;
  final int echoes;
  final List<String> echoedBy;

  bool isMine(String? uid) => uid != null && authorUid == uid;
  bool wasEchoedBy(String? uid) => uid != null && echoedBy.contains(uid);

  KindAct copyWith({int? echoes, List<String>? echoedBy}) => KindAct(
        id: id,
        authorUid: authorUid,
        authorHandle: authorHandle,
        text: text,
        createdAt: createdAt,
        echoes: echoes ?? this.echoes,
        echoedBy: echoedBy ?? this.echoedBy,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorUid': authorUid,
        'authorHandle': authorHandle,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'echoes': echoes,
        'echoedBy': echoedBy,
      };

  factory KindAct.fromJson(Map<String, dynamic> json) => KindAct(
        id: json['id'] as String,
        authorUid: json['authorUid'] as String? ?? 'unknown',
        authorHandle: json['authorHandle'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        echoes: json['echoes'] as int? ?? 0,
        echoedBy: (json['echoedBy'] as List?)?.cast<String>() ?? const [],
      );
}
