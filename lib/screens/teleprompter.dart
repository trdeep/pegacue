import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pegacue/screens/prompter.dart';
import '../utils/tools.dart';

/// 提词器页面组件
///
/// 提供自动滚动文本显示功能，支持播放/暂停和速度调节
class TeleprompterPage extends StatefulWidget {
  /// 提词器标题
  final String title;

  /// 富文本数据的JSON字符串
  final String deltaJson;

  const TeleprompterPage({
    super.key,
    required this.title,
    required this.deltaJson,
  });

  @override
  State<TeleprompterPage> createState() => _TeleprompterPageState();
}

class _TeleprompterPageState extends State<TeleprompterPage>
    with SingleTickerProviderStateMixin {
  /// 滚动控制器，用于控制文本滚动
  late ScrollController _scrollController;

  /// 动画控制器，用于控制滚动动画
  late AnimationController _scrollAnimationController;

  /// 是否正在滚动
  bool _isScrolling = false;

  /// 当前滚动速度（像素/帧）
  double _scrollSpeed = 0.2;

  /// 最小滚动速度
  static const double _minSpeed = 0.1;

  /// 最大滚动速度
  static const double _maxSpeed = 10.0;

  /// 速度调节步长
  static const double _speedStep = 0.05;

  @override
  void initState() {
    super.initState();
    // 设置全屏沉浸式模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 允许所有屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initScrolling();
  }

  /// 初始化滚动控制
  ///
  /// 设置滚动控制器和动画控制器，并添加滚动监听
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

        // 当滚动到底部时，自动回到顶部
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          // 使用 jumpTo 而不是 animateTo 以避免动画叠加导致的性能问题
          _scrollController.jumpTo(currentScroll + _scrollSpeed);
        }
      }
    });
  }

  /// 切换滚动状态
  ///
  /// 控制文本的滚动和暂停
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

  /// 调整滚动速度
  ///
  /// [increase] 为 true 时增加速度，为 false 时减小速度
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Prompter()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 内容区域
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
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
                    ),
                    "u": Style(textDecorationColor: Colors.redAccent)
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
                    heroTag: 'decreaseSpeed',
                    onPressed: () => _adjustSpeed(false),
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    child: const Icon(Icons.keyboard_double_arrow_left,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  // 播放/暂停按钮
                  FloatingActionButton(
                    heroTag: 'toggleScroll',
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
                    heroTag: 'increaseSpeed',
                    onPressed: () => _adjustSpeed(true),
                    backgroundColor: Colors.orange.withOpacity(0.7),
                    child: const Icon(Icons.keyboard_double_arrow_right,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
