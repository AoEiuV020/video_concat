import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';

part 'home_state.freezed.dart';

/// 主页状态
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<VideoItem> videoItems,
    @Default(OutputConfig(baseName: '', extension: 'mp4'))
    OutputConfig outputConfig,
    @Default(ExportOptions()) ExportOptions exportOptions,
    GenerateResult? generateResult,
    GeneratedVideoInfo? lastGeneratedVideo,
    SegmentedOutputSummary? segmentedOutputSummary,
    @Default(false) bool isGenerating,
    @Default(true) bool isCheckingTools,
    @Default(false) bool areToolsReady,
    String? toolCheckMessage,
    String? errorMessage,
    ProbeResult? referenceResult,
    @Default({}) Map<String, bool> videoCompatibility,
  }) = _HomeState;
}
