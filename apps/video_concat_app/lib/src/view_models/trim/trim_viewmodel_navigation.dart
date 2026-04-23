part of 'trim_viewmodel.dart';

final class _TrimViewModelNavigation {
  _TrimViewModelNavigation(this.vm);

  final TrimViewModel vm;

  TrimState get state => vm.currentState;
  set state(TrimState value) => vm.currentState = value;

  Future<void> goToPreviousKeyframe() async {
    final current = state.currentPositionUs;
    logger.d('goToPreviousKeyframe current=$current');
    final gen = ++vm.snapGeneration;

    if (current == state.durationUs) {
      final lastKf = vm.cache.findNearest(state.durationUs);
      logger.d('goToPreviousKeyframe 从虚拟末尾 → lastKf=$lastKf');
      if (lastKf != null) {
        await vm._syncResolvedPosition(lastKf);
      }
      return;
    }

    if (vm.cache.isCovered(current)) {
      final prev = vm.cache.findPrevious(current);
      if (prev != null && vm.cache.isCoveredRange(prev, current)) {
        logger.d('goToPreviousKeyframe 缓存命中 prev=$prev');
        await vm._syncResolvedPosition(prev);
        return;
      }
    }

    state = state.copyWith(isSnapping: true);

    await ensureCovered(current);
    if (vm.isDisposed || gen != vm.snapGeneration) return;
    var prev = vm.cache.findPrevious(current);

    if (prev == null || !vm.cache.isCoveredRange(prev, current)) {
      final rangeStart = vm.cache.coveredRangeStart(current);
      if (rangeStart != null && rangeStart > 0) {
        logger.d('goToPreviousKeyframe 向后探测 rangeStart=$rangeStart');
        await ensureCovered(rangeStart - 1);
        if (vm.isDisposed || gen != vm.snapGeneration) return;
        prev = vm.cache.findPrevious(current);
      }
    }

    logger.d('goToPreviousKeyframe prev=$prev');
    if (prev != null) {
      state = state.copyWith(isSnapping: false);
      await vm._syncResolvedPosition(prev);
    } else {
      state = state.copyWith(isSnapping: false, draggingPositionUs: null);
    }
  }

  Future<void> goToNextKeyframe() async {
    final current = state.currentPositionUs;
    logger.d('goToNextKeyframe current=$current');

    if (current == state.durationUs) {
      logger.d('goToNextKeyframe 已在虚拟末尾');
      return;
    }

    final gen = ++vm.snapGeneration;

    if (vm.cache.isCovered(current)) {
      final next = vm.cache.findNext(current);
      if (next != null && vm.cache.isCoveredRange(current, next)) {
        logger.d('goToNextKeyframe 缓存命中 next=$next');
        await vm._syncResolvedPosition(next);
        return;
      }
      if (next == null) {
        final rangeEnd = vm.cache.coveredRangeEnd(current);
        if (rangeEnd != null && rangeEnd >= state.durationUs) {
          logger.d('goToNextKeyframe 缓存命中 → 虚拟末尾');
          await vm._syncResolvedPosition(state.durationUs);
          return;
        }
      }
    }

    state = state.copyWith(isSnapping: true);

    await ensureCovered(current);
    if (vm.isDisposed || gen != vm.snapGeneration) return;
    var next = vm.cache.findNext(current);

    if (next == null || !vm.cache.isCoveredRange(current, next)) {
      final rangeEnd = vm.cache.coveredRangeEnd(current);
      if (rangeEnd != null && rangeEnd < state.durationUs) {
        logger.d('goToNextKeyframe 向前探测 rangeEnd=$rangeEnd');
        await ensureCovered(rangeEnd + 1);
        if (vm.isDisposed || gen != vm.snapGeneration) return;
        next = vm.cache.findNext(current);
      }
    }

    if (next == null) {
      logger.d('goToNextKeyframe 无后继 → 虚拟末尾');
      state = state.copyWith(isSnapping: false);
      await vm._syncResolvedPosition(state.durationUs);
      return;
    }

    logger.d('goToNextKeyframe next=$next');
    state = state.copyWith(isSnapping: false);
    await vm._syncResolvedPosition(next);
  }

  int? resolveSnapTarget(int positionUs) {
    final nearest = vm.cache.findNearest(positionUs);
    if (nearest == null) return null;

    if (positionUs > nearest && vm.cache.findNext(nearest) == null) {
      final distToKf = positionUs - nearest;
      final distToEnd = state.durationUs - positionUs;
      if (distToEnd <= distToKf) {
        logger.d(
          '_resolveSnapTarget → 虚拟末尾 '
          '(nearest=$nearest distToKf=$distToKf distToEnd=$distToEnd)',
        );
        return state.durationUs;
      }
    }

    return nearest;
  }

  Future<void> ensureCovered(int targetUs) async {
    if (vm.cache.isCovered(targetUs)) {
      logger.d('_ensureCovered targetUs=$targetUs 已缓存');
      return;
    }

    var windowUs = TrimViewModel._defaultWindowUs;
    for (var retry = 0; retry < TrimViewModel._maxRetries; retry++) {
      final startUs = (targetUs - windowUs).clamp(0, state.durationUs);
      final endUs = (targetUs + windowUs).clamp(0, state.durationUs);

      logger.d(
        '_ensureCovered retry=$retry '
        'window=[$startUs, $endUs]',
      );

      try {
        final ffprobe = getFfprobeService();
        logger.d('ffprobe路径=${ffprobe.ffprobePath}');

        final keyframes = await ffprobe.findKeyframes(
          state.filePath,
          startUs: startUs,
          endUs: endUs,
        );

        logger.d(
          'findKeyframes 返回 ${keyframes.length} 个关键帧'
          '${keyframes.isNotEmpty ? ": ${keyframes.take(5).map((k) => k.ptsUs)}" : ""}',
        );

        vm.cache.addRange(startUs, endUs, keyframes);

        if (keyframes.isNotEmpty) return;
      } catch (e) {
        logger.e('_ensureCovered 异常', error: e);
        state = state.copyWith(errorMessage: '关键帧探测失败: $e');
        return;
      }

      windowUs = (windowUs * 2).clamp(0, TrimViewModel._maxWindowUs);
    }
    logger.w('_ensureCovered ${TrimViewModel._maxRetries}次重试后仍无关键帧');
  }

  FFprobeService getFfprobeService() {
    final ffprobe = vm.currentFfprobeService;
    final ffmpeg = vm.currentFfmpegService;
    if (ffprobe.ffprobePath.trim().isEmpty ||
        ffprobe.ffprobePath == 'ffprobe') {
      ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    }
    return ffprobe;
  }

  int resolvePlayerSeekTarget(int timestampUs) {
    if (timestampUs == state.durationUs) {
      return vm.cache.findNearest(state.durationUs) ?? timestampUs;
    }
    return timestampUs;
  }
}
