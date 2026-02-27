import 'dart:convert';
import 'dart:io';

import 'models/probe_result.dart';

/// FFprobe 服务，用于探测媒体文件信息。
class FFprobeService {
  String _ffprobePath = 'ffprobe';

  /// 设置 ffprobe 可执行文件路径。
  set ffprobePath(String path) => _ffprobePath = path;

  /// 获取 ffprobe 可执行文件路径。
  String get ffprobePath => _ffprobePath;

  /// 从 ffmpeg 路径推导 ffprobe 路径。
  ///
  /// 将路径中最后的 "ffmpeg" 替换为 "ffprobe"。
  void deriveFromFFmpegPath(String ffmpegPath) {
    // 处理路径分隔符
    final separator = ffmpegPath.contains('\\') ? '\\' : '/';
    final parts = ffmpegPath.split(separator);

    // 替换最后一段中的 ffmpeg 为 ffprobe
    final last = parts.last.replaceAll('ffmpeg', 'ffprobe');
    parts[parts.length - 1] = last;

    _ffprobePath = parts.join(separator);
  }

  /// 探测媒体文件信息。
  ///
  /// [filePath] 文件路径
  /// 返回解析后的 [ProbeResult]
  Future<ProbeResult> probe(String filePath) async {
    final result = await Process.run(
      _ffprobePath,
      [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        filePath,
      ],
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      throw Exception('ffprobe 执行失败: $error');
    }

    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    return ProbeResult.fromJson(json);
  }
}
