import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/trim_viewmodel.dart';
import 'widgets/segment_list.dart';
import 'widgets/trim_preview.dart';
import 'widgets/trim_slider.dart';

/// 裁剪页面
class TrimPage extends ConsumerWidget {
  final String videoId;
  const TrimPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trimViewModelProvider(videoId));
    final vm = ref.read(trimViewModelProvider(videoId).notifier);
    final isBusy = state.isSnapping || state.isLoadingPreview;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            onPressed: () {
              vm.confirm();
              context.pop();
            },
            child: const Text('确认'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 预览区
                TrimPreview(
                  previewImage: state.previewImage,
                  isLoading: state.isLoadingPreview,
                  currentPositionUs: state.currentPositionUs,
                  draggingPositionUs: state.draggingPositionUs,
                  durationUs: state.durationUs,
                ),
                const Divider(height: 1),
                // 进度条 + 按钮
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TrimSlider(
                    durationUs: state.durationUs,
                    currentPositionUs: state.currentPositionUs,
                    draggingPositionUs: state.draggingPositionUs,
                    inpointUs: state.pendingInpointUs ?? 0,
                    segments: state.segments,
                    isSnapping: state.isSnapping,
                    isButtonsDisabled: isBusy,
                    onChanged: (us) => vm.onSliderDragging(us),
                    onChangeEnd: (us) => vm.onSliderReleased(us),
                    onPrevious: () => vm.goToPreviousKeyframe(),
                    onNext: () => vm.goToNextKeyframe(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isBusy
                              ? null
                              : () => vm.setInpoint(),
                          icon: const Icon(Icons.skip_previous),
                          label: const Text('设为 inpoint'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isBusy
                              ? null
                              : () {
                                  final error = vm.setOutpoint();
                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.skip_next),
                          label: const Text('设为 outpoint'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // 片段列表
                Expanded(
                  child: SegmentList(
                    segments: state.segments,
                    pendingInpointUs: state.pendingInpointUs,
                    onDelete: (index) => vm.removeSegment(index),
                    onDeletePending: () => vm.removePendingInpoint(),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
    );
  }
}
