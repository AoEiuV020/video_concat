import 'stream_diff.dart';

/// 两个视频的兼容性对比结果。
class ProbeCompareResult {
  /// 是否兼容（可免重编码合并）
  final bool isCompatible;

  /// 每个流的差异详情
  final List<StreamDiff> streamDiffs;

  /// 流数量不匹配时的描述
  final String? streamCountMismatch;

  const ProbeCompareResult({
    required this.isCompatible,
    required this.streamDiffs,
    this.streamCountMismatch,
  });
}
