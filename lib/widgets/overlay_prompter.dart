import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

/// 悬浮提词器组件
/// 
/// 提供一个可拖动、可调整大小的悬浮窗口，用于显示台词内容。
/// 支持以下功能：
/// - 自动滚动文本显示
/// - 可调节滚动速度
/// - 窗口拖动和大小调整
/// - 实时接收和显示 HTML 格式的台词
class OverlayPrompter extends StatefulWidget {
  const OverlayPrompter({super.key});

  @override
  State<OverlayPrompter> createState() => _OverlayPrompterState();
}

class _OverlayPrompterState extends State<OverlayPrompter>
    with SingleTickerProviderStateMixin {
  /// 滚动控制器
  late ScrollController _scrollController;

  /// 最小滚动速度（像素/帧）
  static const double _minSpeed = 0.5;
  
  /// 最大滚动速度（像素/帧）
  static const double _maxSpeed = 10.0;
  
  /// 速度调节步长
  static const double _speedStep = 0.5;

  /// 滚动定时器
  Timer? _scrollTimer;
  
  /// HTML 格式的台词内容
  String? _html = '<h1>没有加载台词</h1>';

  /// 当前滚动速度（像素/帧）
  double _scrollSpeed = 1.0;
  
  /// 是否正在自动滚动
  bool _isScrolling = false;

  /// 悬浮窗口宽度
  double _overlayWidth = 350.0;
  
  /// 悬浮窗口高度
  double _overlayHeight = 500.0;

  /// 窗口位置
  Offset position = Offset.zero;
  
  /// 是否正在拖动
  bool isDragging = false;
  
  /// 是否正在调整大小
  bool isResizing = false;

  /// 滚动动画控制器
  late AnimationController _scrollAnimationController;

  /// 用于接收 HTML 数据的端口
  final ReceivePort _htmlReceivePort = ReceivePort();

  @override
  void initState() {
    super.initState();
    _initShowHtml();
    _scrollController = ScrollController();
    _scrollAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _stopScrolling();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('HTML_DATA_PORT');
    _htmlReceivePort.close();
    _stopScrolling();
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化 HTML 数据接收
  void _initShowHtml() {
    IsolateNameServer.removePortNameMapping('HTML_DATA_PORT');
    IsolateNameServer.registerPortWithName(
        _htmlReceivePort.sendPort, 'HTML_DATA_PORT');
    _htmlReceivePort.listen((dynamic data) {
      if (data is String) {
        setState(() {
          _html = data;
        });
      }
    });
  }

  /// 关闭悬浮窗口
  Future<void> _closeOverlay() async {
    _stopScrolling();
    _scrollController.jumpTo(0);
    await FlutterOverlayWindow.closeOverlay();
  }

  /// 开始自动滚动
  void _startScrolling() {
    _isScrolling = true;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final newOffset = _scrollController.offset + _scrollSpeed;
        if (newOffset < maxExtent) {
          _scrollController.jumpTo(newOffset);
        } else {
          _stopScrolling();
          _scrollController.jumpTo(0);
        }
      }
    });
    setState(() {});
  }

  /// 停止自动滚动并重置状态
  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _isScrolling = false;
    _scrollSpeed = 1.0;

    _overlayWidth = 350.0;
    _overlayHeight = 500.0;

    position = Offset.zero;
    isDragging = false;
    isResizing = false;

    setState(() {});
  }

  /// 切换滚动状态
  void _toggleScrolling() {
    if (_isScrolling) {
      _stopScrolling();
    } else {
      _startScrolling();
    }
  }

  /// 更新悬浮窗口大小和位置
  Future<void> _updateOverlay() async {
    await FlutterOverlayWindow.resizeOverlay(
        _overlayWidth.toInt(), _overlayHeight.toInt(), false);
    await FlutterOverlayWindow.moveOverlay(
        OverlayPosition(position.dx, position.dy));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
            onPanEnd: (details) {
              setState(() => isDragging = false);
              _updateOverlay();
            },
            child: Container(
              width: _overlayWidth,
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
                    icon: Icon(Icons.close,
                        color: Colors.white.withOpacity(0.6)),
                    onPressed: _closeOverlay,
                  ),
                ],
              ),
            ),
          ),
          // 内容区域
          Container(
            width: _overlayWidth,
            height: _overlayHeight - 50,
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
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                        child: Html(
                          data: _html,
                          style: {
                            "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(30),
                                lineHeight: LineHeight.number(1.4),
                                color: Colors.white),
                            "u": Style(textDecorationColor: Colors.redAccent)
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
                          icon: const Icon(
                            Icons.keyboard_double_arrow_left,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _scrollSpeed = (_scrollSpeed - _speedStep)
                                  .clamp(_minSpeed, _maxSpeed);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _isScrolling ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _toggleScrolling,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_double_arrow_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _scrollSpeed = (_scrollSpeed + _speedStep)
                                  .clamp(_minSpeed, _maxSpeed);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 右下角大小调节手柄
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _overlayWidth = (_overlayWidth + details.delta.dx)
                            .clamp(200.0, 800.0);
                        _overlayHeight = (_overlayHeight + details.delta.dy)
                            .clamp(200.0, 800.0);

                        _updateOverlay();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.transparent,
                      child: Icon(
                        Icons.zoom_out_map,
                        size: 18,
                        color: Colors.white.withOpacity(0.6),
                      ),
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

/*

 Widget build0(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
          children: [
            Positioned(
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
                    onPanEnd: (details) {
                      setState(() => isDragging = false);
                      _updateOverlay(); // 拖动结束时更新位置
                    },
                    child: Container(
                      width: _overlayWidth,
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
                            icon: Icon(Icons.close,
                                color: Colors.white.withOpacity(0.6)),
                            onPressed: _closeOverlay,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 内容区域
                  Container(
                    width: _overlayWidth,
                    height: _overlayHeight - 50,
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
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Html(
                                  data: widget.html,
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
                                  icon: const Icon(
                                    Icons.keyboard_arrow_left,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _scrollSpeed = (_scrollSpeed - _speedStep)
                                          .clamp(_minSpeed, _maxSpeed);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isScrolling ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleScrolling,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _scrollSpeed = (_scrollSpeed + _speedStep)
                                          .clamp(_minSpeed, _maxSpeed);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 右下角大小调节手柄
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _overlayWidth = (_overlayWidth + details.delta.dx)
                                    .clamp(200.0, 800.0);
                                _overlayHeight = (_overlayHeight + details.delta.dy)
                                    .clamp(200.0, 800.0);

                                _updateOverlay();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              color: Colors.transparent,
                              child: Icon(
                                Icons.zoom_out_map,
                                size: 18,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]
      ),
    );
  }

 */
