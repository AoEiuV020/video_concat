import 'format_info.dart';
import 'stream_info.dart';

/// ffprobe 探测结果。
class ProbeResult {
  /// 格式信息
  final FormatInfo format;

  /// 媒体流列表
  final List<StreamInfo> streams;

  const ProbeResult({
    required this.format,
    required this.streams,
  });

  /// 从 ffprobe JSON 完整输出解析。
  factory ProbeResult.fromJson(Map<String, dynamic> json) {
    final formatJson = json['format'] as Map<String, dynamic>? ?? {};
    final streamsJson = json['streams'] as List<dynamic>? ?? [];

    return ProbeResult(
      format: FormatInfo.fromJson(formatJson),
      streams: streamsJson
          .map((s) => StreamInfo.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
