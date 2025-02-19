///
/// 台词数据模型
/// 
/// 用于存储和管理提词器中的台词内容，包括标题、纯文本、富文本格式等信息。
/// 支持与数据库的序列化和反序列化操作。
class Cue {
  /// 台词的唯一标识符
  /// 
  /// 在数据库中自动生成，新建台词时可为空
  final int? id;

  /// 台词的标题
  /// 
  /// 用于在列表中显示和识别台词
  final String title;

  /// 台词的纯文本内容
  /// 
  /// 用于搜索和字数统计
  final String plainText;

  /// 台词的富文本内容
  /// 
  /// 使用 Delta 格式存储，包含文本样式信息
  final String deltaJson;

  /// 台词的字数统计
  /// 
  /// 用于显示台词长度信息
  final int wordCount;

  /// 台词的创建时间
  /// 
  /// 用于排序和显示
  final DateTime createdAt;

  /// 构造函数
  /// 
  /// [id] - 台词ID，可选
  /// [title] - 台词标题，必需
  /// [plainText] - 纯文本内容，必需
  /// [deltaJson] - 富文本内容，必需
  /// [wordCount] - 字数统计，必需
  /// [createdAt] - 创建时间，必需
  Cue({
    this.id,
    required this.title,
    required this.plainText,
    required this.deltaJson,
    required this.wordCount,
    required this.createdAt,
  });

  /// 将对象转换为数据库可用的 Map
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

  /// 从数据库 Map 创建对象
  /// 
  /// [map] - 数据库查询结果的 Map
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