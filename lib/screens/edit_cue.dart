import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../utils/database_helper.dart';
import '../models/cue.dart';


class EditCuePage extends StatefulWidget {
  const EditCuePage({super.key});

  @override
  _EditCuePageState createState() => _EditCuePageState();
}

class _EditCuePageState extends State<EditCuePage> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();

  Widget _getMyColorButton() {
    return IconButton(
      icon: const Icon(Icons.color_lens),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('选择颜色'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.red,
                  Colors.blue,
                  Colors.yellow,
                  Colors.green,
                  Colors.purple,
                  Colors.orange,
                  Colors.black,
                ]
                    .map((color) => GestureDetector(
                  onTap: () {
                    _quillController.formatSelection(
                      Attribute.fromKeyValue('color',
                          '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加台词'),
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
                onPressed: () async {
                  final delta = _quillController.document.toDelta();
                  final plainText = _quillController.document.toPlainText();
                  final cue = Cue(
                    title: _titleController.text,
                    content: plainText,
                    createdAt: DateTime.now(),
                  );
                  await DatabaseHelper.instance.insertCue(cue);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
