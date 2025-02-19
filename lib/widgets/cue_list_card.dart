import 'package:flutter/material.dart';
import 'package:pegacue/models/cue.dart';
import '../utils/database_helper.dart';
import '../screens/edit_cue.dart';
import '../screens/teleprompter.dart';

///
/// 台词列表卡片
///
class CueCard extends StatelessWidget {
  final Cue cue;
  final VoidCallback onUpdate;

  const CueCard({
    super.key,
    required this.cue,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    String date = cue.createdAt
        .toString()
        .substring(0, cue.createdAt.toString().lastIndexOf('.'));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCuePage(
              id: cue.id,
              title: cue.title,
              date: date,
              deltaJson: cue.deltaJson,
            ),
          ),
        ).then((_) {
          onUpdate();
        });
      },
      child: Container(
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
                    cue.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == '删除') {
                        _deleteCue(context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: '删除',
                          child: Text('删除'),
                        ),
                      ];
                    },
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cue.plainText,
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
                      fontSize:
                          MediaQuery.of(context).size.width * 0.028, // 动态计算字体大小
                      color: Colors.grey[400],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${cue.wordCount}字/预计录${_formatDuration((cue.wordCount / 2).toInt())}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.028, // 动态计算字体大小
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeleprompterPage(
                                title: cue.title,
                                deltaJson: cue.deltaJson,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange[50],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '去提词',
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
      ),
    );
  }

  void _deleteCue(BuildContext context) async {
    await DatabaseHelper.instance.deleteCue(cue.id!);
    onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('台词已删除')),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 0) return "0秒";

    int hours = totalSeconds ~/ 3600;
    int remaining = totalSeconds % 3600;
    int minutes = remaining ~/ 60;
    int seconds = remaining % 60;

    StringBuffer result = StringBuffer();

    if (hours > 0) {
      result.write("${hours}时");
      result.write("${minutes.toString().padLeft(2, '0')}分");
      result.write("${seconds.toString().padLeft(2, '0')}秒");
    } else if (minutes > 0) {
      result.write("${minutes}分");
      result.write("${seconds.toString().padLeft(2, '0')}秒");
    } else {
      result.write("${seconds}秒");
    }

    return result.toString();
  }
}
