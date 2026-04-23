part of 'settings_viewmodel.dart';

final class _SettingsViewModelActions {
  _SettingsViewModelActions(this.vm);

  final SettingsViewModel vm;

  SettingsState get state => vm.currentState;
  set state(SettingsState value) => vm.currentState = value;

  Future<void> updateFFmpegPath(String path) async {
    await _updateToolPath(ExternalTool.ffmpeg, path);
  }

  Future<void> updateFFprobePath(String path) async {
    await _updateToolPath(ExternalTool.ffprobe, path);
  }

  Future<void> refreshByInputs({
    required String ffmpegPath,
    required String ffprobePath,
  }) async {
    logger.d('refreshByInputs ffmpegPath=$ffmpegPath ffprobePath=$ffprobePath');
    final resolvedFFmpegPath = await _resolveInputPath(
      ExternalTool.ffmpeg,
      ffmpegPath,
    );
    final resolvedFFprobePath = await _resolveInputPath(
      ExternalTool.ffprobe,
      ffprobePath,
    );
    final nextSettings = state.settings.copyWith(
      ffmpegPath: resolvedFFmpegPath,
      ffprobePath: resolvedFFprobePath,
    );
    await _saveAndValidate(
      settings: nextSettings,
      action: 'refreshByInputs 失败',
      userMessage: '刷新失败：',
    );
  }

  Future<void> browseFFmpegPath() async {
    await _browseToolPath(ExternalTool.ffmpeg);
  }

  Future<void> browseFFprobePath() async {
    await _browseToolPath(ExternalTool.ffprobe);
  }

  Future<void> _saveAndValidate({
    required AppSettings settings,
    required String action,
    required String userMessage,
  }) async {
    try {
      state = state.copyWith(settings: settings, errorMessage: null);

      final prefs = vm.preferencesRepository;
      await prefs.saveFFmpegPath(settings.ffmpegPath);
      await prefs.saveFFprobePath(settings.ffprobePath);

      await vm._validateCurrentPath();
    } catch (e, s) {
      vm._reportError(action, e, s, userMessage: '$userMessage$e');
    }
  }

  Future<void> _updateToolPath(ExternalTool tool, String path) async {
    logger.d('updateToolPath tool=$tool path=$path');
    final resolvedPath = await _resolveInputPath(tool, path);
    final nextSettings = tool == ExternalTool.ffmpeg
        ? state.settings.copyWith(ffmpegPath: resolvedPath)
        : state.settings.copyWith(ffprobePath: resolvedPath);
    await _saveAndValidate(
      settings: nextSettings,
      action: 'updateToolPath 失败 tool=$tool',
      userMessage: '保存路径失败：',
    );
  }

  Future<String> _resolveInputPath(ExternalTool tool, String path) async {
    final trimmedPath = path.trim();
    if (trimmedPath.isNotEmpty) {
      return trimmedPath;
    }

    final discoveredPath = await vm._autoDiscoverAndPersist(tool);
    if (discoveredPath != null && discoveredPath.isNotEmpty) {
      return discoveredPath;
    }

    final spec = externalToolSpecsForCurrentPlatform()[tool];
    return spec?.commandName ??
        (tool == ExternalTool.ffmpeg ? 'ffmpeg' : 'ffprobe');
  }

  Future<void> _browseToolPath(ExternalTool tool) async {
    final toolLabel = tool == ExternalTool.ffmpeg ? 'FFmpeg' : 'FFprobe';
    logger.d('browseToolPath tool=$toolLabel 打开文件选择');
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: '选择 $toolLabel 可执行文件',
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final selectedPath = result.files.single.path!;
        if (tool == ExternalTool.ffmpeg) {
          await updateFFmpegPath(selectedPath);
        } else {
          await updateFFprobePath(selectedPath);
        }
      } else {
        logger.d('browseToolPath tool=$toolLabel 用户取消');
      }
    } catch (e, s) {
      vm._reportError(
        'browseToolPath 失败 tool=$toolLabel',
        e,
        s,
        userMessage: '选择文件失败：$e',
      );
    }
  }
}
