import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingPrompterService {
  static Future<bool?> requestPermission() async {
    final status = await FlutterOverlayWindow.requestPermission();
    return status;
  }

  static Future<void> showFloatingPrompt(String title, String content) async {
    if (await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        width: 300,
        height: 200,
        alignment: OverlayAlignment.center,
      );
    }
  }

  static Future<void> closeFloatingPrompt() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}