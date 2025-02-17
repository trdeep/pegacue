import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/tools.dart';

class CameraPrompterPage extends StatefulWidget {
  final String title;
  final String deltaJson;

  const CameraPrompterPage({
    super.key,
    required this.title,
    required this.deltaJson,
  });

  @override
  State<CameraPrompterPage> createState() => _CameraPrompterPageState();
}

class _CameraPrompterPageState extends State<CameraPrompterPage> {
  @override
  void initState() {
    super.initState();
    _openCameraApp();
  }

  Future<void> _openCameraApp() async {
    // 尝试使用不同的意图 URL
    const url = 'intent://media/#Intent;action=android.media.action.STILL_IMAGE_CAMERA;end';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // 如果上面的 URL 不起作用，尝试另一个 URL
      const fallbackUrl = 'intent://com.android.camera/#Intent;scheme=content;end';
      if (await canLaunch(fallbackUrl)) {
        await launch(fallbackUrl);
      } else {
        throw 'Could not launch camera app';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Camera'),
      ),
      body: Center(),
    );
  }
}