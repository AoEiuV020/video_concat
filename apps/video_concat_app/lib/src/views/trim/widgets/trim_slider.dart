import 'package:flutter/material.dart';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';

/// 裁剪进度条
class TrimSlider extends StatelessWidget {
  final int durationUs;
  final int currentPositionUs;
  final int? draggingPositionUs;
  final int inpointUs;
  final List<TrimSegment> segments;
  final bool isButtonsDisabled;
  final bool isPlaying;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTogglePlayPause;

  const TrimSlider({
    super.key,
    required this.durationUs,
    required this.currentPositionUs,
    this.draggingPositionUs,
    required this.inpointUs,
    required this.segments,
    this.isButtonsDisabled = false,
    this.isPlaying = false,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onPrevious,
    required this.onNext,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final max = durationUs.toDouble();
    if (max <= 0) return const SizedBox.shrink();

    final value = (draggingPositionUs ?? currentPositionUs).toDouble();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isButtonsDisabled ? null : onPrevious,
              icon: const Icon(Icons.skip_previous),
              tooltip: '上一个关键帧',
            ),
            IconButton(
              onPressed: onTogglePlayPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              tooltip: isPlaying ? '暂停' : '播放',
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0, max),
                min: 0,
                max: max,
                onChanged: (v) => onChanged(v.round()),
                onChangeEnd: (v) => onChangeEnd(v.round()),
              ),
            ),
            IconButton(
              onPressed: isButtonsDisabled ? null : onNext,
              icon: const Icon(Icons.skip_next),
              tooltip: '下一个关键帧',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTimestampDisplay(0)),
              Text(formatTimestampDisplay(durationUs)),
            ],
          ),
        ),
      ],
    );
  }
}
