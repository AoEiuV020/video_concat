import 'dart:io';

import 'ffmpeg_service.dart';

/// 章节信息
class ChapterInfo {
  /// 章节标题
  final String title;

  /// 时长（秒）
  final double duration;

  const ChapterInfo({required this.title, required this.duration});
}

/// 视频合并服务
class VideoConcatService {
  final FFmpegService _ffmpegService;

  VideoConcatService({required FFmpegService ffmpegService})
      : _ffmpegService = ffmpegService;

  /// 合并视频文件
  ///
  /// [inputPaths] 输入文件路径列表（有序）
  /// [outputPath] 输出文件路径
  /// [preInputArguments] -i 之前的 FFmpeg 参数（如 -display_rotation）
  /// [extraArguments] 额外 FFmpeg 输出参数（如 -an, -sn 等）
  /// [chapters] 章节信息（非空时注入章节元数据）
  /// [onOutput] 实时输出回调
  /// 返回退出码
  Future<int> concat({
    required List<String> inputPaths,
    required String outputPath,
    List<String> preInputArguments = const [],
    List<String> extraArguments = const [],
    List<ChapterInfo>? chapters,
    OutputCallback? onOutput,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('video_concat_');
    final listFile = File('${tempDir.path}/filelist.txt');

    // 创建文件列表
    // Windows/Unix: 统一使用正斜杠路径
    final content = inputPaths.map((p) {
      final normalizedPath = p.replaceAll('\\', '/');
      final escapedPath = normalizedPath.replaceAll("'", "'\\''");
      return "file '$escapedPath'";
    }).join('\n');
    await listFile.writeAsString(content);

    // 输出路径也转换为正斜杠
    final normalizedOutput = outputPath.replaceAll('\\', '/');

    try {
      // 根据额外参数调整音频编解码器
      final hasNoAudio = extraArguments.contains('-an');
      final audioArgs = hasNoAudio ? <String>['-an'] : ['-acodec', 'copy'];
      final filteredExtra =
          extraArguments.where((a) => a != '-an').toList();

      // 章节元数据
      final chapterArgs = <String>[];
      if (chapters != null && chapters.isNotEmpty) {
        final metadataFile = File('${tempDir.path}/chapters.txt');
        await metadataFile.writeAsString(_buildChapterMetadata(chapters));
        chapterArgs.addAll(['-i', metadataFile.path, '-map_metadata', '1']);
      }

      return await _ffmpegService.execute(
        arguments: [
          '-y', // 自动覆盖输出文件，不询问
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
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  /// 生成 FFmpeg 章节元数据内容
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
