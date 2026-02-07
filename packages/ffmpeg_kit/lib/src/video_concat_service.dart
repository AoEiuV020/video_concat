import 'dart:io';

import 'ffmpeg_service.dart';

/// 视频合并服务
class VideoConcatService {
  final FFmpegService _ffmpegService;

  VideoConcatService({required FFmpegService ffmpegService})
      : _ffmpegService = ffmpegService;

  /// 合并视频文件
  ///
  /// [inputPaths] 输入文件路径列表（有序）
  /// [outputPath] 输出文件路径
  /// [onOutput] 实时输出回调
  /// 返回退出码
  Future<int> concat({
    required List<String> inputPaths,
    required String outputPath,
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
      return await _ffmpegService.execute(
        arguments: [
          '-safe',
          '0',
          '-f',
          'concat',
          '-i',
          listFile.path,
          '-vcodec',
          'copy',
          '-acodec',
          'copy',
          normalizedOutput,
        ],
        onOutput: onOutput,
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  /// 中断合并
  void cancel() => _ffmpegService.cancel();
}
