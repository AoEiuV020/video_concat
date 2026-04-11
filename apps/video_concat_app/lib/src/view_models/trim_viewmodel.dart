import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/keyframe_cache.dart';
import 'home_viewmodel.dart';
import 'providers.dart';
import 'trim_state.dart';

part 'trim_viewmodel.g.dart';

/// 裁剪页面 ViewModel
@riverpod
class TrimViewModel extends _$TrimViewModel {
  late KeyframeCache _cache;

  /// 默认查询窗口（微秒）：10秒
  static const _defaultWindowUs = 10000000;

  /// 最大窗口（微秒）：30秒
  static const _maxWindowUs = 30000000;

  /// 最大重试次数
  static const _maxRetries = 3;

  @override
  TrimState build(String videoId) {
    final homeState = ref.read(homeViewModelProvider);
    final item = homeState.videoItems.firstWhere((v) => v.id == videoId);

    final durationUs = item.durationUs ?? 0;
    _cache = KeyframeCache(durationUs: durationUs);

    // 加载已有的裁剪配置
    final existingSegments = item.trimConfig?.segments ?? [];

    // 异步初始化
    if (durationUs > 0) {
      Future.microtask(() => _init());
    }

    return TrimState(
      videoId: videoId,
      filePath: item.filePath,
      fileName: item.fileName,
      durationUs: durationUs,
      segments: existingSegments,
      isLoading: durationUs > 0,
    );
  }

  Future<void> _init() async {
    // 加载初始位置（0）附近的关键帧
    await _ensureCovered(0);
    final nearest = _cache.findNearest(0);

    state = state.copyWith(
      isLoading: false,
      currentPositionUs: nearest ?? 0,
    );

    // 加载首帧预览
    if (nearest != null) {
      await _loadPreview(nearest);
    }
  }

  /// 滑块松开时调用
  Future<void> onSliderReleased(int positionUs) async {
    await _ensureCovered(positionUs);
    final nearest = _cache.findNearest(positionUs);
    if (nearest == null) return;

    state = state.copyWith(currentPositionUs: nearest);
    await _loadPreview(nearest);
  }

  /// 设置 inpoint 为当前位置
  void setInpoint() {
    state = state.copyWith(inpointUs: state.currentPositionUs);
  }

  /// 设置 outpoint 并创建片段
  ///
  /// 返回错误消息（null 表示成功）
  String? setOutpoint() {
    final inpoint = state.inpointUs;
    final outpoint = state.currentPositionUs;

    if (outpoint <= inpoint) {
      return '终点必须在起点之后';
    }

    // 检查片段重叠
    final newSeg = TrimSegment(inpoint: inpoint, outpoint: outpoint);
    for (final existing in state.segments) {
      if (_overlaps(newSeg, existing)) {
        return '新片段与已有片段重叠';
      }
    }

    // 添加并排序
    final segments = [...state.segments, newSeg]
      ..sort((a, b) => a.inpoint.compareTo(b.inpoint));

    state = state.copyWith(
      segments: segments,
      inpointUs: 0, // 重置 inpoint
    );

    return null;
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

  /// 确保目标时间点已被关键帧缓存覆盖
  Future<void> _ensureCovered(int targetUs) async {
    if (_cache.isCovered(targetUs)) return;

    var windowUs = _defaultWindowUs;
    for (var retry = 0; retry < _maxRetries; retry++) {
      final startUs = (targetUs - windowUs).clamp(0, state.durationUs);
      final endUs = (targetUs + windowUs).clamp(0, state.durationUs);

      try {
        final ffprobe = _getFfprobeService();
        final keyframes = await ffprobe.findKeyframes(
          state.filePath,
          startUs: startUs,
          endUs: endUs,
        );

        _cache.addRange(startUs, endUs, keyframes);

        if (keyframes.isNotEmpty) return;
      } catch (e) {
        state = state.copyWith(errorMessage: '关键帧探测失败: $e');
        return;
      }

      // 窗口内无关键帧，翻倍重试
      windowUs = (windowUs * 2).clamp(0, _maxWindowUs);
    }
  }

  /// 加载预览图
  Future<void> _loadPreview(int timestampUs) async {
    state = state.copyWith(isLoadingPreview: true);
    try {
      final ffmpeg = ref.read(ffmpegServiceProvider);
      final bytes = await ffmpeg.extractFrame(
        filePath: state.filePath,
        timestampUs: timestampUs,
      );
      state = state.copyWith(
        previewImage: bytes,
        isLoadingPreview: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingPreview: false);
    }
  }

  FFprobeService _getFfprobeService() {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    return ffprobe;
  }
}
