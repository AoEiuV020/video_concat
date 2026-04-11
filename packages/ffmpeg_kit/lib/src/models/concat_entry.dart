import 'trim_config.dart';

/// 合并输入条目，包含文件路径和可选的裁剪配置。
class ConcatEntry {
  /// 视频文件路径
  final String filePath;

  /// 裁剪配置（null 或空表示不裁剪）
  final TrimConfig? trimConfig;

  /// 视频总时长（微秒），用于判断是否省略 outpoint
  final int? durationUs;

  const ConcatEntry({
    required this.filePath,
    this.trimConfig,
    this.durationUs,
  });
}
