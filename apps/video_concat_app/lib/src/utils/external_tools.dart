import 'dart:io';

/// 支持的外部工具。
enum ExternalTool { ffmpeg, ffprobe }

/// 外部工具定义：统一维护名称与候选路径。
class ExternalToolSpec {
  final ExternalTool tool;
  final String displayName;
  final String commandName;
  final List<String> candidatePaths;

  const ExternalToolSpec({
    required this.tool,
    required this.displayName,
    required this.commandName,
    required this.candidatePaths,
  });
}

/// 当前平台的外部工具候选定义。
///
/// 将 ffmpeg/ffprobe 的可执行名与常见安装路径集中在一个地方，
/// 供启动自检和设置页复用。
Map<ExternalTool, ExternalToolSpec> externalToolSpecsForCurrentPlatform() {
  final specs = <ExternalTool, ExternalToolSpec>{};
  for (final tool in ExternalTool.values) {
    final commandName = _commandName(tool);
    specs[tool] = ExternalToolSpec(
      tool: tool,
      displayName: _displayName(tool),
      commandName: commandName,
      candidatePaths: _candidatePathsForCurrentPlatform(commandName),
    );
  }
  return specs;
}

String _displayName(ExternalTool tool) {
  switch (tool) {
    case ExternalTool.ffmpeg:
      return 'FFmpeg';
    case ExternalTool.ffprobe:
      return 'FFprobe';
  }
}

String _commandName(ExternalTool tool) {
  switch (tool) {
    case ExternalTool.ffmpeg:
      return Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
    case ExternalTool.ffprobe:
      return Platform.isWindows ? 'ffprobe.exe' : 'ffprobe';
  }
}

List<String> _candidatePathsForCurrentPlatform(String commandName) {
  if (Platform.isMacOS) {
    return [
      '/opt/homebrew/bin/$commandName',
      '/usr/local/bin/$commandName',
      '/usr/bin/$commandName',
      commandName,
    ];
  }

  if (Platform.isLinux) {
    return [
      '/usr/local/bin/$commandName',
      '/usr/bin/$commandName',
      '/snap/bin/$commandName',
      commandName,
    ];
  }

  if (Platform.isWindows) {
    return [
      'C:/ffmpeg/bin/$commandName',
      'C:/Program Files/ffmpeg/bin/$commandName',
      'C:/Program Files (x86)/ffmpeg/bin/$commandName',
      commandName,
    ];
  }

  return [commandName];
}
