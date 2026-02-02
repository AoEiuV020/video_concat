import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_result.freezed.dart';

/// 生成状态
enum GenerateState {
  idle,
  running,
  success,
  failed,
}

/// 生成结果
@freezed
abstract class GenerateResult with _$GenerateResult {
  const factory GenerateResult({
    required GenerateState state,
    required String output,
    String? errorMessage,
  }) = _GenerateResult;
}
