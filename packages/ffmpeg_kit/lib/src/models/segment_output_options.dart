/// 分段输出参数。
class SegmentOutputOptions {
  final String segmentTime;
  final String outputPattern;
  final String? formatOptions;

  const SegmentOutputOptions({
    required this.segmentTime,
    required this.outputPattern,
    this.formatOptions,
  });
}
