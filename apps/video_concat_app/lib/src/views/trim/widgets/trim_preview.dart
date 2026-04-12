import 'dart:typed_data';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 关键帧预览区域
class TrimPreview extends StatelessWidget {
  final Uint8List? previewImage;
  final bool isLoading;
  final int currentPositionUs;
  final int? draggingPositionUs;
  final int durationUs;

  const TrimPreview({
    super.key,
    this.previewImage,
    required this.isLoading,
    required this.currentPositionUs,
    this.draggingPositionUs,
    required this.durationUs,
  });

  @override
  Widget build(BuildContext context) {
    final isDragging = draggingPositionUs != null;
    final isAtEnd = currentPositionUs == durationUs;
    final endSuffix = isAtEnd ? ' (末尾)' : '';
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (previewImage != null)
                Image.memory(
                  previewImage!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                )
              else
                const Icon(Icons.image, size: 64, color: Colors.grey),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
