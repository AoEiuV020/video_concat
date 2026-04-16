import 'package:ffmpeg_kit/ffmpeg_kit.dart';

import '../models/models.dart';

/// 根据视频列表构建章节信息（支持裁剪）
///
/// 优先使用 VideoItem.durationUs（无需再次探测），
/// 如果任何视频缺少 durationUs 则回退到 ffprobe 探测。
///
/// 裁剪场景：每个片段各自成为一个章节。
/// 多片段时标题后缀 " #1"、" #2" 等。
Future<List<ChapterInfo>?> buildChapters({
  required FFprobeService ffprobe,
  required List<VideoItem> items,
}) async {
  // 尝试纯本地构建（不需要 ffprobe）
  final local = buildChaptersFromItems(items);
  if (local != null) return local;

  // 回退：逐个探测
  final chapters = <ChapterInfo>[];
  for (final item in items) {
    final nameWithoutExt = item.fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final segments = item.trimConfig?.segments ?? [];

    if (segments.isEmpty) {
      try {
        final durationUs =
            item.durationUs ??
            ((await ffprobe.probe(item.filePath)).format.duration * 1000000)
                .round();
        chapters.add(
          ChapterInfo(title: nameWithoutExt, duration: durationUs / 1000000),
        );
      } catch (_) {
        return null;
      }
    } else {
      for (var i = 0; i < segments.length; i++) {
        final suffix = segments.length > 1 ? ' #${i + 1}' : '';
        chapters.add(
          ChapterInfo(
            title: '$nameWithoutExt$suffix',
            duration: segments[i].durationUs / 1000000,
          ),
        );
      }
    }
  }
  return chapters;
}

/// 纯本地章节构建（不调用 ffprobe）
///
/// 如果所有无裁剪的视频都有 durationUs，可以直接构建。
/// 否则返回 null，需要回退到探测。
List<ChapterInfo>? buildChaptersFromItems(List<VideoItem> items) {
  final chapters = <ChapterInfo>[];
  for (final item in items) {
    final nameWithoutExt = item.fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final segments = item.trimConfig?.segments ?? [];

    if (segments.isEmpty) {
      if (item.durationUs == null) return null;
      chapters.add(
        ChapterInfo(
          title: nameWithoutExt,
          duration: item.durationUs! / 1000000,
        ),
      );
    } else {
      for (var i = 0; i < segments.length; i++) {
        final suffix = segments.length > 1 ? ' #${i + 1}' : '';
        chapters.add(
          ChapterInfo(
            title: '$nameWithoutExt$suffix',
            duration: segments[i].durationUs / 1000000,
          ),
        );
      }
    }
  }
  return chapters;
}
