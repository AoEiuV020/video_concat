part of 'home_viewmodel.dart';

final class _HomeViewModelInit {
  _HomeViewModelInit(this.vm);

  final HomeViewModel vm;

  HomeState get state => vm.currentState;
  set state(HomeState value) => vm.currentState = value;

  bool get mounted => vm.isMounted;
  dynamic get preferencesRepository => vm.preferencesRepository;
  FFmpegService get ffmpegService => vm.currentFFmpegService;
  FFprobeService get ffprobeService => vm.currentFFprobeService;

  Future<void> initialize() async {
    try {
      await _loadPreferences();
      if (!mounted) return;
      await _setupExternalTools();
      if (!mounted) return;
      await _validateExternalTools();
    } catch (e, s) {
      if (!mounted) return;
      vm._reportError('初始化失败', e, s, userMessage: '初始化失败：$e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final ext = await preferencesRepository.getLastExtension();
      final exportOptions = await preferencesRepository.loadExportOptions();
      if (!mounted) return;
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(extension: ext),
        exportOptions: exportOptions,
      );
      logger.d('偏好加载完成 ext=$ext exportOptions=$exportOptions');
    } catch (e, s) {
      if (!mounted) return;
      vm._reportError('偏好加载失败', e, s, userMessage: '读取偏好失败：$e');
    }
  }

  Future<void> _setupExternalTools() async {
    if (!mounted) return;
    final specs = externalToolSpecsForCurrentPlatform();

    String ffmpegPath = await preferencesRepository.getFFmpegPath() ?? '';
    if (!mounted) return;
    String ffprobePath = await preferencesRepository.getFFprobePath() ?? '';
    if (!mounted) return;

    ffmpegPath = await _resolveToolPath(
      tool: ExternalTool.ffmpeg,
      currentPath: ffmpegPath,
      fallbackCommand: specs[ExternalTool.ffmpeg]!.commandName,
      onPersist: preferencesRepository.saveFFmpegPath,
      validateCandidate: (candidate) async {
        final old = ffmpegService.ffmpegPath;
        ffmpegService.ffmpegPath = candidate;
        final ok = await ffmpegService.validate();
        ffmpegService.ffmpegPath = old;
        return ok;
      },
    );
    if (!mounted) return;

    ffprobePath = await _resolveToolPath(
      tool: ExternalTool.ffprobe,
      currentPath: ffprobePath,
      fallbackCommand: specs[ExternalTool.ffprobe]!.commandName,
      onPersist: preferencesRepository.saveFFprobePath,
      validateCandidate: (candidate) async {
        final old = ffprobeService.ffprobePath;
        ffprobeService.ffprobePath = candidate;
        final ok = await ffprobeService.validate();
        ffprobeService.ffprobePath = old;
        return ok;
      },
    );
    if (!mounted) return;

    ffmpegService.ffmpegPath = ffmpegPath;
    ffprobeService.ffprobePath = ffprobePath;
    logger.i('工具路径已设置 ffmpeg=$ffmpegPath ffprobe=$ffprobePath');
  }

  Future<String> _resolveToolPath({
    required ExternalTool tool,
    required String currentPath,
    required String fallbackCommand,
    required Future<void> Function(String) onPersist,
    required Future<bool> Function(String) validateCandidate,
  }) async {
    final specs = externalToolSpecsForCurrentPlatform();
    final spec = specs[tool]!;
    final trimmed = currentPath.trim();

    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    for (final candidate in spec.candidatePaths) {
      try {
        if (!await toolPathExistsIfAbsolute(candidate)) {
          continue;
        }
        if (await validateCandidate(candidate)) {
          await onPersist(candidate);
          logger.i('自动发现 ${spec.displayName}=$candidate');
          return candidate;
        }
      } catch (e, s) {
        logger.w('探测 ${spec.displayName} 失败 candidate=$candidate error=$e');
        logger.d('探测异常堆栈: $s');
      }
    }

    return trimmed.isNotEmpty ? trimmed : fallbackCommand;
  }

  Future<void> _validateExternalTools() async {
    if (!mounted) return;
    state = state.copyWith(isCheckingTools: true, toolCheckMessage: null);
    try {
      final ffmpegOk = await ffmpegService.validate();
      if (!mounted) return;
      if (!ffmpegOk) {
        const message = 'FFmpeg 不可用，请到设置页修复路径';
        state = state.copyWith(
          isCheckingTools: false,
          areToolsReady: false,
          toolCheckMessage: message,
        );
        vm._emitSnackbar(message);
        return;
      }

      final ffprobeOk = await ffprobeService.validate();
      if (!mounted) return;
      if (!ffprobeOk) {
        const message = 'FFprobe 不可用，请到设置页修复路径';
        state = state.copyWith(
          isCheckingTools: false,
          areToolsReady: false,
          toolCheckMessage: message,
        );
        vm._emitSnackbar(message);
        return;
      }

      state = state.copyWith(
        isCheckingTools: false,
        areToolsReady: true,
        toolCheckMessage: null,
        errorMessage: null,
      );
    } catch (e, s) {
      if (!mounted) return;
      vm._reportError('工具校验失败', e, s, userMessage: '工具校验失败：$e');
      const message = '工具校验失败，请前往设置页修复路径';
      state = state.copyWith(
        isCheckingTools: false,
        areToolsReady: false,
        toolCheckMessage: message,
      );
      vm._emitSnackbar(message);
    }
  }

  Future<void> refreshExternalToolsStatus() async {
    try {
      await _setupExternalTools();
      if (!mounted) return;
      await _validateExternalTools();
    } catch (e, s) {
      vm._reportError(
        'refreshExternalToolsStatus 失败',
        e,
        s,
        userMessage: '刷新工具状态失败：$e',
      );
    }
  }
}
