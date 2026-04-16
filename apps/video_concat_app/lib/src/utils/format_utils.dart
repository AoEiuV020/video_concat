/// 格式化文件大小
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// 格式化秒数为 MM:SS.mmm 或 HH:MM:SS.mmm
String formatDuration(double seconds) {
  final totalMs = (seconds * 1000).round();
  final ms = totalMs % 1000;
  final totalSec = totalMs ~/ 1000;
  final s = totalSec % 60;
  final totalMin = totalSec ~/ 60;
  final m = totalMin % 60;
  final h = totalMin ~/ 60;

  final msStr = ms.toString().padLeft(3, '0');
  final secStr = _pad(s);
  final minStr = _pad(m);

  if (h > 0) {
    final hourStr = _pad(h);
    return '$hourStr:$minStr:$secStr.$msStr';
  }
  return '$minStr:$secStr.$msStr';
}

/// 格式化码率
String formatBitRate(int bps) {
  if (bps >= 1000000) return '${(bps / 1000000).toStringAsFixed(1)} Mbps';
  if (bps >= 1000) return '${(bps / 1000).toStringAsFixed(0)} Kbps';
  return '$bps bps';
}

/// 解析帧率字符串（如 "60/1" → "60 fps"）
String formatFrameRate(String? frameRate) {
  if (frameRate == null || frameRate.isEmpty) return '未知';

  final parts = frameRate.split('/');
  if (parts.length == 2) {
    final num = int.tryParse(parts[0]) ?? 0;
    final den = int.tryParse(parts[1]) ?? 1;
    if (den > 0) {
      return '${(num / den).toStringAsFixed(num % den == 0 ? 0 : 2)} fps';
    }
  }

  return '$frameRate fps';
}

String _pad(int n) => n.toString().padLeft(2, '0');
