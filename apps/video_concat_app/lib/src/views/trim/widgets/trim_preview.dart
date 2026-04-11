import 'dart:typed_data';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 关键帧预览区域
class TrimPreview extends StatelessWidget {
  final Uint8List? previewImage;
  final bool isLoading;
  final int currentPositionUs;

  const TrimPreview({
    super.key,
    this.previewImage,
    required this.isLoading,
    required this.currentPositionUs,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            '当前: ${formatTimestampDisplay(currentPositionUs)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
