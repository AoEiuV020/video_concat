import 'dart:io';

import 'ffmpeg_service.dart';
import 'filelist_builder.dart';
import 'log.dart';
import 'models/concat_entry.dart';
import 'models/segment_output_options.dart';

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

  /// 合并视频文件（支持裁剪和自定义片段拆分）
  ///
  /// [entries] 合并条目列表（含可选裁剪配置）
  /// [outputPath] 输出文件路径
  /// [preInputArguments] -i 之前的 FFmpeg 参数
  /// [extraArguments] 额外 FFmpeg 输出参数
  /// [segmentOutput] 分段输出参数
  /// [chapters] 章节信息
  /// [useCustomSegments] 是否使用 Trim 片段拆分模式
  /// [onOutput] 实时输出回调
  Future<int> concat({
    required List<ConcatEntry> entries,
    required String outputPath,
    List<String> preInputArguments = const [],
    List<String> extraArguments = const [],
    SegmentOutputOptions? segmentOutput,
    List<ChapterInfo>? chapters,
    bool useCustomSegments = false,
    OutputCallback? onOutput,
  }) async {
    logger.i(
      'concat 开始 entries=${entries.length} output=$outputPath useCustomSegments=$useCustomSegments',
    );

    // 自定义片段拆分模式
    if (useCustomSegments) {
      return _splitByCustomSegments(
        entries: entries,
        outputPath: outputPath,
        preInputArguments: preInputArguments,
        extraArguments: extraArguments,
        onOutput: onOutput,
      );
    }

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
          if (segmentOutput == null) normalizedOutput,
          if (segmentOutput != null) ...[
            '-f',
            'segment',
            '-segment_time',
            segmentOutput.segmentTime,
            '-reset_timestamps',
            '1',
            if (segmentOutput.formatOptions != null) ...[
              '-segment_format_options',
              segmentOutput.formatOptions!,
            ],
            segmentOutput.outputPattern.replaceAll('\\', '/'),
          ],
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

  /// 使用 Trim 片段拆分视频
  Future<int> _splitByCustomSegments({
    required List<ConcatEntry> entries,
    required String outputPath,
    required List<String> preInputArguments,
    required List<String> extraArguments,
    OutputCallback? onOutput,
  }) async {
    if (entries.isEmpty) {
      logger.e('_splitByCustomSegments: entries 为空');
      return 1;
    }

    // 获取输出目录和文件信息
    final outputDir = File(outputPath).parent.path;
    final outputFile = File(outputPath).path;
    final baseName = File(
      outputFile,
    ).path.split(RegExp(r'[\\/]')).last.replaceFirst(RegExp(r'\.[^.]*$'), '');
    final extension = outputFile.substring(outputFile.lastIndexOf('.'));

    int globalSegmentIndex = 0;

    // 遍历所有视频，生成对应的片段
    for (final entry in entries) {
      final segments = entry.trimConfig?.segments;
      final inputPath = entry.filePath;

      logger.d('处理视频: $inputPath segmentCount=${segments?.length ?? 0}');

      // 如果有片段，逐个处理
      if (segments != null && segments.isNotEmpty) {
        for (final segment in segments) {
          globalSegmentIndex++;
          final segmentNum = '$globalSegmentIndex'.padLeft(3, '0');
          final segmentPath = '$outputDir/${baseName}_$segmentNum$extension';

          // 微秒转秒
          final startSec = segment.inpoint / 1000000.0;
          final endSec = segment.outpoint / 1000000.0;

          logger.d(
            '处理片段 $globalSegmentIndex: $startSec~$endSec 秒 → $segmentPath',
          );

          final args = [
            '-y',
            ...preInputArguments,
            '-ss',
            startSec.toString(),
            '-to',
            endSec.toString(),
            '-i',
            inputPath,
            '-c:v',
            'copy',
            '-c:a',
            'copy',
            ...extraArguments,
            segmentPath,
          ];

          final exitCode = await _ffmpegService.execute(
            arguments: args,
            onOutput: onOutput,
          );
          if (exitCode != 0) {
            logger.e('片段 $globalSegmentIndex 切割失败: exitCode=$exitCode');
            return 1;
          }
        }
      } else {
        // 无片段时，整个视频作为一个输出
        globalSegmentIndex++;
        final segmentNum = '$globalSegmentIndex'.padLeft(3, '0');
        final segmentPath = '$outputDir/${baseName}_$segmentNum$extension';

        logger.d('处理完整视频 → $segmentPath');

        final args = [
          '-y',
          ...preInputArguments,
          '-i',
          inputPath,
          '-c:v',
          'copy',
          '-c:a',
          'copy',
          ...extraArguments,
          segmentPath,
        ];

        final exitCode = await _ffmpegService.execute(
          arguments: args,
          onOutput: onOutput,
        );
        if (exitCode != 0) {
          logger.e('完整视频复制失败: exitCode=$exitCode');
          return 1;
        }
      }
    }

    logger.i('片段拆分完成: $globalSegmentIndex 个文件');
    return 0;
  }

  /// 中断合并
  void cancel() => _ffmpegService.cancel();

  /// 是否已取消
  bool get isCancelled => _ffmpegService.isCancelled;
}
