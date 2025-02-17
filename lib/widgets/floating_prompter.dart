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
            overflow-y: auto; /* 允许垂直滚动 */
            -webkit-overflow-scrolling: touch; /* iOS 流畅滚动 */
          }
          .content {
            padding: 16px;
            color: white;
            font-size: 24px;
            line-height: 1.8;
            opacity: 0;
            transition: opacity 0.3s ease;
            min-height: 200%; /* 确保内容足够长以支持滚动 */
          }
          ::-webkit-scrollbar {
            width: 0px; /* 隐藏滚动条但保持功能 */
          }
        </style>
        <script>
          var scrollInterval;
          var scrollSpeed = ${_scrollSpeed};
          var isScrolling = false;
          
          function startScroll() {
            if (!isScrolling) {
              isScrolling = true;
              scrollInterval = setInterval(() => {
                window.scrollBy({
                  top: scrollSpeed,
                  behavior: 'smooth'
                });
                
                // 检查是否到达底部，如果是则回到顶部
                if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
                  window.scrollTo(0, 0);
                }
              }, 50);
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

          document.addEventListener('DOMContentLoaded', function() {
            setTimeout(() => {
              document.querySelector('.content').style.opacity = '1';
              startScroll();
              PageLoaded.postMessage('loaded');
            }, 300);
          });

          // 添加触摸事件处理
          document.addEventListener('touchstart', function() {
            stopScroll();
          });

          document.addEventListener('touchend', function() {
            setTimeout(startScroll, 1000);
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _updateScrollSpeed(_scrollSpeed - _speedStep),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _updateScrollSpeed(_scrollSpeed + _speedStep),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          Container(
            width: size.width,
            height: size.height - 40, // 减去顶部高度
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

                // 大小调节手柄
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanStart: (details) => setState(() => isResizing = true),
                    onPanUpdate: (details) {
                      if (isResizing) {
                        setState(() {
                          size = Size(
                            (size.width + details.delta.dx)
                                .clamp(200.0, MediaQuery.of(context).size.width - 40),
                            (size.height + details.delta.dy + 40) // 加上顶部高度
                                .clamp(190.0, MediaQuery.of(context).size.height - 100),
                          );
                        });
                      }
                    },
                    onPanEnd: (details) => setState(() => isResizing = false),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.zoom_out_map,
                          size: 16, color: Colors.white),
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
