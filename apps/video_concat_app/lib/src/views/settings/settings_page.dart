import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/settings/settings_viewmodel.dart';

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _ffmpegController;
  late final TextEditingController _ffprobeController;

  @override
  void initState() {
    super.initState();
    _ffmpegController = TextEditingController();
    _ffprobeController = TextEditingController();
  }

  @override
  void dispose() {
    _ffmpegController.dispose();
    _ffprobeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    if (_ffmpegController.text != state.settings.ffmpegPath) {
      _ffmpegController.value = TextEditingValue(
        text: state.settings.ffmpegPath,
        selection: TextSelection.collapsed(
          offset: state.settings.ffmpegPath.length,
        ),
      );
    }
    if (_ffprobeController.text != state.settings.ffprobePath) {
      _ffprobeController.value = TextEditingValue(
        text: state.settings.ffprobePath,
        selection: TextSelection.collapsed(
          offset: state.settings.ffprobePath.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: state.isValidating
                ? null
                : () => vm.refreshByInputs(
                    ffmpegPath: _ffmpegController.text.trim(),
                    ffprobePath: _ffprobeController.text.trim(),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolCard(
            title: 'FFmpeg 路径',
            isValidating: state.isValidating,
            isValid: state.isFFmpegValid,
            version: state.ffmpegVersion,
            controller: _ffmpegController,
            onSubmitted: vm.updateFFmpegPath,
            onBrowse: vm.browseFFmpegPath,
            hintText: 'ffmpeg',
          ),
          const SizedBox(height: 12),
          _ToolCard(
            title: 'FFprobe 路径',
            isValidating: state.isValidating,
            isValid: state.isFFprobeValid,
            version: state.ffprobeVersion,
            controller: _ffprobeController,
            onSubmitted: vm.updateFFprobePath,
            onBrowse: vm.browseFFprobePath,
            hintText: 'ffprobe',
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final bool isValidating;
  final bool isValid;
  final String? version;
  final TextEditingController controller;
  final Future<void> Function(String) onSubmitted;
  final Future<void> Function() onBrowse;
  final String hintText;

  const _ToolCard({
    required this.title,
    required this.isValidating,
    required this.isValid,
    required this.version,
    required this.controller,
    required this.onSubmitted,
    required this.onBrowse,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (isValidating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isValid)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.error, color: Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onFieldSubmitted: onSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: onBrowse,
                  tooltip: '浏览',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isValidating
                  ? '正在检查...'
                  : isValid
                  ? '可用${version == null ? "" : "，版本：$version"}'
                  : '$title 不可用，请检查路径',
              style: TextStyle(
                color: isValidating
                    ? Colors.grey
                    : isValid
                    ? Colors.green
                    : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
