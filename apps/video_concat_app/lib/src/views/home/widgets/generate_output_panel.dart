import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/models.dart';

/// 生成输出面板
class GenerateOutputPanel extends StatefulWidget {
  final GenerateResult result;
  final GeneratedVideoInfo? generatedVideo;
  final SegmentedOutputSummary? segmentedOutputSummary;
  final VoidCallback? onOpenVideoInfo;

  const GenerateOutputPanel({
    super.key,
    required this.result,
    this.generatedVideo,
    this.segmentedOutputSummary,
    this.onOpenVideoInfo,
  });

  @override
  State<GenerateOutputPanel> createState() => _GenerateOutputPanelState();
}

class _GenerateOutputPanelState extends State<GenerateOutputPanel> {
  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void didUpdateWidget(GenerateOutputPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result.state != oldWidget.result.state) {
      if (widget.result.state == GenerateState.running) {
        _startTime = DateTime.now();
        _startTimer();
      } else {
        _stopTimer();
        if (widget.result.elapsedDuration != null) {
          _elapsedTime = widget.result.elapsedDuration!;
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    IconData icon;

    switch (widget.result.state) {
      case GenerateState.running:
        backgroundColor = colorScheme.primaryContainer;
        icon = Icons.hourglass_empty;
        break;
      case GenerateState.success:
        backgroundColor = colorScheme.tertiaryContainer;
        icon = Icons.check_circle;
        break;
      case GenerateState.failed:
        backgroundColor = colorScheme.errorContainer;
        icon = Icons.error;
        break;
      case GenerateState.cancelled:
        backgroundColor = colorScheme.surfaceContainerHighest;
        icon = Icons.cancel;
        break;
      case GenerateState.idle:
        backgroundColor = colorScheme.surfaceContainerHighest;
        icon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (widget.result.state == GenerateState.running ||
                          widget.result.elapsedDuration != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '耗时：${_formatDuration(_elapsedTime)}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.result.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.result.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          if (widget.result.state == GenerateState.success &&
              widget.segmentedOutputSummary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分段输出',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.segmentedOutputSummary!.directoryPath),
                      const SizedBox(height: 2),
                      Text(widget.segmentedOutputSummary!.fileNamePattern),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.result.state == GenerateState.success &&
              widget.segmentedOutputSummary == null &&
              widget.generatedVideo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '合并结果',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(widget.generatedVideo!.fileName),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onOpenVideoInfo,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('查看信息'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                widget.result.output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.result.state) {
      case GenerateState.running:
        return '正在合并...';
      case GenerateState.success:
        return '合并完成';
      case GenerateState.failed:
        return '合并失败';
      case GenerateState.cancelled:
        return '已取消';
      case GenerateState.idle:
        return '输出';
    }
  }
}
