import 'package:ffmpeg_kit/ffmpeg_kit.dart';

import '../models/models.dart';

/// 根据视频列表构建章节信息
///
/// 逐个探测视频时长，以文件名作为章节标题。
/// 任何一个视频探测失败则返回 null。
Future<List<ChapterInfo>?> buildChapters({
  required FFprobeService ffprobe,
  required List<VideoItem> items,
}) async {
  final chapters = <ChapterInfo>[];

  for (final item in items) {
    try {
      final result = await ffprobe.probe(item.filePath);
      final nameWithoutExt =
          item.fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
      chapters.add(ChapterInfo(
        title: nameWithoutExt,
        duration: result.format.duration,
      ));
    } catch (_) {
      return null;
    }
  }

  return chapters;
}
