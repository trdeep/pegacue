class Cue {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  Cue({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cue.fromMap(Map<String, dynamic> map) {
    return Cue(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}