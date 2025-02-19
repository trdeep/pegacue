import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class OverlayPrompter extends StatefulWidget {
  final html = '''
  <div>
    <p>尊敬的数码发展及<strong>新闻</strong>部长兼内政部第二部长 杨莉明女士</p>
    <h1 id="_1">各位会馆领导和代表</h1>
    <p>各位理事、属校校长<br>
    属校教职员以及福建会馆会员们<br>
    各位嘉宾，大家中午好！</p>
    <ol>
      <li>首先，我谨代表新加坡福建会馆全体同仁，欢迎主宾 —— 数码发展及新闻部长兼内政部第二部长杨莉明女士，以及各位嘉宾，拨冗出席今天的新春团拜。在此祝愿大家在新的一年里，身心安康、吉祥如意、步步高升、阖家幸福。</li>
      <li>今年新加坡欢庆建国60周年，而新加坡福建会馆，则是庆祝成立185周年！成立于1840年的福建会馆，多年来得力于各位乡贤以<em>及华社同仁的</em>通力合作、鼎力支持，使得会务日益精进，会馆也能够在推动教育、推广华族语言文化、以及推进社会公益这三方面，尽心尽力，支持社会国家的发展。再次衷心感谢所有为福建会馆出钱出力的理事、会员、教职员和义工们，“福建人、做阵行，也做阵赢！”，只要我们团结一致，一定能够克服万难、一起向前迈进！</li>
      <li>福建会馆为庆祝成立185周<del>年，将于今年</del>举办一系列精彩的庆祝活动，包括5月18日在南洋理工大学进行的慈善行兼跑，除了10公里的义跑，也欢迎公众到来参加1.85公里的义走，届时也将有小朋友喜欢的迷你嘉年华，欢迎各位会员、各位会馆朋友们合家参与，同欢共庆。</li>
    </ol>
  </div>
  ''';

  const OverlayPrompter({super.key});

  @override
  State<OverlayPrompter> createState() => _OverlayPrompterState();
}

class _OverlayPrompterState extends State<OverlayPrompter>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  double _scrollSpeed = 1.0; // 每个周期滚动的像素数
  bool _isScrolling = false; // 默认关闭自动滚动
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 10.0;
  static const double _speedStep = 0.5;

  // 悬浮框初始宽高
  double _overlayWidth = 350.0;
  double _overlayHeight = 500.0;

  Offset position = const Offset(10, 100);
  bool isDragging = false;
  bool isResizing = false;

  // 滚动控制
  late AnimationController _scrollAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 50));
    _stopScrolling();
  }

  @override
  void dispose() {
    _stopScrolling();
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _closeOverlay() async {
    _stopScrolling();
    await FlutterOverlayWindow.closeOverlay();
  }

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
        }
      }
    });
    setState(() {});
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _isScrolling = false;
    setState(() {});
  }

  void _toggleScrolling() {
    if (_isScrolling) {
      _stopScrolling();
    } else {
      _startScrolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: SizedBox(
              width: _overlayWidth,
              height: _overlayHeight,
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
                    height: _overlayHeight - 40,
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
                                    _isScrolling
                                        ? Icons.pause
                                        : Icons.play_arrow,
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
                                _overlayWidth =
                                    (_overlayWidth + details.delta.dx)
                                        .clamp(200.0, 800.0);
                                _overlayHeight =
                                    (_overlayHeight + details.delta.dy)
                                        .clamp(200.0, 800.0);
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
            ),
          ),
        ],
      ),
    );
  }
}