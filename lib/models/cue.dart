///
/// 台词数据模型
///
class Cue {
  final int? id;
  final String title;
  final String plainText;
  final String deltaJson;
  final int wordCount;
  final DateTime createdAt;

  Cue({
    this.id,
    required this.title,
    required this.plainText,
    required this.deltaJson,
    required this.wordCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'plain_text': plainText,
      'delta_json': deltaJson,
      'word_count': wordCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Cue.fromMap(Map<String, dynamic> map) {
    return Cue(
      id: map['id'],
      title: map['title'],
      plainText: map['plain_text'],
      deltaJson: map['delta_json'],
      wordCount: map['word_count'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}