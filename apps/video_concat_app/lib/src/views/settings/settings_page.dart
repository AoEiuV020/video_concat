import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/settings_viewmodel.dart';

/// 设置页
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal),
                      const SizedBox(width: 8),
                      Text(
                        'FFmpeg 路径',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (state.isValidating)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (state.isFFmpegValid)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        const Icon(Icons.error, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: state.settings.ffmpegPath,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'ffmpeg',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: vm.updateFFmpegPath,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.folder_open),
                        onPressed: vm.browseFFmpegPath,
                        tooltip: '浏览',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isFFmpegValid
                        ? 'FFmpeg 可用'
                        : 'FFmpeg 不可用，请检查路径',
                    style: TextStyle(
                      color: state.isFFmpegValid ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
