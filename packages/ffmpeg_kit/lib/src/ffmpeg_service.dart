import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'log.dart';
import 'utils/timestamp.dart';

/// FFmpeg 执行回调
typedef OutputCallback = void Function(String output);

/// FFmpeg 服务
class FFmpegService {
  String ffmpegPath = 'ffmpeg';
  Process? _currentProcess;

  /// 是否正在执行
  bool get isRunning => _currentProcess != null;

  /// 是否已取消（用于区分正常退出和取消）
  bool _cancelled = false;
  bool get isCancelled => _cancelled;

  /// 验证 FFmpeg 是否可用
  Future<bool> validate() async {
    try {
      final result = await Process.run(ffmpegPath, ['-version']);
      logger.d('validate path=$ffmpegPath exitCode=${result.exitCode}');
      return result.exitCode == 0;
    } catch (e, s) {
      logger.e('validate 失败 path=$ffmpegPath', error: e, stackTrace: s);
      return false;
    }
  }

  /// 执行原始命令
  ///
  /// [arguments] 命令参数列表
  /// [onOutput] 实时输出回调
  /// 返回退出码
  Future<int> execute({
    required List<String> arguments,
    OutputCallback? onOutput,
  }) async {
    _cancelled = false;
    logger.d('execute args=${arguments.join(" ")}');
    _currentProcess = await Process.start(ffmpegPath, arguments);

    _currentProcess!.stdout.transform(utf8.decoder).listen((data) {
      onOutput?.call(data);
    });

    _currentProcess!.stderr.transform(utf8.decoder).listen((data) {
      onOutput?.call(data);
    });

    final exitCode = await _currentProcess!.exitCode;
    _currentProcess = null;
    logger.d('execute 完成 exitCode=$exitCode');
    return exitCode;
  }

  /// 中断当前执行
  void cancel() {
    final process = _currentProcess;
    if (process != null) {
      _cancelled = true;
      logger.i('cancel 中断当前进程');

      // 先尝试发送 'q' 让 FFmpeg 优雅退出
      try {
        process.stdin.writeln('q');
      } catch (_) {
        // 忽略写入错误
      }

      // 如果 FFmpeg 没有响应，强制终止
      Future.delayed(const Duration(milliseconds: 500), () {
        process.kill(ProcessSignal.sigkill);
      });
    }
  }

  /// 提取指定时间点的视频帧画面。
  ///
  /// 使用 -ss 在 -i 之前直接跳转到关键帧，耗时约 50~80ms。
  /// 返回 JPEG 图像字节数据，失败返回 null。
  ///
  /// [filePath] 视频文件路径
  /// [timestampUs] 目标时间（微秒），应为关键帧时间
  /// [maxWidth] 预览图最大宽度（像素），高度按比例缩放
  /// [isHdr] 是否为 HDR 内容，为 true 时自动应用 tone mapping
  Future<Uint8List?> extractFrame({
    required String filePath,
    required int timestampUs,
    int maxWidth = 640,
    bool isHdr = false,
  }) async {
    final timestampStr = formatTimestampUs(timestampUs);
    logger.d('extractFrame file=$filePath ts=$timestampStr isHdr=$isHdr');

    final vf = isHdr
        ? 'zscale=t=linear:npl=100,format=gbrpf32le,'
              'zscale=p=bt709,tonemap=tonemap=hable:desat=0,'
              'zscale=t=bt709:m=bt709:r=tv,format=yuv420p,'
              'scale=$maxWidth:-1'
        : 'scale=$maxWidth:-1';

    final result = await Process.run(ffmpegPath, [
      '-ss',
      timestampStr,
      '-i',
      filePath,
      '-vframes',
      '1',
      '-q:v',
      '5',
      '-vf',
      vf,
      '-f',
      'image2pipe',
      '-vcodec',
      'mjpeg',
      'pipe:1',
    ], stdoutEncoding: null);

    if (result.exitCode != 0) {
      logger.w(
        'extractFrame 失败 exitCode=${result.exitCode} '
        'stderr=${result.stderr}',
      );
      return null;
    }

    final bytes = result.stdout as List<int>;
    if (bytes.isEmpty) {
      logger.w('extractFrame 返回空数据');
      return null;
    }
    logger.d('extractFrame 成功 ${bytes.length} bytes');
    return Uint8List.fromList(bytes);
  }
}
