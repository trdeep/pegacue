import 'package:flutter/material.dart';
import 'prompter.dart';
import 'mine.dart';

/// 主页框架
/// 
/// 应用的主要导航页面，包含以下功能：
/// - 提词器页面：用于管理和显示台词
/// - 个人中心页面：用于管理用户相关功能
/// 
/// 使用底部导航栏进行页面切换，保持页面状态。
class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  /// 当前选中的页面索引
  int _currentIndex = 0;
  
  /// 页面列表
  /// 
  /// 包含提词器和个人中心两个主要页面
  final List<Widget> _pages = [
    const Prompter(),
    const Mine(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: '提词',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
