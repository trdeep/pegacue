import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';

/// 相机提示器页面组件
/// 
/// 用于视频录制和自动保存功能，提供以下功能：
/// - 自动启动系统相机进行视频录制
/// - 录制完成后自动保存到相册
/// - 处理用户取消录制的情况
class CameraPrompterPage extends StatefulWidget {
  const CameraPrompterPage({super.key});

  @override
  State<CameraPrompterPage> createState() => _CameraPrompterPageState();
}

class _CameraPrompterPageState extends State<CameraPrompterPage> {
  /// 图片选择器实例，用于调用系统相机
  final ImagePicker _picker = ImagePicker();
  
  /// 是否正在处理视频
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 页面初始化时自动启动视频录制
    _pickVideo();
  }

  /// 调用系统相机进行视频录制
  /// 
  /// 录制完成后自动保存视频到相册
  /// 如果用户取消录制，将返回上一页面
  /// 如果录制过程中发生错误，将显示错误信息
  Future<void> _pickVideo() async {
    // 防止重复调用
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        // 自动保存视频到相册
        await _saveVideoToGallery(video.path);
      } else {
        // 用户取消录制
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户取消了录制视频')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('录制视频时发生错误')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// 保存视频到相册
  /// 
  /// [videoPath] 临时视频文件路径
  /// 
  /// 将视频文件复制到应用目录，然后保存到系统相册
  /// 保存完成后自动清理临时文件
  Future<void> _saveVideoToGallery(String videoPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'pega_$timestamp.mp4';
    final newPath = '${directory.path}/$fileName';

    try {
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
      await _cleanupVideoFile(newPath);

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频已成功保存到相册')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频保存到相册失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存视频时发生错误')),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  /// 清理临时视频文件
  /// 
  /// [videoPath] 需要清理的视频文件路径
  Future<void> _cleanupVideoFile(String videoPath) async {
    try {
      final File videoFile = File(videoPath);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
    } catch (e) {
      debugPrint('Error cleaning up video file: $e');
    }
  }

  @override
  void dispose() {
    FlutterOverlayWindow.closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
