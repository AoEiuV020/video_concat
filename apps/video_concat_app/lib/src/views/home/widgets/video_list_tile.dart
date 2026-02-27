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
  final bool isIncompatible;

  const VideoListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    this.onTap,
    this.isOutOfOrder = false,
    this.isIncompatible = false,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIncompatible)
            const Tooltip(
              message: '编码参数与第一个视频不一致',
              child: Icon(Icons.warning, color: Colors.red, size: 20),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: '删除',
          ),
        ],
      ),
    );
  }
}
