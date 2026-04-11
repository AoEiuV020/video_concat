import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 裁剪进度条
class TrimSlider extends StatelessWidget {
  final int durationUs;
  final int currentPositionUs;
  final int? draggingPositionUs;
  final int inpointUs;
  final List<TrimSegment> segments;
  final bool isBusy;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const TrimSlider({
    super.key,
    required this.durationUs,
    required this.currentPositionUs,
    this.draggingPositionUs,
    required this.inpointUs,
    required this.segments,
    this.isBusy = false,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final max = durationUs.toDouble();
    if (max <= 0) return const SizedBox.shrink();

    final value =
        (draggingPositionUs ?? currentPositionUs).toDouble();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isBusy ? null : onPrevious,
              icon: const Icon(Icons.skip_previous),
              tooltip: '上一个关键帧',
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0, max),
                min: 0,
                max: max,
                onChanged: isBusy
                    ? null
                    : (v) => onChanged(v.round()),
                onChangeEnd: isBusy
                    ? null
                    : (v) => onChangeEnd(v.round()),
              ),
            ),
            IconButton(
              onPressed: isBusy ? null : onNext,
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
