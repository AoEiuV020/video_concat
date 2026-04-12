import 'dart:async';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../utils/keyframe_cache.dart';
import '../home/home_viewmodel.dart';
import '../providers.dart';
import 'trim_state.dart';

part 'trim_viewmodel.g.dart';

/// 裁剪页面 ViewModel
@riverpod
class TrimViewModel extends _$TrimViewModel {
  late KeyframeCache _cache;
  Timer? _debounceTimer;
  bool _disposed = false;
  bool _isHdr = false;
  int _previewGeneration = 0;
  int _snapGeneration = 0;

  /// 默认查询窗口（微秒）：10秒
  static const _defaultWindowUs = 10000000;

  /// 最大窗口（微秒）：30秒
  static const _maxWindowUs = 30000000;

  /// 最大重试次数
  static const _maxRetries = 3;

  @override
  TrimState build(String videoId) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
    });

    final homeState = ref.read(homeViewModelProvider);
    final item = homeState.videoItems.firstWhere((v) => v.id == videoId);

    final durationUs = item.durationUs ?? 0;
    _cache = KeyframeCache(durationUs: durationUs);

    // 加载已有的裁剪配置
    final existingSegments = item.trimConfig?.segments ?? [];

    logger.d('build videoId=$videoId durationUs=$durationUs '
        'filePath=${item.filePath} segments=${existingSegments.length}');

    // 异步初始化
    if (durationUs > 0) {
      Future.microtask(() async {
        try {
          await _init();
        } catch (e, s) {
          logger.e('_init 未捕获异常', error: e, stackTrace: s);
          state = state.copyWith(
            isLoading: false,
            errorMessage: '初始化失败: $e',
          );
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

    // 探测视频是否为 HDR
    try {
      final ffprobe = _getFfprobeService();
      final probeResult = await ffprobe.probe(state.filePath);
      if (_disposed) return;
      final videoStream = probeResult.streams.where((s) => s.isVideo).firstOrNull;
      if (videoStream != null) {
        _isHdr = videoStream.isHdr;
        logger.d('_init isHdr=$_isHdr '
            'colorTransfer=${videoStream.colorTransfer}');
      }
    } catch (e) {
      logger.w('_init HDR 探测失败: $e');
    }

    // 加载初始位置（0）附近的关键帧
    await _ensureCovered(0);
    if (_disposed) return;
    final nearest = _cache.findNearest(0);

    logger.d('_init nearest=$nearest '
        '缓存关键帧数=${_cache.keyframes.length}');

    state = state.copyWith(
      isLoading: false,
      currentPositionUs: nearest ?? 0,
    );

    // 加载首帧预览
    if (nearest != null) {
      await _loadPreview(nearest);
    } else {
      logger.w('_init 无关键帧，跳过预览');
    }

    logger.d('_init 完成');
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
    state = state.copyWith(
      currentPositionUs: target,
      isSnapping: false,
      draggingPositionUs: null,
    );
    await _loadPreview(target);
  }

  /// 拖动中调用，100ms 防抖触发关键帧预览
  void onSliderDragging(int positionUs) {
    _previewGeneration++;
    _snapGeneration++;
    state = state.copyWith(
      draggingPositionUs: positionUs,
      isLoadingPreview: false,
      isSnapping: false,
    );
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
      await _loadPreview(target);
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
        state = state.copyWith(
          currentPositionUs: lastKf,
          draggingPositionUs: null,
        );
        await _loadPreview(lastKf);
      }
      return;
    }

    // 快速路径：缓存命中，直接跳转
    if (_cache.isCovered(current)) {
      final prev = _cache.findPrevious(current);
      if (prev != null && _cache.isCoveredRange(prev, current)) {
        logger.d('goToPreviousKeyframe 缓存命中 prev=$prev');
        state = state.copyWith(
          currentPositionUs: prev,
          draggingPositionUs: null,
        );
        await _loadPreview(prev);
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
      state = state.copyWith(
        currentPositionUs: prev,
        isSnapping: false,
        draggingPositionUs: null,
      );
      await _loadPreview(prev);
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
        state = state.copyWith(
          currentPositionUs: next,
          draggingPositionUs: null,
        );
        await _loadPreview(next);
        return;
      }
      // 无后继且已覆盖到末尾 → 虚拟末尾
      if (next == null) {
        final rangeEnd = _cache.coveredRangeEnd(current);
        if (rangeEnd != null && rangeEnd >= state.durationUs) {
          logger.d('goToNextKeyframe 缓存命中 → 虚拟末尾');
          state = state.copyWith(
            currentPositionUs: state.durationUs,
            draggingPositionUs: null,
          );
          await _loadPreview(state.durationUs);
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
      state = state.copyWith(
        currentPositionUs: state.durationUs,
        isSnapping: false,
        draggingPositionUs: null,
      );
      await _loadPreview(state.durationUs);
      return;
    }

    logger.d('goToNextKeyframe next=$next');
    state = state.copyWith(
      currentPositionUs: next,
      isSnapping: false,
      draggingPositionUs: null,
    );
    await _loadPreview(next);
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

    // 虚拟末尾 → outpoint = durationUs，filelist 省略 outpoint → EOF
    // 普通关键帧 → 正常左闭右开
    final isVirtualEnd = current == state.durationUs;
    final outpoint = isVirtualEnd ? state.durationUs : current;
    final outpointDts = isVirtualEnd ? null : _cache.getDts(current);

    logger.d('setOutpoint current=$current outpoint=$outpoint '
        'pending=$pending outpointDts=$outpointDts '
        'isVirtualEnd=$isVirtualEnd');

    if (pending != null) {
      // 有 pending inpoint → 创建新片段
      if (outpoint <= pending) {
        return '终点必须在起点之后';
      }
      final newSeg = TrimSegment(
        inpoint: pending,
        outpoint: outpoint,
        outpointDtsUs: outpointDts,
      );
      for (final existing in state.segments) {
        if (_overlaps(newSeg, existing)) {
          return '新片段与已有片段重叠';
        }
      }
      final segments = [...state.segments, newSeg]
        ..sort((a, b) => a.inpoint.compareTo(b.inpoint));
      state = state.copyWith(
        segments: segments,
        pendingInpointUs: null,
      );
    } else {
      // 无 pending → 更新最后一个片段的 outpoint
      if (state.segments.isEmpty) {
        return '没有可更新的片段';
      }
      final lastIdx = state.segments.length - 1;
      final last = state.segments[lastIdx];
      if (outpoint <= last.inpoint) {
        return '终点必须在起点之后';
      }
      final updated = TrimSegment(
        inpoint: last.inpoint,
        outpoint: outpoint,
        outpointDtsUs: outpointDts,
      );
      for (var i = 0; i < state.segments.length - 1; i++) {
        if (_overlaps(updated, state.segments[i])) {
          return '更新后的片段与已有片段重叠';
        }
      }
      final segments = [...state.segments];
      segments[lastIdx] = updated;
      state = state.copyWith(segments: segments);
    }
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
      homeVm.setTrimConfig(
        state.videoId,
        TrimConfig(segments: state.segments),
      );
    }
  }

  bool _overlaps(TrimSegment a, TrimSegment b) {
    return a.inpoint < b.outpoint && b.inpoint < a.outpoint;
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
        logger.d('_resolveSnapTarget → 虚拟末尾 '
            '(nearest=$nearest distToKf=$distToKf distToEnd=$distToEnd)');
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

      logger.d('_ensureCovered retry=$retry '
          'window=[$startUs, $endUs]');

      try {
        final ffprobe = _getFfprobeService();
        logger.d('ffprobe路径=${ffprobe.ffprobePath}');

        final keyframes = await ffprobe.findKeyframes(
          state.filePath,
          startUs: startUs,
          endUs: endUs,
        );

        logger.d('findKeyframes 返回 ${keyframes.length} 个关键帧'
            '${keyframes.isNotEmpty ? ": ${keyframes.take(5).map((k) => k.ptsUs)}" : ""}');

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

  /// 加载预览图
  Future<void> _loadPreview(int timestampUs) async {
    if (_disposed) return;
    final gen = ++_previewGeneration;

    // 虚拟末尾 → 用最后关键帧的画面
    final actualTs = timestampUs == state.durationUs
        ? (_cache.findNearest(state.durationUs) ?? timestampUs)
        : timestampUs;

    logger.d('_loadPreview timestampUs=$timestampUs '
        'actualTs=$actualTs gen=$gen');
    state = state.copyWith(isLoadingPreview: true);
    try {
      final ffmpeg = ref.read(ffmpegServiceProvider);
      logger.d('ffmpeg路径=${ffmpeg.ffmpegPath}');

      final bytes = await ffmpeg.extractFrame(
        filePath: state.filePath,
        timestampUs: actualTs,
        isHdr: _isHdr,
      );
      if (_disposed || gen != _previewGeneration) return;

      logger.d('extractFrame 返回 '
          '${bytes != null ? "${bytes.length} bytes" : "null"}');

      state = state.copyWith(
        previewImage: bytes,
        isLoadingPreview: false,
      );
    } catch (e) {
      if (_disposed || gen != _previewGeneration) return;
      logger.e('_loadPreview 异常', error: e);
      state = state.copyWith(
        isLoadingPreview: false,
        errorMessage: '预览加载失败: $e',
      );
    }
  }

  FFprobeService _getFfprobeService() {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    return ffprobe;
  }
}
