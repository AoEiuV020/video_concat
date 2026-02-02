import 'package:flutter/material.dart';

import '../../../models/models.dart';

/// 视频列表项
class VideoListTile extends StatelessWidget {
  final VideoItem item;
  final int index;
  final VoidCallback onDelete;

  const VideoListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_indicator),
      ),
      title: Text(
        item.fileName,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item.filePath,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
        tooltip: '删除',
      ),
    );
  }
}
