import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
import '../../repositories/preferences_repository.dart';
import '../../utils/chapter_builder.dart';
import '../../utils/external_tools.dart';
import '../../utils/segment_output_parser.dart';
import '../providers.dart';
import 'home_state.dart';

part 'home_viewmodel.g.dart';
part 'home_viewmodel_actions.dart';
part 'home_viewmodel_generate.dart';
part 'home_viewmodel_init.dart';
part 'home_viewmodel_probe.dart';

/// 主页 ViewModel
@riverpod
class HomeViewModel extends _$HomeViewModel {
  String? _referenceFilePath;
  final _comparer = ProbeComparer();
  int _snackbarEventId = 0;

  late final _initDelegate = _HomeViewModelInit(this);
  late final _actionsDelegate = _HomeViewModelActions(this);
  late final _generateDelegate = _HomeViewModelGenerate(this);
  late final _probeDelegate = _HomeViewModelProbe(this);

  HomeState get currentState => state;
  set currentState(HomeState value) => state = value;

  bool get isMounted => ref.mounted;
  PreferencesRepository get preferencesRepository =>
      ref.read(preferencesRepositoryProvider);
  FFmpegService get currentFFmpegService => ref.read(ffmpegServiceProvider);
  FFprobeService get currentFFprobeService => ref.read(ffprobeServiceProvider);
  VideoConcatService get currentVideoConcatService =>
      ref.read(videoConcatServiceProvider);

  @override
  HomeState build() {
    _initialize();
    return const HomeState();
  }

  Future<void> _initialize() => _initDelegate.initialize();
  Future<void> refreshExternalToolsStatus() =>
      _initDelegate.refreshExternalToolsStatus();

  Future<void> addVideos(List<String> filePaths) =>
      _actionsDelegate.addVideos(filePaths);
  void removeVideo(String id) => _actionsDelegate.removeVideo(id);
  void reorderVideo(int oldIndex, int newIndex) =>
      _actionsDelegate.reorderVideo(oldIndex, newIndex);
  void updateOutputBaseName(String baseName) =>
      _actionsDelegate.updateOutputBaseName(baseName);
  Future<void> updateOutputExtension(String extension) =>
      _actionsDelegate.updateOutputExtension(extension);
  void updateExportOptions(ExportOptions options) =>
      _actionsDelegate.updateExportOptions(options);
  void setTrimConfig(String videoId, TrimConfig? config) =>
      _actionsDelegate.setTrimConfig(videoId, config);
  void cancelGenerate() => _actionsDelegate.cancelGenerate();
  void clearResult() => _actionsDelegate.clearResult();
  void reset() => _actionsDelegate.reset();

  Future<void> startGenerate(String outputPath) =>
      _generateDelegate.startGenerate(outputPath);

  void _checkAndProbe() => _probeDelegate.checkAndProbe();
  FFprobeService _getFfprobeService() => _probeDelegate.getFfprobeService();

  void _reportError(
    String action,
    Object error,
    StackTrace stackTrace, {
    required String userMessage,
  }) {
    if (!isMounted) return;
    logger.e(action, error: error, stackTrace: stackTrace);
    _setErrorMessage(userMessage);
  }

  void _setErrorMessage(String message) {
    if (!isMounted) return;
    currentState = currentState.copyWith(errorMessage: message);
    _emitSnackbar(message);
  }

  void _emitSnackbar(String message) {
    if (!isMounted) return;
    _snackbarEventId += 1;
    currentState = currentState.copyWith(
      snackbarMessage: message,
      snackbarEventId: _snackbarEventId,
    );
  }
}
