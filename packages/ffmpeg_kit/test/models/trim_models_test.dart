import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/models/trim_config.dart';
import 'package:ffmpeg_kit/src/models/trim_segment.dart';

void main() {
  group('TrimSegment', () {
    test('有效片段', () {
      final seg = TrimSegment(inpoint: 0, outpoint: 4004000);
      expect(seg.isValid, true);
      expect(seg.durationUs, 4004000);
    });

    test('无效片段：outpoint <= inpoint', () {
      expect(TrimSegment(inpoint: 5000000, outpoint: 5000000).isValid, false);
      expect(TrimSegment(inpoint: 5000000, outpoint: 3000000).isValid, false);
    });

    test('无效片段：inpoint 负数', () {
      expect(TrimSegment(inpoint: -1, outpoint: 5000000).isValid, false);
    });

    test('相等性', () {
      final a = TrimSegment(inpoint: 0, outpoint: 1000000);
      final b = TrimSegment(inpoint: 0, outpoint: 1000000);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('TrimConfig', () {
    test('空配置', () {
      const config = TrimConfig(segments: []);
      expect(config.isEmpty, true);
      expect(config.isNotEmpty, false);
    });

    test('有片段的配置', () {
      final config = TrimConfig(
        segments: [
          TrimSegment(inpoint: 0, outpoint: 4004000),
          TrimSegment(inpoint: 60000000, outpoint: 90000000),
        ],
      );
      expect(config.isEmpty, false);
      expect(config.isNotEmpty, true);
      expect(config.segments.length, 2);
    });

    test('相等性', () {
      final a = TrimConfig(
        segments: [TrimSegment(inpoint: 0, outpoint: 1000000)],
      );
      final b = TrimConfig(
        segments: [TrimSegment(inpoint: 0, outpoint: 1000000)],
      );
      expect(a, equals(b));
    });

    test('不等性：片段不同', () {
      final a = TrimConfig(
        segments: [TrimSegment(inpoint: 0, outpoint: 1000000)],
      );
      final b = TrimConfig(
        segments: [TrimSegment(inpoint: 0, outpoint: 2000000)],
      );
      expect(a, isNot(equals(b)));
    });
  });
}
