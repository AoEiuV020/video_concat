import 'package:flutter_test/flutter_test.dart';
import 'package:video_concat_app/src/utils/keyframe_cache.dart';

void main() {
  group('KeyframeCache.isCovered', () {
    test('空缓存：未覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.isCovered(50000000), false);
    });

    test('目标在已查询区间内：已覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, [15000000, 20000000]);
      expect(cache.isCovered(20000000), true);
    });

    test('目标在区间边界上：已覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.isCovered(10000000), true);
      expect(cache.isCovered(30000000), true);
    });

    test('目标在区间外：未覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.isCovered(9999999), false);
      expect(cache.isCovered(30000001), false);
    });
  });

  group('KeyframeCache.addRange 区间合并', () {
    test('不相邻的区间保持独立', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      cache.addRange(50000000, 70000000, []);
      expect(cache.isCovered(40000000), false);
    });

    test('重叠区间合并', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, [15000000]);
      cache.addRange(25000000, 55000000, [40000000]);
      expect(cache.isCovered(10000000), true);
      expect(cache.isCovered(40000000), true);
      expect(cache.isCovered(55000000), true);
    });

    test('相邻区间（间距 ≤ 1s）合并', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      cache.addRange(30500000, 50000000, []); // gap 0.5s < 1s
      expect(cache.isCovered(30250000), true);
    });

    test('三个区间合并为一个', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 20000000, [15000000]);
      cache.addRange(40000000, 50000000, [45000000]);
      cache.addRange(15000000, 45000000, [30000000]);
      expect(cache.isCovered(10000000), true);
      expect(cache.isCovered(30000000), true);
      expect(cache.isCovered(50000000), true);
    });

    test('关键帧去重并排序', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 20000000, [5000000, 10000000]);
      cache.addRange(5000000, 25000000, [10000000, 20000000]);
      expect(cache.keyframes, [5000000, 10000000, 20000000]);
    });
  });

  group('KeyframeCache.findNearest', () {
    test('精确命中', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNearest(4004000), 4004000);
    });

    test('取更近的前关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNearest(5000000), 4004000);
    });

    test('取更近的后关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNearest(7000000), 8008000);
    });

    test('目标在最后一个关键帧之后', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNearest(99000000), 8008000);
    });

    test('目标在第一个关键帧之前', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(2000000, 30000000, [4004000, 8008000]);
      expect(cache.findNearest(1000000), 4004000);
    });

    test('空缓存返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.findNearest(5000000), isNull);
    });
  });

  group('KeyframeCache.findPrevious', () {
    test('返回前一个关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findPrevious(8008000), 4004000);
    });

    test('精确匹配时不返回自身', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findPrevious(4004000), 0);
    });

    test('第一个关键帧无前驱', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000]);
      expect(cache.findPrevious(0), isNull);
    });

    test('空缓存返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.findPrevious(5000000), isNull);
    });
  });

  group('KeyframeCache.findNext', () {
    test('返回后一个关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNext(0), 4004000);
    });

    test('精确匹配时不返回自身', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNext(4004000), 8008000);
    });

    test('最后一个关键帧无后继', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, [0, 4004000, 8008000]);
      expect(cache.findNext(8008000), isNull);
    });

    test('空缓存返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.findNext(5000000), isNull);
    });
  });

  group('KeyframeCache 边界处理', () {
    test('start < 0 截断为 0', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(-5000000, 10000000, [0]);
      expect(cache.isCovered(0), true);
    });

    test('end > 视频时长截断', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(100000000, 999000000, [110000000]);
      expect(cache.isCovered(120000000), true);
    });
  });
}
