import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_video_info.freezed.dart';

/// 最近一次成功生成的产物信息。
@freezed
abstract class GeneratedVideoInfo with _$GeneratedVideoInfo {
  const factory GeneratedVideoInfo({
    required String outputPath,
    required String fileName,
  }) = _GeneratedVideoInfo;
}
