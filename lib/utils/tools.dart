import 'package:flutter_quill/quill_delta.dart';
import 'dart:convert' as convert;

///
/// 工具类
///
String deltaJsonToHtml(String json) {
  final delta = Delta.fromJson(convert.jsonDecode(json));
  return deltaToHtml(delta);
}


String deltaToHtml(Delta delta) {
  final StringBuffer htmlBuffer = StringBuffer();

  for (final op in delta.toList()) {
    if (op.isInsert) {
      final String text = op.data is String ? op.data as String : '';
      final Map<String, dynamic> attributes = op.attributes ?? {};

      // 处理文本中的换行符
      final List<String> lines = text.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];

        // 开始标签
        htmlBuffer.write('<span style="');

        // 处理字体颜色
        if (attributes.containsKey('color')) {
          final String color = attributes['color'];
          htmlBuffer.write('color: $color; ');
        }

        // 处理字体背景颜色
        if (attributes.containsKey('background')) {
          final String backgroundColor = attributes['background'];
          htmlBuffer.write('background-color: $backgroundColor; ');
        }

        // 处理字体大小
        //if (attributes.containsKey('size')) {
        //  final dynamic size = attributes['size'];
        //  if (size is num) {
        //    htmlBuffer.write('font-size: 150px; ');
        //  } else if (size is String) {
        //    htmlBuffer.write('font-size: 150px; ');
        //  }
        //}

        htmlBuffer.write('">');

        // 处理文本样式
        if (attributes.containsKey('bold')) {
          htmlBuffer.write('<strong>');
        }
        if (attributes.containsKey('italic')) {
          htmlBuffer.write('<em>');
        }
        if (attributes.containsKey('underline')) {
          htmlBuffer.write('<u>');
        }
        if (attributes.containsKey('strike')) {
          htmlBuffer.write('<s>');
        }

        // 处理标题
        if (attributes.containsKey('header')) {
          final int headerLevel = attributes['header'];
          htmlBuffer.write('<h$headerLevel>');
        }

        // 处理链接
        if (attributes.containsKey('link')) {
          final String link = attributes['link'];
          htmlBuffer.write('<a href="$link">');
        }

        // 插入文本
        htmlBuffer.write(line);

        // 关闭标签
        if (attributes.containsKey('link')) {
          htmlBuffer.write('</a>');
        }
        if (attributes.containsKey('header')) {
          final int headerLevel = attributes['header'];
          htmlBuffer.write('</h$headerLevel>');
        }
        if (attributes.containsKey('strike')) {
          htmlBuffer.write('</s>');
        }
        if (attributes.containsKey('underline')) {
          htmlBuffer.write('</u>');
        }
        if (attributes.containsKey('italic')) {
          htmlBuffer.write('</em>');
        }
        if (attributes.containsKey('bold')) {
          htmlBuffer.write('</strong>');
        }

        // 关闭 span 标签
        htmlBuffer.write('</span>');

        // 如果不是最后一行，插入换行符
        if (i < lines.length - 1) {
          htmlBuffer.write('<br>');
        }
      }
    } else if (op.isDelete) {
      // 删除操作，HTML 中不需要处理
      continue;
    } else if (op.isRetain) {
      // 保留操作，HTML 中不需要处理
      continue;
    }
  }

  return htmlBuffer.toString();
}


String removeHtmlTags(String htmlString) {
  // 定义正则表达式，匹配所有 HTML 标签
  final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  // 使用正则表达式替换所有匹配的 HTML 标签为空字符串
  return htmlString.replaceAll(exp, '');
}
