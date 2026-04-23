import 'dart:io';

import 'tool_candidate_paths.dart';

/// 支持的外部工具。
enum ExternalTool { ffmpeg, ffprobe }

/// 判断路径是否为绝对路径（支持 Unix/Windows）。
bool isAbsoluteToolPath(String path) {
  return path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
}

/// 仅在绝对路径时检查文件是否存在。
Future<bool> toolPathExistsIfAbsolute(String path) async {
  if (!isAbsoluteToolPath(path)) {
    return true;
  }
  try {
    return File(path).exists();
  } catch (_) {
    return false;
  }
}

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
      candidatePaths: candidatePathsForCurrentPlatform(commandName),
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
