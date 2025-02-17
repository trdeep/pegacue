import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
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

class _TeleprompterPageState extends State<TeleprompterPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _scrollAnimationController;
  bool _isScrolling = false;

  // 速度控制变量
  double _scrollSpeed = 0.2;
  static const double _minSpeed = 0.1;
  static const double _maxSpeed = 10.0;
  static const double _speedStep = 0.05;

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
      if (_scrollController.hasClients && _isScrolling) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + _scrollSpeed);
        }
      }
    });
  }

  void _toggleScroll() {
    setState(() {
      _isScrolling = !_isScrolling;
    });

    if (_isScrolling) {
      _scrollAnimationController.repeat();
    } else {
      _scrollAnimationController.stop();
    }
  }

  void _adjustSpeed(bool increase) {
    setState(() {
      if (increase) {
        _scrollSpeed = (_scrollSpeed + _speedStep).clamp(_minSpeed, _maxSpeed);
      } else {
        _scrollSpeed = (_scrollSpeed - _speedStep).clamp(_minSpeed, _maxSpeed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 内容区域
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Html(
                data: deltaJsonToHtmlFull(widget.deltaJson),
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(40),
                    lineHeight: LineHeight.number(1.5),
                    color: Colors.white,
                    textDecoration: TextDecoration.none,
                  )
                },
              ),
            ),
          ),
          
          // 控制按钮
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
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}