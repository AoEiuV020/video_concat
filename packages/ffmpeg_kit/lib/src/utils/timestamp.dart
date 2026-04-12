/// 将 ffprobe 输出的秒字符串解析为微秒。
///
/// 例: "4.004000" → 4004000, "28.028" → 28028000
int parseTimestampUs(String secondsStr) {
  final seconds = double.parse(secondsStr);
  return (seconds * 1000000).round();
}

/// 将微秒格式化为 FFmpeg 可接受的秒字符串。
///
/// 例: 4004000 → "4.004000"
String formatTimestampUs(int us) {
  final seconds = us ~/ 1000000;
  final fraction = (us % 1000000).abs();
  return '$seconds.${fraction.toString().padLeft(6, '0')}';
}

/// 将微秒格式化为用户可读的时间字符串。
///
/// 例: 5445500000 → "01:30:45.500", 65500000 → "01:05.500"
String formatTimestampDisplay(int us) {
  final totalMs = us ~/ 1000;
  final ms = totalMs % 1000;
  final totalSec = totalMs ~/ 1000;
  final sec = totalSec % 60;
  final totalMin = totalSec ~/ 60;
  final min = totalMin % 60;
  final hour = totalMin ~/ 60;

  final msStr = ms.toString().padLeft(3, '0');
  final secStr = sec.toString().padLeft(2, '0');
  final minStr = min.toString().padLeft(2, '0');

  if (hour > 0) {
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minStr:$secStr.$msStr';
  }
  return '$minStr:$secStr.$msStr';
}
