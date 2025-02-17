import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pegacue/screens/teleprompter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cue.dart';
import '../utils/tools.dart';
import '../widgets/cue_list_card.dart';
import '../widgets/cue_selector_dialog.dart';
import 'camera_prompter.dart';
import 'camera_prompter2.dart';
import 'edit_cue.dart';
import '../utils/database_helper.dart';

///
/// 主界面
///
class Prompter extends StatefulWidget {
  const Prompter({super.key});

  @override
  _PrompterState createState() => _PrompterState();
}

class _PrompterState extends State<Prompter> {
  late Future<List<Cue>> _cuesFuture;

  @override
  void initState() {
    super.initState();
    _cuesFuture = _fetchCues();
  }

  Future<List<Cue>> _fetchCues() async {
    return await DatabaseHelper.instance.getAllCues();
  }

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
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.orange, size: 32),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditCuePage()),
                                ).then((_) {
                                  setState(() {
                                    _cuesFuture = _fetchCues();
                                  });
                                });
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final fontSize = screenWidth * 0.032;
                                final padding = screenWidth * 0.03;

                                return Container(
                                  padding: EdgeInsets.all(padding),
                                  // 将 margin 修改为固定的底部间距
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '佩嘉提词器可悬浮在任意App之上，你可以在抖音、快手、原相机等软件上使用，适用于直播/短视频等场景。',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                );
                              },
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
              //color: const Color(0xFFF9F9F9),
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
                            MaterialPageRoute(
                                builder: (context) => const EditCuePage()),
                          ).then((_) {
                            setState(() {
                              _cuesFuture = _fetchCues();
                            });
                          });
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
                        _buildFeatureItem(
                            '悬浮提词', '可直播可拍摄', Icons.slideshow, Colors.orange),
                        _buildFeatureItem(
                            '拍摄提词', 'App拍摄剪辑', Icons.camera_alt, Colors.blue),
                        _buildFeatureItem(
                            '提词板', '', Icons.view_agenda, Colors.green),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 8),
                                Text(
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
                child: FutureBuilder<List<Cue>>(
                  future: _cuesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('加载失败'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('没有台词'));
                    } else {
                      final cues = snapshot.data!;
                      return Column(
                        children: List.generate(cues.length, (index) {
                          final cue = cues[index];
                          return CueCard(
                            id: cue.id!,
                            title: cue.title,
                            date: cue.createdAt.toString().substring(
                                0, cue.createdAt.toString().lastIndexOf('.')),
                            plainText: cue.plainText,
                            deltaJson: cue.deltaJson,
                            wordCount: cue.wordCount,
                            action: '去提词',
                            onUpdate: () {
                              setState(() {
                                _cuesFuture = _fetchCues();
                              });
                            },
                          );
                        }),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      String title, String subtitle, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CueSelectorDialog(
            title: '选择台词',
            onCueSelected: (cue) async {
              if (title == '提词板') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeleprompterPage(
                      title: cue.title,
                      deltaJson: cue.deltaJson,
                    ),
                  ),
                );
              } else if (title == '悬浮提词') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPrompterPage2(
                      title: cue.title,
                      content: cue.deltaJson,
                    ),
                  ),
                );

              } else if (title == '拍摄提词') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPrompterPage(
                      title: cue.title,
                      content: cue.deltaJson,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
      child: Container(
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return true;
  }
}
