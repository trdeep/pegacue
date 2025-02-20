import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:pegacue/screens/teleprompter.dart';
import 'package:pegacue/utils/tools.dart';
import '../models/cue.dart';
import '../services/global.dart';
import '../widgets/cue_list_card.dart';
import '../widgets/cue_selector_dialog.dart';
import 'bluetooth_scan.dart';
import 'camera_prompter.dart';
import 'edit_cue.dart';
import '../utils/database_helper.dart';

class Prompter extends StatefulWidget {
  const Prompter({super.key});

  @override
  _PrompterState createState() => _PrompterState();
}

class _PrompterState extends State<Prompter> {
  late Future<List<Cue>> _cuesFuture;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _cuesFuture = _fetchCues();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  Future<List<Cue>> _fetchCues() async {
    try {
      return await DatabaseHelper.instance.getAllCues();
    } catch (e) {
      debugPrint('获取台词列表失败: $e');
      rethrow;
    }
  }

  Future<void> _openTeleprompter(String deltaJson) async {
    try {
      final status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        final permissionGranted = await FlutterOverlayWindow.requestPermission();
        if (!permissionGranted!) {
          throw Exception('未获得悬浮窗权限');
        }
      }

      if (await FlutterOverlayWindow.isActive()) {
        debugPrint('悬浮窗已经处于活动状态');
        return;
      }

      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        width: 1000,
        height: 1500,
      );

      final SendPort? htmlPort = IsolateNameServer.lookupPortByName('HTML_DATA_PORT');
      if (htmlPort == null) {
        throw Exception('未找到 HTML_DATA_PORT');
      }

      htmlPort.send(deltaJsonToHtml(deltaJson));
    } catch (e) {
      debugPrint('打开悬浮提词器失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开悬浮提词器失败: $e')),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildMainContent(),
          _buildCueListHeader(),
          _buildCueList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
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
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BluetoothScanScreen()),
                              ).then((_) {
                                setState(() {
                                  _cuesFuture = _fetchCues();
                                });
                              });
                            },
                          ),
                          Positioned(
                            right: 8,
                            bottom: 30,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Global.connectedDevices.isEmpty ? Colors.grey : Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenHeight = MediaQuery.of(context).size.height;
                      final availableHeight = screenHeight - 250 - 20; // 250 is the height of the container, 20 is the bottom margin
                      final fontSize = constraints.maxWidth * 0.038;
                      final padding = constraints.maxWidth * 0.03;

                      return Container(
                        padding: EdgeInsets.all(padding),
                        margin: const EdgeInsets.only(bottom: 20),
                        height: availableHeight,
                        width: 160, // Ensure the width remains unchanged
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '佩嘉提词器可悬浮在任意App之上，你可以在抖音、快手、原相机等软件上使用，适用于直播/短视频等场景。',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMainContent() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
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
                      '拍摄提词', 'APP拍摄剪辑', Icons.camera_alt, Colors.blue),
                  _buildFeatureItem(
                      '提词板', '', Icons.view_agenda, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCueListHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverHeaderDelegate(
        child: Container(
          color: const Color(0xFFF9F9F9),
          child: Column(
            children: [
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
    );
  }

  Widget _buildCueList() {
    return SliverToBoxAdapter(
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
                // 当列表为空时，填充整个区域并不显示分层颜色
                return Container(
                  color: const Color(0xFFF9F9F9), // 填充整个区域的颜色
                  height: 230,
                  child: const Center(child: Text('没有台词')),
                );
              } else {
                final cues = snapshot.data!;
                return Column(
                  children: List.generate(cues.length, (index) {
                    return CueCard(
                      cue: cues[index],
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
                _openTeleprompter(cue.deltaJson);
              } else if (title == '拍摄提词') {
                _openTeleprompter(cue.deltaJson);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraPrompterPage(),
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