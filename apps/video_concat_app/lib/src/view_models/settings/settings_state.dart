import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';

part 'settings_state.freezed.dart';

/// 设置页状态
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(AppSettings(ffmpegPath: 'ffmpeg', ffprobePath: 'ffprobe'))
    AppSettings settings,
    @Default(false) bool isFFmpegValid,
    @Default(false) bool isFFprobeValid,
    String? ffmpegVersion,
    String? ffprobeVersion,
    @Default(true) bool isValidating,
    String? errorMessage,
  }) = _SettingsState;
}
