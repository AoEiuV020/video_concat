import 'package:flutter/material.dart';

import '../../../utils/format_utils.dart';
import '../../../view_models/home_state.dart';
import '../../../view_models/home_viewmodel.dart';

/// 输出配置栏
class OutputConfigBar extends StatelessWidget {
  final HomeState state;
  final HomeViewModel vm;

  const OutputConfigBar({
    super.key,
    required this.state,
    required this.vm,
  });

  static const _extensions = ['mp4', 'mkv', 'avi', 'mov', 'webm'];

  @override
  Widget build(BuildContext context) {
    final totalSize =
        state.videoItems.fold<int>(0, (sum, item) => sum + item.fileSize);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('输出: '),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text: state.outputConfig.baseName,
              )..selection = TextSelection.fromPosition(
                  TextPosition(offset: state.outputConfig.baseName.length),
                ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: '文件名',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: vm.updateOutputBaseName,
              enabled: !state.isGenerating,
            ),
          ),
          const SizedBox(width: 8),
          const Text('.'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: state.outputConfig.extension,
            items: _extensions
                .map((ext) => DropdownMenuItem(value: ext, child: Text(ext)))
                .toList(),
            onChanged: state.isGenerating
                ? null
                : (value) {
                    if (value != null) {
                      vm.updateOutputExtension(value);
                    }
                  },
          ),
          if (state.videoItems.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text(
              '≈ ${formatFileSize(totalSize)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
