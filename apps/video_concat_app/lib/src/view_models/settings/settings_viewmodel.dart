import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
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
      final path = await prefs.getFFmpegPath();

      if (path != null) {
        state = state.copyWith(settings: AppSettings(ffmpegPath: path));
        logger.d('已加载 ffmpegPath=$path');
      }

      await _validateCurrentPath();
    } catch (e, s) {
      logger.e('_loadSettings 失败', error: e, stackTrace: s);
    }
  }

  Future<void> _validateCurrentPath() async {
    state = state.copyWith(isValidating: true);
    try {
      final ffmpeg = ref.read(ffmpegServiceProvider);
      ffmpeg.ffmpegPath = state.settings.ffmpegPath;
      final isValid = await ffmpeg.validate();

      logger.d(
        '验证 ffmpegPath=${state.settings.ffmpegPath} '
        'isValid=$isValid',
      );

      state = state.copyWith(isFFmpegValid: isValid, isValidating: false);
    } catch (e, s) {
      logger.e('_validateCurrentPath 失败', error: e, stackTrace: s);
      state = state.copyWith(isFFmpegValid: false, isValidating: false);
    }
  }

  /// 更新 FFmpeg 路径
  Future<void> updateFFmpegPath(String path) async {
    logger.d('updateFFmpegPath path=$path');
    try {
      state = state.copyWith(settings: AppSettings(ffmpegPath: path));

      await ref.read(preferencesRepositoryProvider).saveFFmpegPath(path);
      await _validateCurrentPath();
    } catch (e, s) {
      logger.e('updateFFmpegPath 失败', error: e, stackTrace: s);
    }
  }

  /// 浏览选择 FFmpeg 路径
  Future<void> browseFFmpegPath() async {
    logger.d('browseFFmpegPath 打开文件选择');
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: '选择 FFmpeg 可执行文件',
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        await updateFFmpegPath(result.files.single.path!);
      } else {
        logger.d('browseFFmpegPath 用户取消');
      }
    } catch (e, s) {
      logger.e('browseFFmpegPath 失败', error: e, stackTrace: s);
    }
  }
}
