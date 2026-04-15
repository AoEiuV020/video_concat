import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../view_models/trim/trim_player_provider.dart';

/// 视频预览区域
class TrimPreview extends ConsumerWidget {
  final String videoId;
  final int currentPositionUs;
  final int? draggingPositionUs;
  final int durationUs;
  final bool isPreviewPending;

  const TrimPreview({
    super.key,
    required this.videoId,
    required this.currentPositionUs,
    this.draggingPositionUs,
    required this.durationUs,
    this.isPreviewPending = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(trimVideoControllerProvider(videoId));
    final isDragging = draggingPositionUs != null;
    final isAtEnd = currentPositionUs == durationUs;
    final endSuffix = isAtEnd ? ' (末尾)' : '';
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(
                controller: controller,
                controls: NoVideoControls,
              ),
              if (isPreviewPending)
                Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: isDragging
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '拖动: ${formatTimestampDisplay(draggingPositionUs!)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '关键帧: ${formatTimestampDisplay(currentPositionUs)}$endSuffix',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Text(
                  '当前: ${formatTimestampDisplay(currentPositionUs)}$endSuffix',
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ],
    );
  }
}
