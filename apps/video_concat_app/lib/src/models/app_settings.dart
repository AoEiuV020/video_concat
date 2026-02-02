import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// 应用设置
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required String ffmpegPath,
  }) = _AppSettings;
}
