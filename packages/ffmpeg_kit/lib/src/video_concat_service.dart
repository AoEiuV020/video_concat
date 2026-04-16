import 'dart:io';

import 'ffmpeg_service.dart';
import 'filelist_builder.dart';
import 'log.dart';
import 'models/concat_entry.dart';

/// 章节信息
class ChapterInfo {
  /// 章节标题
  final String title;

  /// 时长（秒）
  final double duration;

  const ChapterInfo({required this.title, required this.duration});
}

/// 简单路径列表转为 ConcatEntry 列表（向后兼容）
List<ConcatEntry> inputPathsToEntries(List<String> paths) {
  return paths.map((p) => ConcatEntry(filePath: p)).toList();
}

/// 视频合并服务
class VideoConcatService {
  final FFmpegService _ffmpegService;

  VideoConcatService({required FFmpegService ffmpegService})
    : _ffmpegService = ffmpegService;

  /// 合并视频文件（支持裁剪）
  ///
  /// [entries] 合并条目列表（含可选裁剪配置）
  /// [outputPath] 输出文件路径
  /// [preInputArguments] -i 之前的 FFmpeg 参数
  /// [extraArguments] 额外 FFmpeg 输出参数
  /// [chapters] 章节信息
  /// [onOutput] 实时输出回调
  Future<int> concat({
    required List<ConcatEntry> entries,
    required String outputPath,
    List<String> preInputArguments = const [],
    List<String> extraArguments = const [],
    List<ChapterInfo>? chapters,
    OutputCallback? onOutput,
  }) async {
    logger.i('concat 开始 entries=${entries.length} output=$outputPath');
    final tempDir = await Directory.systemTemp.createTemp('video_concat_');
    final listFile = File('${tempDir.path}/filelist.txt');

    final content = buildFilelistContent(entries);
    await listFile.writeAsString(content);
    logger.d('filelist:\n$content');

    final normalizedOutput = outputPath.replaceAll('\\', '/');

    try {
      final hasNoAudio = extraArguments.contains('-an');
      final audioArgs = hasNoAudio ? <String>['-an'] : ['-acodec', 'copy'];
      final filteredExtra = extraArguments.where((a) => a != '-an').toList();

      final chapterArgs = <String>[];
      if (chapters != null && chapters.isNotEmpty) {
        final metadataFile = File('${tempDir.path}/chapters.txt');
        await metadataFile.writeAsString(_buildChapterMetadata(chapters));
        chapterArgs.addAll(['-i', metadataFile.path, '-map_metadata', '1']);
        logger.d('章节数=${chapters.length}');
      }

      final exitCode = await _ffmpegService.execute(
        arguments: [
          '-y',
          ...preInputArguments,
          '-safe',
          '0',
          '-f',
          'concat',
          '-i',
          listFile.path,
          ...chapterArgs,
          '-vcodec',
          'copy',
          ...audioArgs,
          ...filteredExtra,
          normalizedOutput,
        ],
        onOutput: onOutput,
      );
      logger.i('concat 完成 exitCode=$exitCode');
      return exitCode;
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  String _buildChapterMetadata(List<ChapterInfo> chapters) {
    final buffer = StringBuffer(';FFMETADATA1\n');
    var startMs = 0;

    for (final chapter in chapters) {
      final endMs = startMs + (chapter.duration * 1000).round();
      buffer.writeln('[CHAPTER]');
      buffer.writeln('TIMEBASE=1/1000');
      buffer.writeln('START=$startMs');
      buffer.writeln('END=$endMs');
      buffer.writeln('title=${chapter.title}');
      buffer.writeln();
      startMs = endMs;
    }

    return buffer.toString();
  }

  /// 中断合并
  void cancel() => _ffmpegService.cancel();

  /// 是否已取消
  bool get isCancelled => _ffmpegService.isCancelled;
}
