import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_item.freezed.dart';

/// 视频项
@freezed
abstract class VideoItem with _$VideoItem {
  const factory VideoItem({
    required String id,
    required String filePath,
    required String fileName,
    required int fileSize,

    /// 裁剪配置（null 表示不裁剪）
    TrimConfig? trimConfig,

    /// 视频总时长（微秒），由探测工具获取
    int? durationUs,
  }) = _VideoItem;
}
