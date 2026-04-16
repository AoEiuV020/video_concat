import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../utils/format_utils.dart';

/// 视频列表项
class VideoListTile extends StatelessWidget {
  final VideoItem item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onTrim;
  final bool isOutOfOrder;
  final bool isIncompatible;

  const VideoListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    this.onTap,
    this.onTrim,
    this.isOutOfOrder = false,
    this.isIncompatible = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrim = item.trimConfig != null && item.trimConfig!.isNotEmpty;

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
        [
          formatFileSize(item.fileSize),
          if (item.durationUs != null)
            formatDuration(item.durationUs! / 1000000),
          if (hasTrim) '裁剪: ${item.trimConfig!.segments.length} 片段',
        ].join(' • '),
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTrim)
            const Tooltip(
              message: '已设置裁剪',
              child: Icon(Icons.content_cut, color: Colors.blue, size: 20),
            ),
          if (isIncompatible)
            const Tooltip(
              message: '编码参数与第一个视频不一致',
              child: Icon(Icons.warning, color: Colors.red, size: 20),
            ),
          IconButton(
            icon: Icon(Icons.content_cut, color: hasTrim ? Colors.blue : null),
            onPressed: onTrim,
            tooltip: '裁剪',
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
