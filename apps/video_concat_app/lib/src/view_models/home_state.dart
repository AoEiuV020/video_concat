import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/models.dart';

part 'home_state.freezed.dart';

/// 主页状态
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<VideoItem> videoItems,
    @Default(OutputConfig(baseName: '', extension: 'mp4'))
    OutputConfig outputConfig,
    GenerateResult? generateResult,
    @Default(false) bool isGenerating,
  }) = _HomeState;
}
