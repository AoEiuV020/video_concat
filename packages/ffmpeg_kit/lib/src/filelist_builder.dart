import 'models/concat_entry.dart';
import 'utils/timestamp.dart';

/// 根据合并条目列表生成 concat demuxer 文件列表内容。
///
/// 遵循 FFmpeg concat demuxer 格式：
/// - 无裁剪：`file 'path'`
/// - 有裁剪：每片段一条 `file 'path'` + 可选 inpoint/outpoint
/// - inpoint = 0 时省略
/// - outpoint = 视频时长时省略
/// - outpoint 使用 [TrimSegment.effectiveOutpoint]（优先 DTS，实现左闭右开）
String buildFilelistContent(List<ConcatEntry> entries) {
  final buffer = StringBuffer();
  var first = true;

  for (final entry in entries) {
    final escapedPath = entry.filePath
        .replaceAll('\\', '/')
        .replaceAll("'", "'\\''");

    final segments = entry.trimConfig?.segments ?? [];

    if (segments.isEmpty) {
      if (!first) buffer.write('\n');
      buffer.write("file '$escapedPath'");
      first = false;
    } else {
      for (final segment in segments) {
        if (!first) buffer.write('\n');
        buffer.write("file '$escapedPath'");

        if (segment.inpoint > 0) {
          buffer.write('\ninpoint ${formatTimestampUs(segment.inpoint)}');
        }

        final shouldOmitOutpoint =
            entry.durationUs != null && segment.outpoint >= entry.durationUs!;
        if (!shouldOmitOutpoint) {
          buffer.write(
            '\noutpoint ${formatTimestampUs(segment.effectiveOutpoint)}',
          );
        }

        first = false;
      }
    }
  }

  return buffer.toString();
}
