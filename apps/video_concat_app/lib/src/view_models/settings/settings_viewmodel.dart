import 'package:ffmpeg_kit/src/ffmpeg_service.dart';
import 'package:ffmpeg_kit/src/ffprobe_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
import '../../repositories/preferences_repository.dart';
import '../../utils/external_tools.dart';
import '../providers.dart';
import 'settings_state.dart';

part 'settings_viewmodel.g.dart';
part 'settings_viewmodel_actions.dart';
part 'settings_viewmodel_init.dart';

/// 设置 ViewModel
@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  late final _initDelegate = _SettingsViewModelInit(this);
  late final _actionsDelegate = _SettingsViewModelActions(this);

  SettingsState get currentState => state;
  set currentState(SettingsState value) => state = value;

  PreferencesRepository get preferencesRepository =>
      ref.read(preferencesRepositoryProvider);
  FFmpegService get currentFFmpegService => ref.read(ffmpegServiceProvider);
  FFprobeService get currentFFprobeService => ref.read(ffprobeServiceProvider);

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() => _initDelegate.loadSettings();
  Future<void> _validateCurrentPath() => _initDelegate.validateCurrentPath();
  Future<String?> _autoDiscoverAndPersist(ExternalTool tool) =>
      _initDelegate.autoDiscoverAndPersist(tool);

  Future<void> updateFFmpegPath(String path) =>
      _actionsDelegate.updateFFmpegPath(path);
  Future<void> updateFFprobePath(String path) =>
      _actionsDelegate.updateFFprobePath(path);
  Future<void> refreshByInputs({
    required String ffmpegPath,
    required String ffprobePath,
  }) => _actionsDelegate.refreshByInputs(
    ffmpegPath: ffmpegPath,
    ffprobePath: ffprobePath,
  );
  Future<void> browseFFmpegPath() => _actionsDelegate.browseFFmpegPath();
  Future<void> browseFFprobePath() => _actionsDelegate.browseFFprobePath();

  void _reportError(
    String action,
    Object error,
    StackTrace stackTrace, {
    required String userMessage,
  }) {
    logger.e(action, error: error, stackTrace: stackTrace);
    state = state.copyWith(errorMessage: userMessage, isValidating: false);
  }
}
