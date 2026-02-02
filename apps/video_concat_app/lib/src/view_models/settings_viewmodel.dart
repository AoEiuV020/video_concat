import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';
import 'providers.dart';
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
    final prefs = ref.read(preferencesRepositoryProvider);
    final path = await prefs.getFFmpegPath();

    if (path != null) {
      state = state.copyWith(
        settings: AppSettings(ffmpegPath: path),
      );
    }

    await _validateCurrentPath();
  }

  Future<void> _validateCurrentPath() async {
    state = state.copyWith(isValidating: true);

    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffmpeg.ffmpegPath = state.settings.ffmpegPath;
    final isValid = await ffmpeg.validate();

    state = state.copyWith(
      isFFmpegValid: isValid,
      isValidating: false,
    );
  }

  /// 更新 FFmpeg 路径
  Future<void> updateFFmpegPath(String path) async {
    state = state.copyWith(
      settings: AppSettings(ffmpegPath: path),
    );

    await ref.read(preferencesRepositoryProvider).saveFFmpegPath(path);
    await _validateCurrentPath();
  }

  /// 浏览选择 FFmpeg 路径
  Future<void> browseFFmpegPath() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择 FFmpeg 可执行文件',
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      await updateFFmpegPath(result.files.single.path!);
    }
  }
}
