/// 视频格式（容器）信息。
class FormatInfo {
  /// 文件名
  final String filename;

  /// 格式名称，如 "matroska,webm"
  final String formatName;

  /// 格式全名，如 "Matroska / WebM"
  final String formatLongName;

  /// 时长（秒）
  final double duration;

  /// 文件大小（字节）
  final int size;

  /// 码率（bps）
  final int bitRate;

  /// 流数量
  final int nbStreams;

  const FormatInfo({
    required this.filename,
    required this.formatName,
    required this.formatLongName,
    required this.duration,
    required this.size,
    required this.bitRate,
    required this.nbStreams,
  });

  /// 从 ffprobe JSON 的 format 节点解析。
  factory FormatInfo.fromJson(Map<String, dynamic> json) {
    return FormatInfo(
      filename: json['filename'] as String? ?? '',
      formatName: json['format_name'] as String? ?? '',
      formatLongName: json['format_long_name'] as String? ?? '',
      duration: double.tryParse(json['duration']?.toString() ?? '') ?? 0,
      size: int.tryParse(json['size']?.toString() ?? '') ?? 0,
      bitRate: int.tryParse(json['bit_rate']?.toString() ?? '') ?? 0,
      nbStreams: json['nb_streams'] as int? ?? 0,
    );
  }
}
