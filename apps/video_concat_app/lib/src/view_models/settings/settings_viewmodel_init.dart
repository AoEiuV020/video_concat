part of 'settings_viewmodel.dart';

final class _SettingsViewModelInit {
  _SettingsViewModelInit(this.vm);

  final SettingsViewModel vm;

  SettingsState get state => vm.currentState;
  set state(SettingsState value) => vm.currentState = value;

  dynamic get preferencesRepository => vm.preferencesRepository;
  dynamic get ffmpegService => vm.currentFFmpegService;
  dynamic get ffprobeService => vm.currentFFprobeService;

  Future<void> loadSettings() async {
    try {
      var ffmpegPath = await preferencesRepository.getFFmpegPath();
      var ffprobePath = await preferencesRepository.getFFprobePath();

      if (ffmpegPath == null || ffmpegPath.isEmpty) {
        ffmpegPath = await autoDiscoverAndPersist(ExternalTool.ffmpeg);
      }
      if (ffprobePath == null || ffprobePath.isEmpty) {
        ffprobePath = await autoDiscoverAndPersist(ExternalTool.ffprobe);
      }

      final resolvedSettings = AppSettings(
        ffmpegPath: ffmpegPath ?? 'ffmpeg',
        ffprobePath: ffprobePath ?? 'ffprobe',
      );
      state = state.copyWith(settings: resolvedSettings);
      logger.d(
        '已加载工具路径 ffmpeg=${resolvedSettings.ffmpegPath} '
        'ffprobe=${resolvedSettings.ffprobePath}',
      );

      await validateCurrentPath();
    } catch (e, s) {
      vm._reportError('loadSettings 失败', e, s, userMessage: '加载设置失败：$e');
    }
  }

  Future<void> validateCurrentPath() async {
    state = state.copyWith(
      isValidating: true,
      errorMessage: null,
      ffmpegVersion: null,
      ffprobeVersion: null,
    );
    try {
      ffmpegService.ffmpegPath = state.settings.ffmpegPath;
      ffprobeService.ffprobePath = state.settings.ffprobePath;

      final isFFmpegValid = await ffmpegService.validate();
      final isFFprobeValid = await ffprobeService.validate();
      final ffmpegVersion = isFFmpegValid
          ? await ffmpegService.readVersion()
          : null;
      final ffprobeVersion = isFFprobeValid
          ? await ffprobeService.readVersion()
          : null;

      logger.d(
        '验证路径 '
        'ffmpeg=${state.settings.ffmpegPath} isFFmpegValid=$isFFmpegValid '
        'ffprobe=${state.settings.ffprobePath} isFFprobeValid=$isFFprobeValid',
      );

      state = state.copyWith(
        isFFmpegValid: isFFmpegValid,
        isFFprobeValid: isFFprobeValid,
        ffmpegVersion: ffmpegVersion,
        ffprobeVersion: ffprobeVersion,
        isValidating: false,
      );
    } catch (e, s) {
      vm._reportError('validateCurrentPath 失败', e, s, userMessage: '工具校验失败：$e');
      state = state.copyWith(
        isFFmpegValid: false,
        isFFprobeValid: false,
        isValidating: false,
      );
    }
  }

  Future<String?> autoDiscoverAndPersist(ExternalTool tool) async {
    final specs = externalToolSpecsForCurrentPlatform();
    final spec = specs[tool];
    if (spec == null) return null;

    for (final candidate in spec.candidatePaths) {
      try {
        final isValid = await _validateCandidate(tool, candidate);
        if (!isValid) continue;

        if (tool == ExternalTool.ffmpeg) {
          await preferencesRepository.saveFFmpegPath(candidate);
        } else {
          await preferencesRepository.saveFFprobePath(candidate);
        }
        logger.i('自动发现 ${spec.displayName} 路径: $candidate');
        return candidate;
      } catch (e, s) {
        logger.w('自动发现候选失败 ${spec.displayName}=$candidate error=$e');
        logger.d('自动发现异常堆栈: $s');
      }
    }

    logger.w('未发现可用 ${spec.displayName}，回退 commandName=${spec.commandName}');
    return null;
  }

  Future<bool> _validateCandidate(ExternalTool tool, String candidate) async {
    if (!await toolPathExistsIfAbsolute(candidate)) {
      return false;
    }

    if (tool == ExternalTool.ffmpeg) {
      final oldPath = ffmpegService.ffmpegPath;
      ffmpegService.ffmpegPath = candidate;
      final ok = await ffmpegService.validate();
      ffmpegService.ffmpegPath = oldPath;
      return ok;
    }

    final oldPath = ffprobeService.ffprobePath;
    ffprobeService.ffprobePath = candidate;
    final ok = await ffprobeService.validate();
    ffprobeService.ffprobePath = oldPath;
    return ok;
  }
}
