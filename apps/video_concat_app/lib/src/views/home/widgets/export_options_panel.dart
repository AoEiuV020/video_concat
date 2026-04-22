import 'package:flutter/material.dart';

import '../../../models/export_options.dart';
import '../../../view_models/home/home_viewmodel.dart';

/// 导出选项展开面板
class ExportOptionsPanel extends StatelessWidget {
  final ExportOptions options;
  final HomeViewModel vm;
  final String outputExtension;
  final bool isGenerating;

  const ExportOptionsPanel({
    super.key,
    required this.options,
    required this.vm,
    required this.outputExtension,
    required this.isGenerating,
  });

  static const _rotations = <int?>[null, 0, 90, 180, 270];

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: options.showOptions
          ? _buildPanel(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildRotationSelector(context),
          const SizedBox(height: 8),
          _buildOptionCheckboxes(context),
          _buildRememberRow(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildRotationSelector(BuildContext context) {
    return Row(
      children: [
        Text('旋转: ', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 8),
        SegmentedButton<int?>(
          showSelectedIcon: false,
          segments: _rotations
              .map(
                (r) => ButtonSegment(
                  value: r,
                  label: Text(r == null ? '不设置' : '$r°'),
                ),
              )
              .toList(),
          selected: {options.rotation},
          onSelectionChanged: isGenerating
              ? null
              : (selected) {
                  vm.updateExportOptions(
                    options.copyWith(rotation: selected.first),
                  );
                },
        ),
      ],
    );
  }

  Widget _buildOptionCheckboxes(BuildContext context) {
    final isMp4Like = outputExtension == 'mp4' || outputExtension == 'mov';

    final items = [
      _CheckboxItem(
        label: '去除音频',
        value: options.removeAudio,
        onChanged: (v) =>
            vm.updateExportOptions(options.copyWith(removeAudio: v ?? false)),
      ),
      _CheckboxItem(
        label: '去除字幕',
        value: options.removeSubtitles,
        onChanged: (v) => vm.updateExportOptions(
          options.copyWith(removeSubtitles: v ?? false),
        ),
      ),
      _CheckboxItem(
        label: '快速启动(mp4)',
        value: options.fastStart,
        enabled: isMp4Like,
        tooltip: isMp4Like ? null : '仅支持 mp4/mov 格式',
        onChanged: (v) =>
            vm.updateExportOptions(options.copyWith(fastStart: v ?? false)),
      ),
      _CheckboxItem(
        label: '清除元数据',
        value: options.stripMetadata,
        onChanged: (v) =>
            vm.updateExportOptions(options.copyWith(stripMetadata: v ?? false)),
      ),
      _CheckboxItem(
        label: '拼接点章节',
        value: options.addChapters,
        onChanged: (v) =>
            vm.updateExportOptions(options.copyWith(addChapters: v ?? false)),
      ),
      _CheckboxItem(
        label: '按目标时长分段',
        value: options.enableSegmentOutput,
        onChanged: (v) => vm.updateExportOptions(
          options.copyWith(enableSegmentOutput: v ?? false),
        ),
      ),
      _CheckboxItem(
        label: '按裁剪分段',
        value: options.enableCustomSplit,
        onChanged: (v) => vm.updateExportOptions(
          options.copyWith(enableCustomSplit: v ?? false),
        ),
      ),
      _CheckboxItem(
        label: '自动打开信息页',
        value: options.autoOpenVideoInfo,
        onChanged: (v) => vm.updateExportOptions(
          options.copyWith(autoOpenVideoInfo: v ?? false),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: items.map((item) => _buildCheckboxTile(item)).toList(),
        ),
        if (options.enableSegmentOutput) ...[
          const SizedBox(height: 8),
          _buildSegmentTextField(
            key: const ValueKey('segment-duration'),
            label: '分段时长',
            initialValue: options.segmentDurationText,
            onChanged: (value) => vm.updateExportOptions(
              options.copyWith(segmentDurationText: value),
            ),
          ),
          const SizedBox(height: 8),
          _buildSegmentTextField(
            key: const ValueKey('segment-template-by-duration'),
            label: '文件名模板',
            initialValue: options.segmentFilenameTemplate,
            onChanged: (value) => vm.updateExportOptions(
              options.copyWith(segmentFilenameTemplate: value),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '切点按关键帧对齐，时长可能略有偏差。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (options.enableCustomSplit) ...[
          const SizedBox(height: 8),
          _buildSegmentTextField(
            key: const ValueKey('segment-template-by-trim'),
            label: '文件名模板',
            initialValue: options.segmentFilenameTemplate,
            onChanged: (value) => vm.updateExportOptions(
              options.copyWith(segmentFilenameTemplate: value),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trim 片段将分别生成视频文件。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildSegmentTextField({
    Key? key,
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      key: key,
      width: 280,
      child: TextFormField(
        initialValue: initialValue,
        enabled: !isGenerating,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'HH:MM:SS.mmm',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(_CheckboxItem item) {
    final enabled = !isGenerating && item.enabled;
    final checkbox = SizedBox(
      width: 180,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: item.value,
            onChanged: enabled ? item.onChanged : null,
          ),
          Expanded(
            child: GestureDetector(
              onTap: enabled ? () => item.onChanged(!item.value) : null,
              child: Text(
                item.label,
                style: TextStyle(color: enabled ? null : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );

    if (item.tooltip != null && !item.enabled) {
      return Tooltip(message: item.tooltip!, child: checkbox);
    }
    return checkbox;
  }

  Widget _buildRememberRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: options.rememberChoices,
              onChanged: isGenerating
                  ? null
                  : (v) => vm.updateExportOptions(
                      options.copyWith(rememberChoices: v ?? false),
                    ),
            ),
            GestureDetector(
              onTap: isGenerating
                  ? null
                  : () => vm.updateExportOptions(
                      options.copyWith(
                        rememberChoices: !options.rememberChoices,
                      ),
                    ),
              child: const Text('记住选择'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxItem {
  final String label;
  final bool value;
  final bool enabled;
  final String? tooltip;
  final ValueChanged<bool?> onChanged;

  const _CheckboxItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.tooltip,
  });
}
