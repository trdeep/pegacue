// import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
// import '../utils/database_helper.dart';
// import '../models/cue.dart';
//
// import '../utils/tools.dart';
// ///
// /// 编辑台词
// ///
// class EditCuePage2 extends StatefulWidget {
//   final int? id;
//   final String? title;
//   final String? date;
//   final String? deltaJson;
//
//   const EditCuePage2(
//       {super.key, this.id, this.title, this.date, this.deltaJson});
//
//   @override
//   _EditCuePage2State createState() => _EditCuePage2State();
// }
//
// class _EditCuePage2State extends State<EditCuePage2> {
//   final TextEditingController _titleController = TextEditingController();
//   final HtmlEditorController _htmlController = HtmlEditorController();
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.title != null) {
//       _titleController.text = widget.title!;
//     }
//     if (widget.deltaJson != null) {
//       _htmlController.setText(widget.deltaJson!);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('编辑台词'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: '标题',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: HtmlEditor(
//                 htmlToolbarOptions: HtmlToolbarOptions(
//                   defaultToolbarButtons: [
//                     FontButtons(
//                         bold: true,
//                         italic: true,
//                         underline: true,
//                         clearAll: true,
//                         strikethrough: false,
//                         superscript: false,
//                         subscript: false),
//                     ColorButtons(),
//                     ListButtons(listStyles: false),
//                   ],
//                 ),
//                 controller: _htmlController,
//                 htmlEditorOptions: HtmlEditorOptions(
//                   hint: "请输入内容...",
//                 ),
//                 otherOptions: OtherOptions(
//                   height: MediaQuery.of(context).size.height * 0.7,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saveOrUpdateCue,
//                 child: Text(widget.id == null ? '保存' : '更新'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _saveOrUpdateCue() async {
//     final title = _titleController.text;
//     final plainText = removeHtmlTags(await _htmlController.getText());
//     final deltaJson = await _htmlController.getText();
//     final wordCount = plainText.replaceAll('\n', '').length;
//     final createdAt = DateTime.now();
//
//     if (title.isEmpty || plainText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('标题和内容不能为空')),
//       );
//       return;
//     }
//
//     if (widget.id == null) {
//       // 保存台词逻辑
//       final cue = Cue(
//         title: title,
//         plainText: plainText,
//         deltaJson: deltaJson,
//         wordCount: wordCount,
//         createdAt: createdAt,
//       );
//       await DatabaseHelper.instance.insertCue(cue);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('添加成功')),
//       );
//     } else {
//       // 更新台词逻辑
//       final cue = Cue(
//         id: widget.id,
//         title: title,
//         plainText: plainText,
//         deltaJson: deltaJson,
//         wordCount: wordCount,
//         createdAt: createdAt,
//       );
//       await DatabaseHelper.instance.updateCue(cue);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('更新成功')),
//       );
//     }
//
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }
// }
