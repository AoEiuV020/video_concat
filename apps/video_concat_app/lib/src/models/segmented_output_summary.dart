import 'package:freezed_annotation/freezed_annotation.dart';

part 'segmented_output_summary.freezed.dart';

/// 最近一次成功生成的分段输出摘要。
@freezed
abstract class SegmentedOutputSummary with _$SegmentedOutputSummary {
  const factory SegmentedOutputSummary({
    required String directoryPath,
    required String fileNamePattern,
  }) = _SegmentedOutputSummary;
}
