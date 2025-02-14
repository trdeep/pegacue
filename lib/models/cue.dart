class Cue {
  final int? id;
  final String title;
  final String plainText;
  final String deltaJson;
  final DateTime createdAt;

  Cue({
    this.id,
    required this.title,
    required this.plainText,
    required this.deltaJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'plainText': plainText,
      'deltaJson': deltaJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cue.fromMap(Map<String, dynamic> map) {
    return Cue(
      id: map['id'],
      title: map['title'],
      plainText: map['plainText'],
      deltaJson: map['deltaJson'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}