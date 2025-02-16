import 'package:flutter/material.dart';
import '../models/cue.dart';
import '../utils/database_helper.dart';
import '../screens/teleprompter.dart';

class CueSelectorDialog extends StatefulWidget {
  final String title;
  final Function(Cue) onCueSelected;

  const CueSelectorDialog({
    super.key,
    required this.title,
    required this.onCueSelected,
  });

  @override
  State<CueSelectorDialog> createState() => _CueSelectorDialogState();
}

class _CueSelectorDialogState extends State<CueSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<List<Cue>>(
        future: DatabaseHelper.instance.getAllCues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('加载失败')),
            );
          }

          final allCues = snapshot.data ?? [];
          if (allCues.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('没有台词')),
            );
          }

          // 过滤台词
          final filteredCues = allCues.where((cue) {
            return cue.title.contains(_searchText) ||
                cue.plainText.contains(_searchText);
          }).toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 搜索框
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                //   child: TextField(
                //     controller: _searchController,
                //     decoration: InputDecoration(
                //       hintText: '关键字',
                //       prefixIcon: const Icon(Icons.search),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       contentPadding: const EdgeInsets.symmetric(
                //         horizontal: 16,
                //         vertical: 8,
                //       ),
                //     ),
                //     onChanged: (value) {
                //       setState(() {
                //         _searchText = value;
                //       });
                //     },
                //   ),
                // ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(), // 添加弹性滚动效果
                    itemCount: filteredCues.length,  // 显示所有过滤后的台词
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cue = filteredCues[index];
                      return ListTile(
                        title: Text(
                          cue.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          cue.plainText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onCueSelected(cue);
                        },
                      );
                    },
                  ),
                ),
                // 移除底部的计数提示，因为现在显示所有内容
              ],
            ),
          );
        },
      ),
    );
  }
}