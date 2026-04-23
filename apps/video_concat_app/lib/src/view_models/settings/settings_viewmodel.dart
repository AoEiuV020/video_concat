import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
import '../../utils/external_tools.dart';
import '../providers.dart';
import 'settings_state.dart';

part 'settings_viewmodel.g.dart';

/// 设置 ViewModel
@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = ref.read(preferencesRepositoryProvider);
      var ffmpegPath = await prefs.getFFmpegPath();
      var ffprobePath = await prefs.getFFprobePath();

      if (ffmpegPath == null || ffmpegPath.isEmpty) {
        ffmpegPath = await _autoDiscoverAndPersist(ExternalTool.ffmpeg);
      }
      if (ffprobePath == null || ffprobePath.isEmpty) {
        ffprobePath = await _autoDiscoverAndPersist(ExternalTool.ffprobe);
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

      await _validateCurrentPath();
    } catch (e, s) {
      _reportError('_loadSettings 失败', e, s, userMessage: '加载设置失败：$e');
    }
  }

  Future<void> _validateCurrentPath() async {
    state = state.copyWith(
      isValidating: true,
      errorMessage: null,
      ffmpegVersion: null,
      ffprobeVersion: null,
    );
    try {
      final ffmpeg = ref.read(ffmpegServiceProvider);
      final ffprobe = ref.read(ffprobeServiceProvider);

      ffmpeg.ffmpegPath = state.settings.ffmpegPath;
      ffprobe.ffprobePath = state.settings.ffprobePath;

      final isFFmpegValid = await ffmpeg.validate();
      final isFFprobeValid = await ffprobe.validate();
      final ffmpegVersion = isFFmpegValid ? await ffmpeg.readVersion() : null;
      final ffprobeVersion = isFFprobeValid
          ? await ffprobe.readVersion()
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
      _reportError('_validateCurrentPath 失败', e, s, userMessage: '工具校验失败：$e');
      state = state.copyWith(
        isFFmpegValid: false,
        isFFprobeValid: false,
        isValidating: false,
      );
    }
  }

  /// 更新 FFmpeg 路径
  Future<void> updateFFmpegPath(String path) async {
    await _updateToolPath(ExternalTool.ffmpeg, path);
  }

  /// 更新 FFprobe 路径
  Future<void> updateFFprobePath(String path) async {
    await _updateToolPath(ExternalTool.ffprobe, path);
  }

  /// 按当前输入主动刷新工具状态
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

  Future<void> _saveAndValidate({
    required AppSettings settings,
    required String action,
    required String userMessage,
  }) async {
    try {
      state = state.copyWith(settings: settings, errorMessage: null);

      final prefs = ref.read(preferencesRepositoryProvider);
      await prefs.saveFFmpegPath(settings.ffmpegPath);
      await prefs.saveFFprobePath(settings.ffprobePath);

      await _validateCurrentPath();
    } catch (e, s) {
      _reportError(action, e, s, userMessage: '$userMessage$e');
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

    final discoveredPath = await _autoDiscoverAndPersist(tool);
    if (discoveredPath != null && discoveredPath.isNotEmpty) {
      return discoveredPath;
    }

    final spec = externalToolSpecsForCurrentPlatform()[tool];
    return spec?.commandName ??
        (tool == ExternalTool.ffmpeg ? 'ffmpeg' : 'ffprobe');
  }

  /// 浏览选择 FFmpeg 路径
  Future<void> browseFFmpegPath() async {
    await _browseToolPath(ExternalTool.ffmpeg);
  }

  /// 浏览选择 FFprobe 路径
  Future<void> browseFFprobePath() async {
    await _browseToolPath(ExternalTool.ffprobe);
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
      _reportError(
        'browseToolPath 失败 tool=$toolLabel',
        e,
        s,
        userMessage: '选择文件失败：$e',
      );
    }
  }

  Future<String?> _autoDiscoverAndPersist(ExternalTool tool) async {
    final specs = externalToolSpecsForCurrentPlatform();
    final spec = specs[tool];
    if (spec == null) return null;

    for (final candidate in spec.candidatePaths) {
      try {
        final isValid = await _validateCandidate(tool, candidate);
        if (!isValid) continue;

        final prefs = ref.read(preferencesRepositoryProvider);
        if (tool == ExternalTool.ffmpeg) {
          await prefs.saveFFmpegPath(candidate);
        } else {
          await prefs.saveFFprobePath(candidate);
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
    final ffmpeg = ref.read(ffmpegServiceProvider);
    final ffprobe = ref.read(ffprobeServiceProvider);

    if (!await toolPathExistsIfAbsolute(candidate)) {
      return false;
    }

    if (tool == ExternalTool.ffmpeg) {
      final oldPath = ffmpeg.ffmpegPath;
      ffmpeg.ffmpegPath = candidate;
      final ok = await ffmpeg.validate();
      ffmpeg.ffmpegPath = oldPath;
      return ok;
    }

    final oldPath = ffprobe.ffprobePath;
    ffprobe.ffprobePath = candidate;
    final ok = await ffprobe.validate();
    ffprobe.ffprobePath = oldPath;
    return ok;
  }

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
