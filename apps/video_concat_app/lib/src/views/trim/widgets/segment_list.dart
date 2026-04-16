import 'package:flutter/material.dart';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';

/// 已选片段列表
class SegmentList extends StatelessWidget {
  final List<TrimSegment> segments;
  final int? pendingInpointUs;
  final ValueChanged<int> onDelete;
  final VoidCallback? onDeletePending;

  const SegmentList({
    super.key,
    required this.segments,
    this.pendingInpointUs,
    required this.onDelete,
    this.onDeletePending,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = segments.length + (pendingInpointUs != null ? 1 : 0);

    if (totalCount == 0) {
      return const Center(
        child: Text(
          '未选择裁剪片段\n确认后将使用完整视频',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: totalCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index < segments.length) {
          final seg = segments[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 14,
              child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text(
              '${formatTimestampDisplay(seg.inpoint)}'
              ' → ${formatTimestampDisplay(seg.outpoint)}',
            ),
            subtitle: Text(
              '时长: ${formatTimestampDisplay(seg.durationUs)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onDelete(index),
              tooltip: '删除',
            ),
          );
        } else {
          return ListTile(
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
            ),
            title: Text(
              '${formatTimestampDisplay(pendingInpointUs!)} → …',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            subtitle: Text(
              '待设置终点',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDeletePending,
              tooltip: '删除',
            ),
          );
        }
      },
    );
  }
}
