import 'dart:convert';
import 'dart:io';

import 'log.dart';
import 'models/keyframe.dart';
import 'models/probe_result.dart';
import 'utils/timestamp.dart';

/// FFprobe 服务，用于探测媒体文件信息。
class FFprobeService {
  String ffprobePath = 'ffprobe';

  static final _versionRegex = RegExp(r'ffprobe version\s+([^\s]+)');

  /// 验证 FFprobe 是否可用。
  Future<bool> validate() async {
    try {
      final result = await Process.run(ffprobePath, ['-version']);
      logger.d('validate path=$ffprobePath exitCode=${result.exitCode}');
      return result.exitCode == 0;
    } catch (e, s) {
      logger.e('validate 失败 path=$ffprobePath', error: e, stackTrace: s);
      return false;
    }
  }

  /// 获取 FFprobe 版本号，失败返回 null。
  Future<String?> readVersion() async {
    try {
      final result = await Process.run(ffprobePath, ['-version']);
      if (result.exitCode != 0) {
        logger.w(
          'readVersion 失败 path=$ffprobePath exitCode=${result.exitCode}',
        );
        return null;
      }

      final output = result.stdout.toString();
      final lines = output.split('\n');
      final firstLine = lines.isEmpty ? '' : lines.first.trim();
      final match = _versionRegex.firstMatch(firstLine);
      final version = match?.group(1) ?? firstLine;
      return version.isEmpty ? null : version;
    } catch (e, s) {
      logger.e('readVersion 异常 path=$ffprobePath', error: e, stackTrace: s);
      return null;
    }
  }

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

    ffprobePath = parts.join(separator);
  }

  /// 探测媒体文件信息。
  ///
  /// [filePath] 文件路径
  /// 返回解析后的 [ProbeResult]
  Future<ProbeResult> probe(String filePath) async {
    logger.d('probe file=$filePath');
    final result = await Process.run(ffprobePath, [
      '-v',
      'quiet',
      '-print_format',
      'json',
      '-show_format',
      '-show_streams',
      filePath,
    ], runInShell: Platform.isWindows);

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      logger.e('probe 失败 exitCode=${result.exitCode} error=$error');
      throw Exception('ffprobe 执行失败: $error');
    }

    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final probeResult = ProbeResult.fromJson(json);
    logger.d(
      'probe 完成 streams=${probeResult.streams.length} '
      'duration=${probeResult.format.duration}',
    );
    return probeResult;
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
      '-v',
      'quiet',
      if (startUs != null && endUs != null) ...[
        '-read_intervals',
        '${formatTimestampUs(startUs)}%${formatTimestampUs(endUs)}',
      ],
      '-select_streams',
      'v:0',
      '-skip_frame',
      'nokey',
      '-show_entries',
      'frame=pts_time,dts_time',
      '-of',
      'csv=p=0',
      filePath,
    ];
  }

  /// 解析关键帧探测输出为 [Keyframe] 列表。
  ///
  /// 输入格式为 csv：每行 `pts_time,dts_time`，
  /// DTS 可能为 "N/A"。
  static List<Keyframe> parseKeyframeOutput(String output) {
    final lines = output.split('\n').where((l) => l.trim().isNotEmpty);
    final keyframes = <Keyframe>[];
    for (final line in lines) {
      final parts = line.trim().split(',');
      if (parts.isEmpty) continue;
      final ptsValue = double.tryParse(parts[0]);
      if (ptsValue == null) continue;
      final ptsUs = parseTimestampUs(parts[0]);
      int? dtsUs;
      if (parts.length > 1) {
        final dtsValue = double.tryParse(parts[1]);
        if (dtsValue != null) {
          dtsUs = parseTimestampUs(parts[1]);
        }
      }
      keyframes.add(Keyframe(ptsUs: ptsUs, dtsUs: dtsUs));
    }
    keyframes.sort((a, b) => a.ptsUs.compareTo(b.ptsUs));
    return keyframes;
  }

  /// 在指定时间窗口内查找关键帧。
  ///
  /// [startUs] 查询窗口起点（微秒）
  /// [endUs] 查询窗口终点（微秒）
  /// 返回 [Keyframe] 列表（按 PTS 升序），含 PTS 和 DTS
  Future<List<Keyframe>> findKeyframes(
    String filePath, {
    int? startUs,
    int? endUs,
  }) async {
    final args = buildFindKeyframesArgs(
      filePath: filePath,
      startUs: startUs,
      endUs: endUs,
    );

    logger.d(
      'findKeyframes file=$filePath '
      'window=[${startUs ?? "null"}, ${endUs ?? "null"}]',
    );

    final result = await Process.run(
      ffprobePath,
      args,
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      logger.e(
        'findKeyframes 失败 exitCode=${result.exitCode} '
        'error=$error',
      );
      throw Exception('ffprobe 关键帧探测失败: $error');
    }

    final keyframes = parseKeyframeOutput(result.stdout as String);
    logger.d('findKeyframes 返回 ${keyframes.length} 个关键帧');
    return keyframes;
  }
}
