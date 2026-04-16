import 'package:ffmpeg_kit/ffmpeg_kit.dart';

/// 将分段时长输入解析为 FFmpeg 可接受的秒字符串。
String parseSegmentDurationText(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('请输入分段时长');
  }

  if (!trimmed.contains(':')) {
    final seconds = double.tryParse(trimmed);
    if (seconds == null) {
      throw const FormatException('分段时长格式无效');
    }
    if (seconds <= 0) {
      throw const FormatException('分段时长必须大于 0');
    }
    return formatTimestampUs((seconds * 1000000).round());
  }

  final us = _parseDisplayTimestampUs(trimmed);
  if (us <= 0) {
    throw const FormatException('分段时长必须大于 0');
  }
  return formatTimestampUs(us);
}

/// 校验并规范化分段文件名模板。
String validateSegmentFilenameTemplate(String input) {
  final trimmed = input.trim();
  final normalized = trimmed.isEmpty ? '%filename%_%03d' : trimmed;

  if (!normalized.contains('%filename%')) {
    throw const FormatException('文件名模板必须包含 %filename%');
  }
  if (!normalized.contains('%03d')) {
    throw const FormatException('文件名模板必须包含 %03d');
  }
  return normalized;
}

int _parseDisplayTimestampUs(String input) {
  final parts = input.split(':');
  if (parts.length != 2 && parts.length != 3) {
    throw const FormatException('分段时长格式无效');
  }

  final seconds = double.tryParse(parts.last);
  if (seconds == null || seconds < 0 || seconds >= 60) {
    throw const FormatException('分段时长格式无效');
  }

  final minutes = int.tryParse(parts[parts.length - 2]);
  if (minutes == null || minutes < 0 || minutes >= 60) {
    throw const FormatException('分段时长格式无效');
  }

  final hours = parts.length == 3 ? int.tryParse(parts.first) : 0;
  if (hours == null || hours < 0) {
    throw const FormatException('分段时长格式无效');
  }

  final totalSeconds = hours * 3600 + minutes * 60 + seconds;
  return (totalSeconds * 1000000).round();
}
