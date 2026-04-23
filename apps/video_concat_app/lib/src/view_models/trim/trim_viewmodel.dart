import 'dart:async';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../utils/keyframe_cache.dart';
import '../home/home_viewmodel.dart';
import '../providers.dart';
import 'trim_player_provider.dart';
import 'trim_segment_editor.dart';
import 'trim_state.dart';

part 'trim_viewmodel.g.dart';
part 'trim_viewmodel_init.dart';
part 'trim_viewmodel_navigation.dart';
part 'trim_viewmodel_playback.dart';
part 'trim_viewmodel_preview.dart';
part 'trim_viewmodel_segments.dart';

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

  late final _initDelegate = _TrimViewModelInit(this);
  late final _playbackDelegate = _TrimViewModelPlayback(this);
  late final _navigationDelegate = _TrimViewModelNavigation(this);
  late final _previewDelegate = _TrimViewModelPreview(this);
  late final _segmentsDelegate = _TrimViewModelSegments(this);

  TrimState get currentState => state;
  set currentState(TrimState value) => state = value;

  bool get isDisposed => _disposed;
  set isDisposed(bool value) => _disposed = value;

  int get snapGeneration => _snapGeneration;
  set snapGeneration(int value) => _snapGeneration = value;

  int get previewRequestId => _previewRequestId;
  set previewRequestId(int value) => _previewRequestId = value;

  int? get activePreviewRequestId => _activePreviewRequestId;
  set activePreviewRequestId(int? value) => _activePreviewRequestId = value;

  Timer? get debounceTimer => _debounceTimer;
  set debounceTimer(Timer? value) => _debounceTimer = value;

  Timer? get previewPendingTimer => _previewPendingTimer;
  set previewPendingTimer(Timer? value) => _previewPendingTimer = value;

  KeyframeCache get cache => _cache;

  Player get player => ref.read(trimPlayerProvider(state.videoId));
  HomeViewModel get homeViewModel => ref.read(homeViewModelProvider.notifier);
  FFprobeService get currentFfprobeService => ref.read(ffprobeServiceProvider);
  FFmpegService get currentFfmpegService => ref.read(ffmpegServiceProvider);

  @override
  TrimState build(String videoId) {
    isDisposed = false;
    ref.onDispose(() {
      isDisposed = true;
      debounceTimer?.cancel();
      previewPendingTimer?.cancel();
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
          currentState = currentState.copyWith(
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

  Future<void> _init() => _initDelegate.init();
  Future<int> _seekPlayer(int timestampUs) =>
      _initDelegate.seekPlayer(timestampUs);

  Future<void> togglePlayPause() => _playbackDelegate.togglePlayPause();
  Future<void> onSliderReleased(int positionUs) =>
      _playbackDelegate.onSliderReleased(positionUs);
  void onSliderDragging(int positionUs) =>
      _playbackDelegate.onSliderDragging(positionUs);

  Future<void> goToPreviousKeyframe() =>
      _navigationDelegate.goToPreviousKeyframe();
  Future<void> goToNextKeyframe() => _navigationDelegate.goToNextKeyframe();
  int? _resolveSnapTarget(int positionUs) =>
      _navigationDelegate.resolveSnapTarget(positionUs);
  Future<void> _ensureCovered(int targetUs) =>
      _navigationDelegate.ensureCovered(targetUs);
  int _resolvePlayerSeekTarget(int timestampUs) =>
      _navigationDelegate.resolvePlayerSeekTarget(timestampUs);

  void setInpoint() => _segmentsDelegate.setInpoint();
  String? setOutpoint() => _segmentsDelegate.setOutpoint();
  void removePendingInpoint() => _segmentsDelegate.removePendingInpoint();
  void removeSegment(int index) => _segmentsDelegate.removeSegment(index);
  void confirm() => _segmentsDelegate.confirm();

  Future<void> _syncResolvedPosition(int targetUs) =>
      _previewDelegate.syncResolvedPosition(targetUs);
  void _clearPreviewPending() => _previewDelegate.clearPreviewPending();
  void _completePreviewPendingIfMatched(int positionUs) =>
      _previewDelegate.completePreviewPendingIfMatched(positionUs);
}
