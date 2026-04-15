import 'package:flutter/material.dart';

/// 视频预览区展示壳。
class VideoInfoPlaybackSection extends StatelessWidget {
  final bool hasVideoStream;
  final Widget? preview;

  const VideoInfoPlaybackSection({
    super.key,
    required this.hasVideoStream,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('视频预览', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (hasVideoStream)
              preview ?? const _PlaybackPlaceholder()
            else
              Text('无视频流，无法预览', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PlaybackPlaceholder extends StatelessWidget {
  const _PlaybackPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('预览功能待接入', style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
