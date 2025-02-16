import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import '../utils/tools.dart';

class TeleprompterPage extends StatefulWidget {
  final String title;
  final String deltaJson;

  const TeleprompterPage({
    super.key,
    required this.title,
    required this.deltaJson,
  });

  @override
  State<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends State<TeleprompterPage> {
  late WebViewControllerPlus _controller;
  bool _isLoading = true;
  late final String _htmlContent;

  @override
  void initState() {
    super.initState();
    // 隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            background-color: black;
            color: white;
            font-size: 50px;
            line-height: 1.2;
            overflow-x: hidden;
          }
          ::-webkit-scrollbar {
            display: none;
          }
        </style>
      </head>
      <body>
        ${deltaJsonToHtml(widget.deltaJson)}
      </body>
    </html>
    ''';

    _controller = WebViewControllerPlus()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    
    await _controller.loadHtmlString(_htmlContent);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 恢复状态栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller));
  }
}