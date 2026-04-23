part of 'trim_viewmodel.dart';

final class _TrimViewModelInit {
  _TrimViewModelInit(this.vm);

  final TrimViewModel vm;

  TrimState get state => vm.currentState;
  set state(TrimState value) => vm.currentState = value;

  Future<void> init() async {
    logger.d('_init 开始');

    final player = vm.player;
    logger.i('打开裁剪媒体 videoId=${state.videoId} filePath=${state.filePath}');
    await player.open(Media(state.filePath), play: false);
    if (vm.isDisposed) return;
    logger.i('打开裁剪媒体完成 videoId=${state.videoId}');

    setupPlayerListeners(player);

    await vm._ensureCovered(0);
    if (vm.isDisposed) return;
    final nearest = vm.cache.findNearest(0);

    logger.d(
      '_init nearest=$nearest '
      '缓存关键帧数=${vm.cache.keyframes.length}',
    );

    state = state.copyWith(isLoading: false, currentPositionUs: nearest ?? 0);

    if (nearest != null && nearest > 0) {
      await seekPlayer(nearest);
    }

    logger.d('_init 完成');
  }

  void setupPlayerListeners(Player player) {
    vm._positionSub = player.stream.position.listen((position) {
      vm._completePreviewPendingIfMatched(position.inMicroseconds);
      if (!vm.isDisposed &&
          state.isPlaying &&
          state.draggingPositionUs == null) {
        state = state.copyWith(currentPositionUs: position.inMicroseconds);
      }
    });

    vm._playingSub = player.stream.playing.listen((playing) {
      if (vm.isDisposed) return;
      if (state.isPlaying != playing) {
        logger.i('播放器播放状态变化 videoId=${state.videoId} playing=$playing');
        state = state.copyWith(isPlaying: playing);
      }
    });

    vm._errorSub = player.stream.error.listen((error) {
      if (vm.isDisposed) return;
      logger.e('播放器错误 videoId=${state.videoId}', error: error);
      state = state.copyWith(isPlaying: false, errorMessage: '播放器错误: $error');
    });

    vm._completedSub = player.stream.completed.listen((completed) {
      if (!vm.isDisposed && completed) {
        logger.i('播放到达末尾 videoId=${state.videoId}');
        state = state.copyWith(
          isPlaying: false,
          currentPositionUs: state.durationUs,
        );
      }
    });
  }

  Future<int> seekPlayer(int timestampUs) async {
    if (vm.isDisposed) return timestampUs;
    final player = vm.player;
    final actualTs = vm._resolvePlayerSeekTarget(timestampUs);

    logger.d('_seekPlayer timestampUs=$timestampUs actualTs=$actualTs');
    await player.seek(Duration(microseconds: actualTs));
    return actualTs;
  }
}
