

String removeHtmlTags(String htmlString) {
  // 定义正则表达式，匹配所有 HTML 标签
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  // 使用正则表达式替换所有匹配的 HTML 标签为空字符串
  return htmlString.replaceAll(exp, '');
}
