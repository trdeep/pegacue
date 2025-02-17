import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
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

class _FloatingPrompterWidgetState extends State<FloatingPrompterWidget> with SingleTickerProviderStateMixin {
  Offset position = const Offset(20, 100);
  Size size = const Size(300, 500);
  bool isDragging = false;
  bool isResizing = false;

  // 滚动控制
  late ScrollController _scrollController;
  late AnimationController _scrollAnimationController;
  double _scrollSpeed = 0.2;
  static const double _minSpeed = 0.1;
  static const double _maxSpeed = 10.0;
  static const double _speedStep = 0.05;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initScrolling();
  }

  void _initScrolling() {
    _scrollController = ScrollController();
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _scrollAnimationController.addListener(() {
      if (_scrollController.hasClients && _isPlaying) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + _scrollSpeed);
        }
      }
    });

    if (_isPlaying) {
      _scrollAnimationController.repeat();
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _scrollAnimationController.repeat();
    } else {
      _scrollAnimationController.stop();
    }
    log('_isPlaying：$_isPlaying');
  }

  void _updateScrollSpeed(double newSpeed) {
    setState(() {
      _scrollSpeed = newSpeed.clamp(_minSpeed, _maxSpeed);
    });
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _scrollController.dispose();
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
                // 内容显示区域
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Html(
                          data: deltaJsonToHtmlFull(widget.content),
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(30),
                              lineHeight: LineHeight.number(1.4),
                              color: Colors.white,
                              textDecoration: TextDecoration.none,
                            )
                          },
                        ),
                      ),
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
                  bottom: 50,
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