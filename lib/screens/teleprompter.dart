import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import '../utils/tools.dart';

///
/// 提词板
///
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
  bool _isScrolling = false;
  bool _isLoading = true;  // 添加加载状态
  late final String _htmlContent;

  @override
  void initState() {
    super.initState();
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
            margin: 0;
            padding: 0;
            background-color: black;
            color: white;
            font-size: 50px;
            line-height: 1.2;
            overflow-x: hidden;
            padding-bottom: 60px;
          }
          ::-webkit-scrollbar {
            display: none;
          }
        </style>
        <script>
          var scrollInterval;
          function startScroll() {
            scrollInterval = setInterval(() => {
              window.scrollBy(0, 1);
            }, 50);
          }
          function stopScroll() {
            clearInterval(scrollInterval);
          }
          // 修改为使用 JavaScript Channel
          window.onload = function() {
            PageLoaded.postMessage('loaded');
          }
        </script>
      </head>
      <body style="visibility: hidden">
        ${deltaJsonToHtml(widget.deltaJson)}
      </body>
    </html>
  ''';

    _controller = WebViewControllerPlus()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PageLoaded',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _controller.runJavaScript(
                "document.body.style.visibility = 'visible';"
            );
          }
        },
      );

    await _controller.loadHtmlString(_htmlContent);
  }

  void _toggleScroll() async {
    setState(() {
      _isScrolling = !_isScrolling;
    });

    if (_isScrolling) {
      await _controller.runJavaScript('startScroll()');
    } else {
      await _controller.runJavaScript('stopScroll()');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 设置背景色为黑色
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            ),

          // 控制按钮
          if (!_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _toggleScroll,
                  backgroundColor: Colors.orange.withOpacity(0.7),
                  child: Icon(
                    _isScrolling ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
}
