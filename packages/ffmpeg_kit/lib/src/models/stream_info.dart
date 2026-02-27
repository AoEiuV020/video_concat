/// 媒体流信息（视频流或音频流）。
class StreamInfo {
  /// 流索引
  final int index;

  /// 编解码器名，如 "hevc"、"aac"
  final String codecName;

  /// 编解码器全名，如 "H.265 / HEVC (High Efficiency Video Coding)"
  final String codecLongName;

  /// 流类型："video" / "audio"
  final String codecType;

  /// 编码配置，如 "Main 10"、"LC"
  final String? profile;

  // ---- 视频流字段 ----

  /// 宽度（像素）
  final int? width;

  /// 高度（像素）
  final int? height;

  /// 像素格式，如 "yuv420p10le"
  final String? pixFmt;

  /// 帧率，如 "60/1"
  final String? frameRate;

  /// 色彩范围，如 "pc"
  final String? colorRange;

  /// 色彩空间，如 "bt2020nc"
  final String? colorSpace;

  /// 传输特性，如 "smpte2084"
  final String? colorTransfer;

  /// 色域，如 "bt2020"
  final String? colorPrimaries;

  // ---- 音频流字段 ----

  /// 采样率（Hz），如 "48000"
  final String? sampleRate;

  /// 声道数
  final int? channels;

  /// 声道布局，如 "stereo"
  final String? channelLayout;

  /// 时长（来自 tags.DURATION）
  final String? duration;

  const StreamInfo({
    required this.index,
    required this.codecName,
    required this.codecLongName,
    required this.codecType,
    this.profile,
    this.width,
    this.height,
    this.pixFmt,
    this.frameRate,
    this.colorRange,
    this.colorSpace,
    this.colorTransfer,
    this.colorPrimaries,
    this.sampleRate,
    this.channels,
    this.channelLayout,
    this.duration,
  });

  /// 是否为视频流。
  bool get isVideo => codecType == 'video';

  /// 是否为音频流。
  bool get isAudio => codecType == 'audio';

  /// 从 ffprobe JSON 的 streams[] 元素解析。
  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};

    return StreamInfo(
      index: json['index'] as int? ?? 0,
      codecName: json['codec_name'] as String? ?? '',
      codecLongName: json['codec_long_name'] as String? ?? '',
      codecType: json['codec_type'] as String? ?? '',
      profile: json['profile'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      pixFmt: json['pix_fmt'] as String?,
      frameRate: json['r_frame_rate'] as String?,
      colorRange: json['color_range'] as String?,
      colorSpace: json['color_space'] as String?,
      colorTransfer: json['color_transfer'] as String?,
      colorPrimaries: json['color_primaries'] as String?,
      sampleRate: json['sample_rate'] as String?,
      channels: json['channels'] as int?,
      channelLayout: json['channel_layout'] as String?,
      duration: tags['DURATION'] as String?,
    );
  }
}
