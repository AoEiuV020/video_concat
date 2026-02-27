import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/home_state.dart';
import '../../view_models/home_viewmodel.dart';
import 'widgets/generate_output_panel.dart';
import 'widgets/output_config_bar.dart';
import 'widgets/video_list_tile.dart';

/// 主页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('视频合并'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isGenerating ? null : () => vm.reset(),
            tooltip: '新任务',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: DropTarget(
        onDragDone: (details) {
          final paths = details.files.map((f) => f.path).toList();
          vm.addVideos(paths);
        },
        child: Column(
          children: [
            Expanded(child: _buildVideoList(state, vm)),
            OutputConfigBar(state: state, vm: vm),
            _buildActionButtons(context, state, vm),
            if (state.generateResult != null)
              GenerateOutputPanel(result: state.generateResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(HomeState state, HomeViewModel vm) {
    if (state.videoItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('拖放视频文件到此处', style: TextStyle(color: Colors.grey)),
            Text('或点击下方按钮添加', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: state.videoItems.length,
      onReorder: (oldIndex, newIndex) {
        vm.reorderVideo(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final item = state.videoItems[index];
        final isOutOfOrder = index > 0 &&
            item.fileName.compareTo(
                  state.videoItems[index - 1].fileName,
                ) <
                0;
        return VideoListTile(
          key: ValueKey(item.id),
          item: item,
          index: index,
          onDelete: () => vm.removeVideo(item.id),
          isOutOfOrder: isOutOfOrder,
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    HomeState state,
    HomeViewModel vm,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.isGenerating ? null : () => _pickVideos(vm),
              icon: const Icon(Icons.add),
              label: const Text('添加视频'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: state.isGenerating || state.videoItems.isEmpty
                  ? null
                  : () => _startGenerate(context, state, vm),
              icon: state.isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.merge),
              label: Text(state.isGenerating ? '生成中...' : '开始合并'),
            ),
          ),
          if (state.isGenerating) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => vm.cancelGenerate(),
              icon: const Icon(Icons.stop),
              tooltip: '中断',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickVideos(HomeViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择视频文件',
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null) {
      final paths = result.files
          .where((f) => f.path != null)
          .map((f) => f.path!)
          .toList();
      vm.addVideos(paths);
    }
  }

  Future<void> _startGenerate(
    BuildContext context,
    HomeState state,
    HomeViewModel vm,
  ) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '保存合并视频',
      fileName: state.outputConfig.fullName,
    );

    if (outputPath != null) {
      vm.startGenerate(outputPath);
    }
  }
}
