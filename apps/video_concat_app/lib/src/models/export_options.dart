import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_options.freezed.dart';

/// 导出选项
@freezed
abstract class ExportOptions with _$ExportOptions {
  const factory ExportOptions({
    /// 是否展开导出选项面板
    @Default(false) bool showOptions,

    /// 元数据旋转角度（null 表示不设置，0/90/180/270）
    @Default(null) int? rotation,

    /// 去除音频轨
    @Default(false) bool removeAudio,

    /// 去除字幕轨
    @Default(false) bool removeSubtitles,

    /// mp4/mov 快速启动（moov 前置）
    @Default(false) bool fastStart,

    /// 清除元数据
    @Default(false) bool stripMetadata,

    /// 在拼接点添加章节标记
    @Default(false) bool addChapters,

    /// 合并成功后自动打开信息页
    @Default(false) bool autoOpenVideoInfo,

    /// 记住所有导出选择
    @Default(false) bool rememberChoices,
  }) = _ExportOptions;

  const ExportOptions._();

  /// 转换为 FFmpeg 输入选项（放在 -i 之前）
  List<String> toPreInputArgs() {
    if (rotation == null) return [];
    return ['-display_rotation:v:0', '$rotation'];
  }

  /// 转换为 FFmpeg 输出选项（放在 -i 之后）
  List<String> toFFmpegArgs({required String outputExtension}) {
    final args = <String>[];

    if (removeAudio) {
      args.add('-an');
    }

    if (removeSubtitles) {
      args.add('-sn');
    }

    if (stripMetadata) {
      args.addAll(['-map_metadata', '-1']);
    }

    final isMp4Like = outputExtension == 'mp4' || outputExtension == 'mov';
    if (fastStart && isMp4Like) {
      args.addAll(['-movflags', '+faststart']);
    }

    return args;
  }
}
