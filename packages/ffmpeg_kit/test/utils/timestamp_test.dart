import 'package:ffmpeg_kit/src/utils/timestamp.dart';
import 'package:test/test.dart';

void main() {
  group('parseTimestampUs', () {
    test('解析整数秒字符串', () {
      expect(parseTimestampUs('4'), 4000000);
    });

    test('解析浮点秒字符串', () {
      expect(parseTimestampUs('4.004000'), 4004000);
    });

    test('解析高精度字符串', () {
      expect(parseTimestampUs('1.500000'), 1500000);
    });

    test('解析零', () {
      expect(parseTimestampUs('0'), 0);
      expect(parseTimestampUs('0.000000'), 0);
    });

    test('解析 ffprobe 典型输出（无尾零）', () {
      expect(parseTimestampUs('28.028'), 28028000);
    });
  });

  group('formatTimestampUs', () {
    test('格式化整数微秒为秒字符串', () {
      expect(formatTimestampUs(4004000), '4.004000');
    });

    test('格式化零', () {
      expect(formatTimestampUs(0), '0.000000');
    });

    test('格式化整秒', () {
      expect(formatTimestampUs(60000000), '60.000000');
    });

    test('格式化小数微秒', () {
      expect(formatTimestampUs(1500000), '1.500000');
    });
  });

  group('formatTimestampDisplay', () {
    test('格式化为可读时间（含小时）', () {
      // 1h 30m 45s 500ms
      expect(formatTimestampDisplay(5445500000), '01:30:45.500');
    });

    test('格式化为可读时间（无小时）', () {
      expect(formatTimestampDisplay(65500000), '01:05.500');
    });

    test('格式化零', () {
      expect(formatTimestampDisplay(0), '00:00.000');
    });
  });
}
