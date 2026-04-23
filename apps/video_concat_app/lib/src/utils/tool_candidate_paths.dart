import 'dart:io';

/// 根据当前平台生成工具候选路径列表。
List<String> candidatePathsForCurrentPlatform(String commandName) {
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
