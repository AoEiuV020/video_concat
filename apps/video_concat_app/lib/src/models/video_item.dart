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
  }) = _VideoItem;
}
