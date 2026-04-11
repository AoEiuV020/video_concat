import 'dart:convert';
import 'dart:io';

import 'models/probe_result.dart';
import 'utils/timestamp.dart';

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

  /// 构建关键帧探测命令参数。
  ///
  /// 指定 [startUs]/[endUs] 时为局部探测（使用 -read_intervals），
  /// 不指定时为全量探测。
  static List<String> buildFindKeyframesArgs({
    required String filePath,
    int? startUs,
    int? endUs,
  }) {
    return [
      '-v', 'quiet',
      if (startUs != null && endUs != null) ...[
        '-read_intervals',
        '${formatTimestampUs(startUs)}%${formatTimestampUs(endUs)}',
      ],
      '-select_streams', 'v:0',
      '-skip_frame', 'nokey',
      '-show_frames',
      '-show_entries', 'frame=pkt_pts_time',
      '-of', 'csv=p=0',
      filePath,
    ];
  }

  /// 解析关键帧探测输出为微秒时间戳列表。
  static List<int> parseKeyframeOutput(String output) {
    final lines = output.split('\n').where((l) => l.trim().isNotEmpty);
    final timestamps = <int>[];
    for (final line in lines) {
      final value = double.tryParse(line.trim());
      if (value != null) {
        timestamps.add(parseTimestampUs(line.trim()));
      }
    }
    timestamps.sort();
    return timestamps;
  }

  /// 在指定时间窗口内查找关键帧。
  ///
  /// [startUs] 查询窗口起点（微秒）
  /// [endUs] 查询窗口终点（微秒）
  /// 返回关键帧时间戳列表（微秒，升序）
  Future<List<int>> findKeyframes(
    String filePath, {
    int? startUs,
    int? endUs,
  }) async {
    final args = buildFindKeyframesArgs(
      filePath: filePath,
      startUs: startUs,
      endUs: endUs,
    );

    final result = await Process.run(
      _ffprobePath,
      args,
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      throw Exception('ffprobe 关键帧探测失败: $error');
    }

    return parseKeyframeOutput(result.stdout as String);
  }
}
