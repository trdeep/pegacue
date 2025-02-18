import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

class CameraPrompterPage extends StatefulWidget {
  const CameraPrompterPage({super.key});

  @override
  State<CameraPrompterPage> createState() => _CameraPrompterPageState();
}

class _CameraPrompterPageState extends State<CameraPrompterPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pickVideo();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        // 自动保存视频到相册
        await _saveVideoToGallery(video.path);
      } else {
        // 用户取消录制
        Navigator.pop(context); // 返回上级页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户取消了录制视频')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // 返回上级页面
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('录制视频时发生错误')),
      );
    }
  }

  Future<void> _saveVideoToGallery(String videoPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'pega_$timestamp.mp4';
    final newPath = '${directory.path}/$fileName';

    // 复制视频文件到应用目录
    final File videoFile = File(videoPath);
    await videoFile.copy(newPath);

    // 保存视频到相册
    final result = await SaverGallery.saveFile(
      filePath: newPath,
      fileName: fileName,
      androidRelativePath: "Movies",
      skipIfExists: true,
    );

    // 清理缓存的视频
    await _cleanupVideoFile(videoPath);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('视频已成功保存到相册')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('视频保存到相册失败')),
      );
    }

    Navigator.pop(context); // 返回上级页面
  }

  Future<void> _cleanupVideoFile(String videoPath) async {
    try {
      final File videoFile = File(videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
    } catch (e) {
      print('Error cleaning up video file: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
