import 'package:freezed_annotation/freezed_annotation.dart';

part 'output_config.freezed.dart';

/// 输出配置
@freezed
abstract class OutputConfig with _$OutputConfig {
  const factory OutputConfig({
    required String baseName,
    required String extension,
  }) = _OutputConfig;

  const OutputConfig._();

  String get fullName => baseName.isEmpty ? '' : '$baseName.$extension';
}
