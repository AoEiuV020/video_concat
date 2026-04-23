import 'dart:async';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../utils/keyframe_cache.dart';
import '../home/home_viewmodel.dart';
import '../providers.dart';
import 'trim_segment_editor.dart';
import 'trim_player_provider.dart';
import 'trim_state.dart';

part 'trim_viewmodel.g.dart';

/// 裁剪页面 ViewModel
@riverpod
class TrimViewModel extends _$TrimViewModel {
  static const _defaultWindowUs = 10000000;
  static const _maxWindowUs = 30000000;
  static const _maxRetries = 3;
  static const _previewMatchToleranceUs = 100000;
  static const _previewPendingTimeout = Duration(seconds: 2);

  late KeyframeCache _cache;
  Timer? _debounceTimer;
  Timer? _previewPendingTimer;
  bool _disposed = false;
  int _snapGeneration = 0;
  int _previewRequestId = 0;
  int? _activePreviewRequestId;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<bool>? _completedSub;

  @override
  TrimState build(String videoId) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
      _previewPendingTimer?.cancel();
      _positionSub?.cancel();
      _playingSub?.cancel();
      _errorSub?.cancel();
      _completedSub?.cancel();
    });

    final homeState = ref.read(homeViewModelProvider);
    final item = homeState.videoItems.firstWhere((v) => v.id == videoId);

    final durationUs = item.durationUs ?? 0;
    _cache = KeyframeCache(durationUs: durationUs);

    // 加载已有的裁剪配置
    final existingSegments = item.trimConfig?.segments ?? [];

    logger.d(
      'build videoId=$videoId durationUs=$durationUs '
      'filePath=${item.filePath} segments=${existingSegments.length}',
    );

    // 异步初始化
    if (durationUs > 0) {
      Future.microtask(() async {
        try {
          await _init();
        } catch (e, s) {
          logger.e('_init 未捕获异常', error: e, stackTrace: s);
          state = state.copyWith(isLoading: false, errorMessage: '初始化失败: $e');
        }
      });
    } else {
      logger.w('durationUs=0, 跳过初始化');
    }

    return TrimState(
      videoId: videoId,
      filePath: item.filePath,
      fileName: item.fileName,
      durationUs: durationUs,
      segments: existingSegments,
      isLoading: durationUs > 0,
      pendingInpointUs: existingSegments.isEmpty ? 0 : null,
    );
  }

  Future<void> _init() async {
    logger.d('_init 开始');

    // 在 Player 中打开视频（暂停状态）
    final player = ref.read(trimPlayerProvider(state.videoId));
    logger.i('打开裁剪媒体 videoId=${state.videoId} filePath=${state.filePath}');
    await player.open(Media(state.filePath), play: false);
    if (_disposed) return;
    logger.i('打开裁剪媒体完成 videoId=${state.videoId}');

    // 设置播放器流监听
    _setupPlayerListeners(player);

    // 加载初始位置附近的关键帧
    await _ensureCovered(0);
    if (_disposed) return;
    final nearest = _cache.findNearest(0);

    logger.d(
      '_init nearest=$nearest '
      '缓存关键帧数=${_cache.keyframes.length}',
    );

    state = state.copyWith(isLoading: false, currentPositionUs: nearest ?? 0);

    // 跳到首个关键帧
    if (nearest != null && nearest > 0) {
      await _seekPlayer(nearest);
    }

    logger.d('_init 完成');
  }

  void _setupPlayerListeners(Player player) {
    // 播放中持续同步滑块位置
    _positionSub = player.stream.position.listen((position) {
      _completePreviewPendingIfMatched(position.inMicroseconds);
      if (!_disposed && state.isPlaying && state.draggingPositionUs == null) {
        state = state.copyWith(currentPositionUs: position.inMicroseconds);
      }
    });

    _playingSub = player.stream.playing.listen((playing) {
      if (_disposed) return;
      if (state.isPlaying != playing) {
        logger.i('播放器播放状态变化 videoId=${state.videoId} playing=$playing');
        state = state.copyWith(isPlaying: playing);
      }
    });

    _errorSub = player.stream.error.listen((error) {
      if (_disposed) return;
      logger.e('播放器错误 videoId=${state.videoId}', error: error);
      state = state.copyWith(isPlaying: false, errorMessage: '播放器错误: $error');
    });

    // 播放结束时停在虚拟末尾
    _completedSub = player.stream.completed.listen((completed) {
      if (!_disposed && completed) {
        logger.i('播放到达末尾 videoId=${state.videoId}');
        state = state.copyWith(
          isPlaying: false,
          currentPositionUs: state.durationUs,
        );
      }
    });
  }

  /// 跳转播放器到指定时间点
  Future<int> _seekPlayer(int timestampUs) async {
    if (_disposed) return timestampUs;
    final player = ref.read(trimPlayerProvider(state.videoId));
    final actualTs = _resolvePlayerSeekTarget(timestampUs);

    logger.d('_seekPlayer timestampUs=$timestampUs actualTs=$actualTs');
    await player.seek(Duration(microseconds: actualTs));
    return actualTs;
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    final player = ref.read(trimPlayerProvider(state.videoId));

    if (state.isPlaying) {
      logger.i('请求暂停裁剪播放器 videoId=${state.videoId}');
      // 暂停 → 吸附到最近关键帧
      await player.pause();
      state = state.copyWith(isPlaying: false);

      final pos = player.state.position.inMicroseconds;
      state = state.copyWith(isSnapping: true);

      await _ensureCovered(pos);
      if (_disposed) return;
      final target = _resolveSnapTarget(pos);

      if (target != null) {
        state = state.copyWith(isSnapping: false);
        await _syncResolvedPosition(target);
      } else {
        state = state.copyWith(isSnapping: false);
      }
    } else {
      logger.i('请求播放裁剪播放器 videoId=${state.videoId}');
      _clearPreviewPending();
      // 在末尾时从头播放
      if (state.currentPositionUs >= state.durationUs) {
        await player.seek(Duration.zero);
        state = state.copyWith(currentPositionUs: 0);
      }
      await player.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// 滑块松开时调用
  Future<void> onSliderReleased(int positionUs) async {
    logger.d('onSliderReleased positionUs=$positionUs');
    final gen = ++_snapGeneration;

    // 立即更新到松手位置（不跳回旧位置）
    final needsLoading = !_cache.isCovered(positionUs);
    state = state.copyWith(
      currentPositionUs: positionUs,
      isSnapping: needsLoading,
    );

    await _ensureCovered(positionUs);
    if (_disposed || gen != _snapGeneration) return;
    final target = _resolveSnapTarget(positionUs);

    logger.d('onSliderReleased target=$target needsLoading=$needsLoading');

    if (target == null) {
      state = state.copyWith(isSnapping: false, draggingPositionUs: null);
      return;
    }

    // 吸附完成，跳到关键帧或虚拟末尾
    state = state.copyWith(isSnapping: false);
    await _syncResolvedPosition(target);
  }

  /// 拖动中调用，即时跳转播放器 + 100ms 防抖触发关键帧信息更新
  void onSliderDragging(int positionUs) {
    _snapGeneration++;
    _clearPreviewPending();
    state = state.copyWith(draggingPositionUs: positionUs, isSnapping: false);

    // 拖动时暂停播放
    if (state.isPlaying) {
      ref.read(trimPlayerProvider(state.videoId)).pause();
      state = state.copyWith(isPlaying: false);
    }

    // 即时跳转播放器（拖动中实时预览）
    ref
        .read(trimPlayerProvider(state.videoId))
        .seek(Duration(microseconds: positionUs));

    // 防抖更新关键帧吸附信息
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _onDragDebounced(positionUs);
    });
  }

  Future<void> _onDragDebounced(int positionUs) async {
    logger.d('_onDragDebounced positionUs=$positionUs');
    await _ensureCovered(positionUs);
    if (_disposed) return;
    final target = _resolveSnapTarget(positionUs);
    if (target != null) {
      state = state.copyWith(currentPositionUs: target);
    }
  }

  /// 跳到上一个关键帧
  Future<void> goToPreviousKeyframe() async {
    final current = state.currentPositionUs;
    logger.d('goToPreviousKeyframe current=$current');
    final gen = ++_snapGeneration;

    // 虚拟末尾 → 跳到最后关键帧（一定在缓存中）
    if (current == state.durationUs) {
      final lastKf = _cache.findNearest(state.durationUs);
      logger.d('goToPreviousKeyframe 从虚拟末尾 → lastKf=$lastKf');
      if (lastKf != null) {
        await _syncResolvedPosition(lastKf);
      }
      return;
    }

    // 快速路径：缓存命中，直接跳转
    if (_cache.isCovered(current)) {
      final prev = _cache.findPrevious(current);
      if (prev != null && _cache.isCoveredRange(prev, current)) {
        logger.d('goToPreviousKeyframe 缓存命中 prev=$prev');
        await _syncResolvedPosition(prev);
        return;
      }
    }

    // 慢速路径：需要探测关键帧
    state = state.copyWith(isSnapping: true);

    await _ensureCovered(current);
    if (_disposed || gen != _snapGeneration) return;
    var prev = _cache.findPrevious(current);

    // 缓存中无前驱 或 前驱在不连续区间 → 向后探测
    if (prev == null || !_cache.isCoveredRange(prev, current)) {
      final rangeStart = _cache.coveredRangeStart(current);
      if (rangeStart != null && rangeStart > 0) {
        logger.d('goToPreviousKeyframe 向后探测 rangeStart=$rangeStart');
        await _ensureCovered(rangeStart - 1);
        if (_disposed || gen != _snapGeneration) return;
        prev = _cache.findPrevious(current);
      }
    }

    logger.d('goToPreviousKeyframe prev=$prev');
    if (prev != null) {
      state = state.copyWith(isSnapping: false);
      await _syncResolvedPosition(prev);
    } else {
      state = state.copyWith(isSnapping: false, draggingPositionUs: null);
    }
  }

  /// 跳到下一个关键帧
  Future<void> goToNextKeyframe() async {
    final current = state.currentPositionUs;
    logger.d('goToNextKeyframe current=$current');

    // 已在虚拟末尾 → 不跳转
    if (current == state.durationUs) {
      logger.d('goToNextKeyframe 已在虚拟末尾');
      return;
    }

    final gen = ++_snapGeneration;

    // 快速路径：缓存命中
    if (_cache.isCovered(current)) {
      final next = _cache.findNext(current);
      if (next != null && _cache.isCoveredRange(current, next)) {
        logger.d('goToNextKeyframe 缓存命中 next=$next');
        await _syncResolvedPosition(next);
        return;
      }
      // 无后继且已覆盖到末尾 → 虚拟末尾
      if (next == null) {
        final rangeEnd = _cache.coveredRangeEnd(current);
        if (rangeEnd != null && rangeEnd >= state.durationUs) {
          logger.d('goToNextKeyframe 缓存命中 → 虚拟末尾');
          await _syncResolvedPosition(state.durationUs);
          return;
        }
      }
    }

    // 慢速路径：需要探测关键帧
    state = state.copyWith(isSnapping: true);

    await _ensureCovered(current);
    if (_disposed || gen != _snapGeneration) return;
    var next = _cache.findNext(current);

    // 缓存中无后继 或 后继在不连续区间 → 向前探测
    if (next == null || !_cache.isCoveredRange(current, next)) {
      final rangeEnd = _cache.coveredRangeEnd(current);
      if (rangeEnd != null && rangeEnd < state.durationUs) {
        logger.d('goToNextKeyframe 向前探测 rangeEnd=$rangeEnd');
        await _ensureCovered(rangeEnd + 1);
        if (_disposed || gen != _snapGeneration) return;
        next = _cache.findNext(current);
      }
    }

    // 无后继 → 跳到虚拟末尾
    if (next == null) {
      logger.d('goToNextKeyframe 无后继 → 虚拟末尾');
      state = state.copyWith(isSnapping: false);
      await _syncResolvedPosition(state.durationUs);
      return;
    }

    logger.d('goToNextKeyframe next=$next');
    state = state.copyWith(isSnapping: false);
    await _syncResolvedPosition(next);
  }

  /// 设置 inpoint 为当前位置
  void setInpoint() {
    logger.d('setInpoint currentPositionUs=${state.currentPositionUs}');
    state = state.copyWith(pendingInpointUs: state.currentPositionUs);
  }

  /// 设置 outpoint 并创建或更新片段
  ///
  /// 返回错误消息（null 表示成功）
  String? setOutpoint() {
    final current = state.currentPositionUs;
    final pending = state.pendingInpointUs;
    final isVirtualEnd = current == state.durationUs;
    final outpointDts = isVirtualEnd ? null : _cache.getDts(current);

    logger.d(
      'setOutpoint current=$current outpoint=${isVirtualEnd ? state.durationUs : current} '
      'pending=$pending outpointDts=$outpointDts '
      'isVirtualEnd=$isVirtualEnd',
    );

    final result = applyTrimOutpoint(
      segments: state.segments,
      pendingInpointUs: pending,
      currentPositionUs: current,
      durationUs: state.durationUs,
      outpointDtsUs: outpointDts,
    );

    if (result.errorMessage != null) {
      return result.errorMessage;
    }

    state = state.copyWith(
      segments: result.segments,
      pendingInpointUs: result.pendingInpointUs,
    );
    return null;
  }

  /// 删除 pending inpoint
  void removePendingInpoint() {
    logger.d('removePendingInpoint');
    state = state.copyWith(pendingInpointUs: null);
  }

  /// 删除片段
  void removeSegment(int index) {
    final segments = [...state.segments]..removeAt(index);
    state = state.copyWith(segments: segments);
  }

  /// 确认裁剪，保存到 HomeViewModel
  void confirm() {
    final homeVm = ref.read(homeViewModelProvider.notifier);
    if (state.segments.isEmpty) {
      homeVm.setTrimConfig(state.videoId, null);
    } else {
      homeVm.setTrimConfig(state.videoId, TrimConfig(segments: state.segments));
    }
  }

  /// 解析吸附目标：关键帧或虚拟末尾。
  ///
  /// 当 [positionUs] 在最后关键帧之后且更接近 durationUs 时，
  /// 返回 durationUs（虚拟末尾）。
  int? _resolveSnapTarget(int positionUs) {
    final nearest = _cache.findNearest(positionUs);
    if (nearest == null) return null;

    // 如果位置在最后关键帧之后，考虑虚拟末尾
    if (positionUs > nearest && _cache.findNext(nearest) == null) {
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

  /// 确保目标时间点已被关键帧缓存覆盖
  Future<void> _ensureCovered(int targetUs) async {
    if (_cache.isCovered(targetUs)) {
      logger.d('_ensureCovered targetUs=$targetUs 已缓存');
      return;
    }

    var windowUs = _defaultWindowUs;
    for (var retry = 0; retry < _maxRetries; retry++) {
      final startUs = (targetUs - windowUs).clamp(0, state.durationUs);
      final endUs = (targetUs + windowUs).clamp(0, state.durationUs);

      logger.d(
        '_ensureCovered retry=$retry '
        'window=[$startUs, $endUs]',
      );

      try {
        final ffprobe = _getFfprobeService();
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

        _cache.addRange(startUs, endUs, keyframes);

        if (keyframes.isNotEmpty) return;
      } catch (e) {
        logger.e('_ensureCovered 异常', error: e);
        state = state.copyWith(errorMessage: '关键帧探测失败: $e');
        return;
      }

      // 窗口内无关键帧，翻倍重试
      windowUs = (windowUs * 2).clamp(0, _maxWindowUs);
    }
    logger.w('_ensureCovered $_maxRetries次重试后仍无关键帧');
  }

  FFprobeService _getFfprobeService() {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    if (ffprobe.ffprobePath.trim().isEmpty ||
        ffprobe.ffprobePath == 'ffprobe') {
      ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    }
    return ffprobe;
  }

  int _resolvePlayerSeekTarget(int timestampUs) {
    if (timestampUs == state.durationUs) {
      return _cache.findNearest(state.durationUs) ?? timestampUs;
    }
    return timestampUs;
  }

  Future<void> _syncResolvedPosition(int targetUs) async {
    if (_disposed) return;

    final actualTs = _resolvePlayerSeekTarget(targetUs);
    final requestId = ++_previewRequestId;
    _activePreviewRequestId = requestId;
    _previewPendingTimer?.cancel();

    state = state.copyWith(
      currentPositionUs: targetUs,
      draggingPositionUs: null,
      isPreviewPending: true,
      pendingPreviewTargetUs: actualTs,
    );

    _previewPendingTimer = Timer(_previewPendingTimeout, () {
      if (_disposed || _activePreviewRequestId != requestId) return;
      if (!state.isPreviewPending || state.pendingPreviewTargetUs != actualTs) {
        return;
      }
      logger.w('预览画面同步超时 videoId=${state.videoId} targetUs=$actualTs');
      _clearPreviewPending();
    });

    await _seekPlayer(targetUs);
    if (_disposed || _activePreviewRequestId != requestId) return;
    final player = ref.read(trimPlayerProvider(state.videoId));
    _completePreviewPendingIfMatched(player.state.position.inMicroseconds);
  }

  void _clearPreviewPending() {
    _previewPendingTimer?.cancel();
    _activePreviewRequestId = null;
    if (!state.isPreviewPending && state.pendingPreviewTargetUs == null) {
      return;
    }
    state = state.copyWith(
      isPreviewPending: false,
      pendingPreviewTargetUs: null,
    );
  }

  void _completePreviewPendingIfMatched(int positionUs) {
    if (_disposed || !_matchesPreviewTarget(positionUs)) return;
    logger.i('预览画面已同步 videoId=${state.videoId} positionUs=$positionUs');
    _clearPreviewPending();
  }

  bool _matchesPreviewTarget(int positionUs) {
    final targetUs = state.pendingPreviewTargetUs;
    if (!state.isPreviewPending || targetUs == null) return false;
    return (positionUs - targetUs).abs() <= _previewMatchToleranceUs;
  }
}
