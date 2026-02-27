import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../utils/format_utils.dart';

/// 视频列表项
class VideoListTile extends StatelessWidget {
  final VideoItem item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool isOutOfOrder;

  const VideoListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    this.onTap,
    this.isOutOfOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_indicator),
      ),
      title: Text(
        item.fileName,
        overflow: TextOverflow.ellipsis,
        style: isOutOfOrder ? const TextStyle(color: Colors.red) : null,
      ),
      subtitle: Text(
        '${formatFileSize(item.fileSize)} • ${item.filePath}',
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
