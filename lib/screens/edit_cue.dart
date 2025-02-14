import 'package:dart_quill_delta/src/delta/delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../utils/database_helper.dart';
import '../models/cue.dart';

class EditCuePage extends StatefulWidget {
  final int? id;
  final String? title;
  final String? date;
  final String? deltaJson;

  const EditCuePage({super.key, this.id, this.title, this.date, this.deltaJson});

  @override
  _EditCuePageState createState() => _EditCuePageState();
}

class _EditCuePageState extends State<EditCuePage> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      _titleController.text = widget.title!;
    }
    if (widget.deltaJson != null) {
      // todo 这里的 as List 转换可能是错误的
      _quillController.document = Document.fromJson(widget.deltaJson! as List);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑台词'),
        actions: [
          IconButton(
            onPressed: _saveOrUpdateCue,
            icon: const Icon(Icons.save),
          ),
        ],
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: QuillEditor.basic(
                  controller: _quillController,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
    var empty = _quillController.document.isEmpty();
    var plainText = _quillController.document.toPlainText();
    final deltaJson = _quillController.document.toDelta().toJson().toString();
    final createdAt = DateTime.now();

    if (widget.id == null) {
      // 保存台词逻辑
      final cue = Cue(title: title, plainText: plainText, deltaJson: deltaJson, createdAt: createdAt);
      await DatabaseHelper.instance.insertCue(cue);
    } else {
      // 更新台词逻辑
      final cue = Cue(id: widget.id, title: title, plainText: plainText, deltaJson: deltaJson, createdAt: createdAt);
      await DatabaseHelper.instance.updateCue(cue);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
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
    QuillToolbarColorButton(
      controller: _quillController,
      isBackground: false,
    ),
    const VerticalDivider(),
    QuillToolbarFontSizeButton(
      controller: _quillController,
    ),
  ];
}