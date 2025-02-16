import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../utils/database_helper.dart';
import '../models/cue.dart';
import 'dart:convert' as convert;

import '../utils/tools.dart';
///
/// 编辑台词
///
class EditCuePage extends StatefulWidget {
  final int? id;
  final String? title;
  final String? date;
  final String? deltaJson;

  const EditCuePage(
      {super.key, this.id, this.title, this.date, this.deltaJson});

  @override
  _EditCuePageState createState() => _EditCuePageState();
}

class _EditCuePageState extends State<EditCuePage> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  void _hideKeyboard() {
    _focusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      _titleController.text = widget.title!;
    }
    if (widget.deltaJson != null) {
      _quillController.document =
          Document.fromJson(convert.jsonDecode(widget.deltaJson!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑台词'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: QuillEditor.basic(
                    controller: _quillController, focusNode: _focusNode),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: _toolbarButtons,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveOrUpdateCue,
                child: Text(widget.id == null ? '保存' : '更新'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveOrUpdateCue() async {
    final title = _titleController.text;
    final document = _quillController.document;
    final plainText = document.toPlainText();
    final delta = document.toDelta();
    final deltaJson = convert.jsonEncode(delta.toJson());
    final wordCount = plainText.replaceAll('\n', '').length;
    final createdAt = DateTime.now();

    if (widget.id == null) {
      // 保存台词逻辑
      final cue = Cue(
          title: title,
          plainText: plainText,
          deltaJson: deltaJson,
          wordCount: wordCount,
          createdAt: createdAt);
      await DatabaseHelper.instance.insertCue(cue);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加成功')),
      );
    } else {
      // 更新台词逻辑
      final cue = Cue(
          id: widget.id,
          title: title,
          plainText: plainText,
          deltaJson: deltaJson,
          wordCount: wordCount,
          createdAt: createdAt);
      await DatabaseHelper.instance.updateCue(cue);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新成功')),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Widget> get _toolbarButtons => [
        QuillToolbarToggleStyleButton(
          attribute: Attribute.bold,
          controller: _quillController,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.underline,
          controller: _quillController,
        ),
        QuillToolbarClearFormatButton(controller: _quillController),

        QuillToolbarColorButton(
          controller: _quillController,
          isBackground: false,
        ),
        QuillToolbarColorButton(
          controller: _quillController,
          isBackground: true,
        ),
        //const VerticalDivider(),
        // GestureDetector(
        //   onTapDown: (_) => _hideKeyboard,
        //   child: QuillToolbarFontSizeButton(
        //     controller: _quillController,
        //     options: const QuillToolbarFontSizeButtonOptions(
        //       rawItemsMap: {'小字号': '8', '大字号': '30', '超大字号': '40', '清除': '0'},
        //     ),
        //   ),
        // ),
      ];
}
