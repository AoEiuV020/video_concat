import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';

/// 裁剪进度条
class TrimSlider extends StatefulWidget {
  final int durationUs;
  final int currentPositionUs;
  final int inpointUs;
  final List<TrimSegment> segments;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;

  const TrimSlider({
    super.key,
    required this.durationUs,
    required this.currentPositionUs,
    required this.inpointUs,
    required this.segments,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<TrimSlider> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final max = widget.durationUs.toDouble();
    if (max <= 0) return const SizedBox.shrink();

    final value = _draggingValue ?? widget.currentPositionUs.toDouble();

    return Column(
      children: [
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: max,
          onChanged: (v) {
            setState(() => _draggingValue = v);
            widget.onChanged(v.round());
          },
          onChangeEnd: (v) {
            setState(() => _draggingValue = null);
            widget.onChangeEnd(v.round());
          },
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
