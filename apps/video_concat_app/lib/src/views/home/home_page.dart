import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/home_state.dart';
import '../../view_models/home_viewmodel.dart';
import 'widgets/export_options_panel.dart';
import 'widgets/generate_output_panel.dart';
import 'widgets/output_config_bar.dart';
import 'widgets/video_list_tile.dart';

/// 主页
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToOutput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    ref.listen(
      homeViewModelProvider.select((s) => s.isGenerating),
      (prev, next) {
        if (next && !(prev ?? false)) _scrollToOutput();
      },
    );

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
            Expanded(child: _buildScrollArea(state, vm, context)),
            _buildOptionsSection(context, state, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollArea(
    HomeState state,
    HomeViewModel vm,
    BuildContext context,
  ) {
    if (state.videoItems.isEmpty && state.generateResult == null) {
      return _buildEmptyPlaceholder();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverReorderableList(
          itemCount: state.videoItems.length,
          onReorder: vm.reorderVideo,
          proxyDecorator: _proxyDecorator,
          itemBuilder: (context, index) =>
              _buildVideoItem(state, vm, context, index),
        ),
        if (state.generateResult != null)
          SliverToBoxAdapter(
            child: GenerateOutputPanel(result: state.generateResult!),
          ),
      ],
    );
  }

  static Widget _proxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final elevation =
            lerpDouble(0, 6, Curves.easeInOut.transform(animation.value))!;
        return Material(elevation: elevation, child: child);
      },
      child: child,
    );
  }

  Widget _buildEmptyPlaceholder() {
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

  Widget _buildVideoItem(
    HomeState state,
    HomeViewModel vm,
    BuildContext context,
    int index,
  ) {
    final item = state.videoItems[index];
    final isOutOfOrder = index > 0 &&
        item.fileName.compareTo(state.videoItems[index - 1].fileName) < 0;
    final isIncompatible = state.videoCompatibility[item.id] == false;
    final refPath = isIncompatible && state.videoItems.isNotEmpty
        ? state.videoItems.first.filePath
        : null;
    return VideoListTile(
      key: ValueKey(item.id),
      item: item,
      index: index,
      onDelete: () => vm.removeVideo(item.id),
      onTap: () {
        var uri =
            '/video-info?path=${Uri.encodeComponent(item.filePath)}';
        if (refPath != null) {
          uri += '&ref=${Uri.encodeComponent(refPath)}';
        }
        context.push(uri);
      },
      isOutOfOrder: isOutOfOrder,
      isIncompatible: isIncompatible,
    );
  }

  Widget _buildOptionsSection(
    BuildContext context,
    HomeState state,
    HomeViewModel vm,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        OutputConfigBar(state: state, vm: vm),
        ExportOptionsPanel(
          options: state.exportOptions,
          vm: vm,
          outputExtension: state.outputConfig.extension,
          isGenerating: state.isGenerating,
        ),
        _buildActionButtons(context, state, vm),
      ],
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
