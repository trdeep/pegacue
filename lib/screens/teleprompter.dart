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
  bool _isScrolling = false;
  bool _isLoading = true;
  late final String _htmlContent;

  // 速度控制变量
  double _scrollSpeed = 1.5;
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 10.0;
  static const double _speedStep = 0.25;

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
            padding: 16px;
            background-color: black;
            color: white;
            font-size: 40px;
            line-height: 1.5;
            opacity: 0;
            transition: opacity 0.3s ease;
          }
          ::-webkit-scrollbar {
            display: none;
          }
        </style>
        <script>
          var scrollInterval;
          var scrollSpeed = 1.0;
          
          function startScroll() {
            scrollInterval = setInterval(() => {
              window.scrollBy(0, scrollSpeed);
            }, 50);
          }
          
          function stopScroll() {
            clearInterval(scrollInterval);
          }
          
          function setScrollSpeed(speed) {
            scrollSpeed = speed;
            if (scrollInterval) {
              stopScroll();
              startScroll();
            }
          }

          document.addEventListener('DOMContentLoaded', function() {
            setTimeout(() => {
              document.body.style.opacity = '1';
              PageLoaded.postMessage('loaded');
            }, 100);
          });
        </script>
      </head>
      <body>
        ${deltaJsonToHtml(widget.deltaJson)}
      </body>
    </html>
    ''';

    _controller = WebViewControllerPlus()
      ..setBackgroundColor(Colors.black)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // 添加 JavaScript Channel
    _controller.addJavaScriptChannel(
      'PageLoaded',
      onMessageReceived: (JavaScriptMessage message) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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

  void _adjustSpeed(bool increase) async {
    setState(() {
      if (increase) {
        _scrollSpeed = (_scrollSpeed + _speedStep).clamp(_minSpeed, _maxSpeed);
      } else {
        _scrollSpeed = (_scrollSpeed - _speedStep).clamp(_minSpeed, _maxSpeed);
      }
    });

    await _controller.runJavaScript('setScrollSpeed(${_scrollSpeed})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // WebView
          Visibility(
            visible: !_isLoading,
            maintainState: true,
            child: WebViewWidget(controller: _controller),
          ),
          
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
              bottom: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 减速按钮
                  FloatingActionButton.small(
                    onPressed: () => _adjustSpeed(false),
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    child: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  // 播放/暂停按钮
                  FloatingActionButton(
                    onPressed: _toggleScroll,
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    child: Icon(
                      _isScrolling ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 加速按钮
                  FloatingActionButton.small(
                    onPressed: () => _adjustSpeed(true),
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}