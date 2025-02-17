import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import '../utils/tools.dart';

class FloatingPrompterWidget extends StatefulWidget {
  final String title;
  final String content;

  const FloatingPrompterWidget({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<FloatingPrompterWidget> createState() => _FloatingPrompterWidgetState();
}

class _FloatingPrompterWidgetState extends State<FloatingPrompterWidget> {
  late WebViewControllerPlus _controller;
  Offset position = const Offset(20, 100);
  Size size = const Size(300, 500);
  bool isDragging = false;
  bool isResizing = false;
  bool isWebViewReady = false;
  late final String _htmlContent;
  double _scrollSpeed = 1.5;
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 10.0;
  static const double _speedStep = 0.25;
  bool _isPlaying = true;

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _controller.runJavaScript(_isPlaying ? 'startScroll()' : 'stopScroll()');
    log('_isPlaying：$_isPlaying');
  }

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
          html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            background-color: transparent;
            overflow-y: scroll;
          }
          .content {
            padding: 16px;
            color: white;
            font-size: 24px;
            line-height: 1.8;
            opacity: 0;
            transition: opacity 0.3s ease;
          }
          ::-webkit-scrollbar {
            width: 0px;
          }
        </style>
        <script>
          let scrollInterval;
          let scrollSpeed = ${_scrollSpeed};
          let isScrolling = false;

          function startScroll() {
            if (!isScrolling) {
              isScrolling = true;
              scrollInterval = setInterval(() => {
                window.scrollBy(0, scrollSpeed);
                if ((window.innerHeight + window.scrollY) >= document.body.scrollHeight) {
                  window.scrollTo(0, 0);
                }
              }, 20);
            }
          }

          function stopScroll() {
            isScrolling = false;
            clearInterval(scrollInterval);
          }

          function setScrollSpeed(speed) {
            scrollSpeed = speed;
            if (isScrolling) {
              stopScroll();
              startScroll();
            }
          }

          function init() {
            document.querySelector('.content').style.opacity = '1';
            PageLoaded.postMessage('loaded');
            startScroll();
          }

          document.addEventListener('DOMContentLoaded', () => {
            setTimeout(init, 100);
          });

          document.addEventListener('wheel', () => {
            stopScroll();
            setTimeout(startScroll, 2000);
          });

          document.addEventListener('touchstart', () => {
            stopScroll();
          });

          document.addEventListener('touchend', () => {
            setTimeout(startScroll, 2000);
          });
        </script>
      </head>
      <body>
        <div class="content">
          ${deltaJsonToHtml(widget.content)}
        </div>
      </body>
    </html>
    ''';

    _controller = WebViewControllerPlus()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller.addJavaScriptChannel(
      'PageLoaded',
      onMessageReceived: (JavaScriptMessage message) {
        setState(() {
          isWebViewReady = true;
        });
      },
    );

    await _controller.loadHtmlString(_htmlContent);
  }

  void _updateScrollSpeed(double newSpeed) {
    setState(() {
      _scrollSpeed = newSpeed.clamp(_minSpeed, _maxSpeed);
    });
    _controller.runJavaScript('setScrollSpeed($_scrollSpeed)');
  }

  @override
  void dispose() {
    _controller.runJavaScript('stopScroll()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        children: [
          // 顶部拖动区域
          GestureDetector(
            onPanStart: (details) => setState(() => isDragging = true),
            onPanUpdate: (details) {
              if (isDragging) {
                setState(() {
                  position += details.delta;
                });
              }
            },
            onPanEnd: (details) => setState(() => isDragging = false),
            child: Container(
              width: size.width,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(''),
                  ),
                  // 关闭按钮
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          Container(
            width: size.width,
            height: size.height - 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Stack(
              children: [
                // WebView 容器
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: SizedBox(
                    width: size.width,
                    height: size.height - 40,
                    child: isWebViewReady
                        ? WebViewWidget(controller: _controller)
                        : const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                  ),
                ),

                // 底部控制栏
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_double_arrow_left,
                              color: Colors.white),
                          onPressed: () =>
                              _updateScrollSpeed(_scrollSpeed - _speedStep),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlay,
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_double_arrow_right,
                              color: Colors.white),
                          onPressed: () =>
                              _updateScrollSpeed(_scrollSpeed + _speedStep),
                        ),
                      ],
                    ),
                  ),
                ),

                // 大小调节手柄
                Positioned(
                  right: 0,
                  bottom: 50, // 调整位置以避免与底部控制栏重叠
                  child: GestureDetector(
                    onPanStart: (details) => setState(() => isResizing = true),
                    onPanUpdate: (details) {
                      if (isResizing) {
                        setState(() {
                          final newWidth = (size.width + details.delta.dx)
                              .clamp(200.0, MediaQuery.of(context).size.width - 40);
                          final newHeight = (size.height + details.delta.dy)
                              .clamp(200.0, MediaQuery.of(context).size.height - 100);
                          size = Size(newWidth, newHeight);
                        });
                      }
                    },
                    onPanEnd: (details) => setState(() => isResizing = false),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Icon(Icons.zoom_out_map,
                          size: 18, color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}