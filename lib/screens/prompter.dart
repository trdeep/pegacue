import 'package:flutter/material.dart';
import 'add_cue_page.dart'; // 导入新增页面

class Prompter extends StatelessWidget {
  const Prompter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 头部内容
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo和添加按钮
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '佩嘉',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[400],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 32),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddCuePage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 提示文本
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '佩嘉提词器可悬浮在任意App之上，你可以在抖音、快手、原相机等软件上使用，适用于直播/短视频等场景。',
                                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 6,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 主要内容区域（白色背景部分）
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // 新建台词按钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddCuePage()),
                          );
                        },
                        child: const Text('+ 新建台词'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 功能区域网格
                  SizedBox(
                    height: 150,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      padding: const EdgeInsets.all(16.0),
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildFeatureItem('悬浮提词', '可直播可拍摄', Icons.slideshow, Colors.orange),
                        _buildFeatureItem('拍摄提词', 'App拍摄剪辑', Icons.camera_alt, Colors.blue),
                        _buildFeatureItem('提词板', '', Icons.view_agenda, Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 我的台词区域（包含标题和列表）
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              child: Container(
                color: const Color(0xFFF9F9F9),
                child: Column(
                  children: [
                    // 我的台词标题
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 60,
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).padding.top,
                          ),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '我的台词',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              height: MediaQuery.of(context).padding.top + 60,
            ),
          ),
          // 台词列表
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF9F9F9),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: List.generate(11, (index) {
                    if (index < 10) {
                      return _buildMyCueCard(
                        index == 0 ? '未命名台词-2024.12.19' : '晓韵',
                        '2024.12.19 00:${index.toString().padLeft(2, '0')}',
                        '去提词',
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            '没有更多了！',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildMyCueCard(String title, String date, String action) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              's的方式对方的身份都是s的方式对方的身份都是s的方式对方的身份都是s的方式对方的身份都是对方的身份都是s的方式对方的身份都是对方的身份都是s的方式对方的身份都是对方的身份都是s的方式对方的身份都是...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '122字/预计录0分40秒',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        // TODO: 去提词
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange[50],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverHeaderDelegate({
    required this.child,
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return true;
  }
}
