part of 'trim_viewmodel.dart';

final class _TrimViewModelPlayback {
  _TrimViewModelPlayback(this.vm);

  final TrimViewModel vm;

  TrimState get state => vm.currentState;
  set state(TrimState value) => vm.currentState = value;

  Future<void> togglePlayPause() async {
    final player = vm.player;

    if (state.isPlaying) {
      logger.i('请求暂停裁剪播放器 videoId=${state.videoId}');
      await player.pause();
      state = state.copyWith(isPlaying: false);

      final pos = player.state.position.inMicroseconds;
      state = state.copyWith(isSnapping: true);

      await vm._ensureCovered(pos);
      if (vm.isDisposed) return;
      final target = vm._resolveSnapTarget(pos);

      if (target != null) {
        state = state.copyWith(isSnapping: false);
        await vm._syncResolvedPosition(target);
      } else {
        state = state.copyWith(isSnapping: false);
      }
    } else {
      logger.i('请求播放裁剪播放器 videoId=${state.videoId}');
      vm._clearPreviewPending();
      if (state.currentPositionUs >= state.durationUs) {
        await player.seek(Duration.zero);
        state = state.copyWith(currentPositionUs: 0);
      }
      await player.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> onSliderReleased(int positionUs) async {
    logger.d('onSliderReleased positionUs=$positionUs');
    final gen = ++vm.snapGeneration;

    final needsLoading = !vm.cache.isCovered(positionUs);
    state = state.copyWith(
      currentPositionUs: positionUs,
      isSnapping: needsLoading,
    );

    await vm._ensureCovered(positionUs);
    if (vm.isDisposed || gen != vm.snapGeneration) return;
    final target = vm._resolveSnapTarget(positionUs);

    logger.d('onSliderReleased target=$target needsLoading=$needsLoading');

    if (target == null) {
      state = state.copyWith(isSnapping: false, draggingPositionUs: null);
      return;
    }

    state = state.copyWith(isSnapping: false);
    await vm._syncResolvedPosition(target);
  }

  void onSliderDragging(int positionUs) {
    vm.snapGeneration++;
    vm._clearPreviewPending();
    state = state.copyWith(draggingPositionUs: positionUs, isSnapping: false);

    if (state.isPlaying) {
      vm.player.pause();
      state = state.copyWith(isPlaying: false);
    }

    vm.player.seek(Duration(microseconds: positionUs));

    vm.debounceTimer?.cancel();
    vm.debounceTimer = Timer(const Duration(milliseconds: 100), () {
      onDragDebounced(positionUs);
    });
  }

  Future<void> onDragDebounced(int positionUs) async {
    logger.d('_onDragDebounced positionUs=$positionUs');
    await vm._ensureCovered(positionUs);
    if (vm.isDisposed) return;
    final target = vm._resolveSnapTarget(positionUs);
    if (target != null) {
      state = state.copyWith(currentPositionUs: target);
    }
  }
}
