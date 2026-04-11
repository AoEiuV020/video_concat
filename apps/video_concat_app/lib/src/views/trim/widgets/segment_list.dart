import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 已选片段列表
class SegmentList extends StatelessWidget {
  final List<TrimSegment> segments;
  final ValueChanged<int> onDelete;

  const SegmentList({
    super.key,
    required this.segments,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return const Center(
        child: Text(
          '未选择裁剪片段\n确认后将使用完整视频',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: segments.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
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
      },
    );
  }
}
