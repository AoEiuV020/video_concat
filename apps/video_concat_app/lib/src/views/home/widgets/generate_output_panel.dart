import 'package:flutter/material.dart';

import '../../../models/models.dart';

/// 生成输出面板
class GenerateOutputPanel extends StatelessWidget {
  final GenerateResult result;

  const GenerateOutputPanel({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    IconData icon;

    switch (result.state) {
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
                Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          if (result.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                result.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Text(
                result.output,
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
    switch (result.state) {
      case GenerateState.running:
        return '正在合并...';
      case GenerateState.success:
        return '合并完成';
      case GenerateState.failed:
        return '合并失败';
      case GenerateState.idle:
        return '输出';
    }
  }
}
