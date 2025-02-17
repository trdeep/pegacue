import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../widgets/floating_prompter.dart';

class CameraPrompterPage2 extends StatefulWidget {
  final String title;
  final String content;

  const CameraPrompterPage2({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<CameraPrompterPage2> createState() => _CameraPrompterPageState();
}

class _CameraPrompterPageState extends State<CameraPrompterPage2> {
  bool _isPrompterVisible = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _startTeleprompter(); // 在启动相机的同时显示提词器
  }

  Future<void> _startTeleprompter() async {
    // 创建悬浮提词器
    _overlayEntry = OverlayEntry(
      builder: (context) => FloatingPrompterWidget(
        title: widget.title,
        content: widget.content,
      ),
    );

    // 显示悬浮提词器
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        _isPrompterVisible = true;
      });
    }
  }

  @override
  void dispose() {
    // 移除悬浮提词器
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text(''),
    );
  }
}