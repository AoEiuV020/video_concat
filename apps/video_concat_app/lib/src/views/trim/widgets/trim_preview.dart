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
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : previewImage != null
                    ? Image.memory(
                        previewImage!,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      )
                    : const Icon(Icons.image, size: 64, color: Colors.grey),
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
