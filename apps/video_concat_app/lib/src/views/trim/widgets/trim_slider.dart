import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 裁剪进度条
class TrimSlider extends StatefulWidget {
  final int durationUs;
  final int currentPositionUs;
  final int inpointUs;
  final List<TrimSegment> segments;
  final bool isSnapping;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const TrimSlider({
    super.key,
    required this.durationUs,
    required this.currentPositionUs,
    required this.inpointUs,
    required this.segments,
    this.isSnapping = false,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  State<TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<TrimSlider> {
  double? _draggingValue;

  @override
  void didUpdateWidget(TrimSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // isSnapping 结束 → 清除拖动状态，让 slider 用 currentPositionUs
    if (oldWidget.isSnapping && !widget.isSnapping) {
      setState(() => _draggingValue = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.durationUs.toDouble();
    if (max <= 0) return const SizedBox.shrink();

    final value = _draggingValue ?? widget.currentPositionUs.toDouble();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.isSnapping ? null : widget.onPrevious,
              icon: const Icon(Icons.skip_previous),
              tooltip: '上一个关键帧',
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0, max),
                min: 0,
                max: max,
                onChanged: (v) {
                  setState(() => _draggingValue = v);
                  widget.onChanged(v.round());
                },
                onChangeEnd: (v) {
                  // 不清除 _draggingValue，等 isSnapping 结束后由 didUpdateWidget 清除
                  widget.onChangeEnd(v.round());
                },
              ),
            ),
            IconButton(
              onPressed: widget.isSnapping ? null : widget.onNext,
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
              Text(formatTimestampDisplay(widget.durationUs)),
            ],
          ),
        ),
      ],
    );
  }
}
