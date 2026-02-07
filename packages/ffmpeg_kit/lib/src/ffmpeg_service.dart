import 'dart:convert';
import 'dart:io';

/// FFmpeg 执行回调
typedef OutputCallback = void Function(String output);

/// FFmpeg 服务
class FFmpegService {
  String _ffmpegPath = 'ffmpeg';
  Process? _currentProcess;

  /// 设置 FFmpeg 可执行文件路径
  set ffmpegPath(String path) => _ffmpegPath = path;

  /// 获取 FFmpeg 可执行文件路径
  String get ffmpegPath => _ffmpegPath;

  /// 是否正在执行
  bool get isRunning => _currentProcess != null;

  /// 是否已取消（用于区分正常退出和取消）
  bool _cancelled = false;
  bool get isCancelled => _cancelled;

  /// 验证 FFmpeg 是否可用
  Future<bool> validate() async {
    try {
      final result = await Process.run(_ffmpegPath, ['-version']);
      return result.exitCode == 0;
    } catch (_) {
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
    _currentProcess = await Process.start(_ffmpegPath, arguments);

    _currentProcess!.stdout.transform(utf8.decoder).listen((data) {
      onOutput?.call(data);
    });

    _currentProcess!.stderr.transform(utf8.decoder).listen((data) {
      onOutput?.call(data);
    });

    final exitCode = await _currentProcess!.exitCode;
    _currentProcess = null;
    return exitCode;
  }

  /// 中断当前执行
  void cancel() {
    final process = _currentProcess;
    if (process != null) {
      _cancelled = true;

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
}
