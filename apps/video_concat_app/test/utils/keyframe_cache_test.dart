import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_concat_app/src/utils/keyframe_cache.dart';

/// PTS-only 关键帧快捷构造
List<Keyframe> _kfs(List<int> ptsList) =>
    ptsList.map((p) => Keyframe(ptsUs: p)).toList();

/// PTS+DTS 关键帧快捷构造
List<Keyframe> _kfsDts(List<(int, int?)> pairs) =>
    pairs.map((p) => Keyframe(ptsUs: p.$1, dtsUs: p.$2)).toList();

void main() {
  group('KeyframeCache.isCovered', () {
    test('空缓存：未覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.isCovered(50000000), false);
    });

    test('目标在已查询区间内：已覆盖', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, _kfs([15000000, 20000000]));
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
      cache.addRange(10000000, 30000000, _kfs([15000000]));
      cache.addRange(25000000, 55000000, _kfs([40000000]));
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
      cache.addRange(10000000, 20000000, _kfs([15000000]));
      cache.addRange(40000000, 50000000, _kfs([45000000]));
      cache.addRange(15000000, 45000000, _kfs([30000000]));
      expect(cache.isCovered(10000000), true);
      expect(cache.isCovered(30000000), true);
      expect(cache.isCovered(50000000), true);
    });

    test('关键帧去重并排序', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 20000000, _kfs([5000000, 10000000]));
      cache.addRange(5000000, 25000000, _kfs([10000000, 20000000]));
      expect(cache.keyframes, [5000000, 10000000, 20000000]);
    });
  });

  group('KeyframeCache.findNearest', () {
    test('精确命中', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNearest(4004000), 4004000);
    });

    test('取更近的前关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNearest(5000000), 4004000);
    });

    test('取更近的后关键帧', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNearest(7000000), 8008000);
    });

    test('目标在最后一个关键帧之后', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNearest(99000000), 8008000);
    });

    test('目标在第一个关键帧之前', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(2000000, 30000000, _kfs([4004000, 8008000]));
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
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findPrevious(8008000), 4004000);
    });

    test('精确匹配时不返回自身', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findPrevious(4004000), 0);
    });

    test('第一个关键帧无前驱', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000]));
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
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNext(0), 4004000);
    });

    test('精确匹配时不返回自身', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNext(4004000), 8008000);
    });

    test('最后一个关键帧无后继', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfs([0, 4004000, 8008000]));
      expect(cache.findNext(8008000), isNull);
    });

    test('空缓存返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.findNext(5000000), isNull);
    });
  });

  group('KeyframeCache.getDts', () {
    test('返回对应的 DTS', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 30000000, _kfsDts([
        (0, null),
        (2083000, 2075000),
        (4167000, 4158000),
      ]));
      expect(cache.getDts(2083000), 2075000);
      expect(cache.getDts(4167000), 4158000);
    });

    test('DTS 为 N/A 时返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 10000000, _kfsDts([(0, null)]));
      expect(cache.getDts(0), isNull);
    });

    test('不存在的 PTS 返回 null', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 10000000, _kfsDts([(0, null)]));
      expect(cache.getDts(9999999), isNull);
    });

    test('多次 addRange 合并 DTS 映射', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(0, 10000000, _kfsDts([(0, null), (2083000, 2075000)]));
      cache.addRange(2000000, 20000000, _kfsDts([(4167000, 4158000)]));
      expect(cache.getDts(2083000), 2075000);
      expect(cache.getDts(4167000), 4158000);
    });
  });

  group('KeyframeCache.isCoveredRange', () {
    test('完全在同一区间内', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 50000000, _kfs([20000000, 30000000]));
      expect(cache.isCoveredRange(15000000, 45000000), true);
    });

    test('跨越不连续区间', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, _kfs([20000000]));
      cache.addRange(50000000, 70000000, _kfs([60000000]));
      expect(cache.isCoveredRange(20000000, 60000000), false);
    });

    test('空缓存返回 false', () {
      final cache = KeyframeCache(durationUs: 120000000);
      expect(cache.isCoveredRange(0, 10000000), false);
    });

    test('区间边界精确匹配', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.isCoveredRange(10000000, 30000000), true);
    });
  });

  group('KeyframeCache.coveredRangeEnd', () {
    test('返回包含位置的区间右端点', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeEnd(20000000), 30000000);
    });

    test('位置在边界上', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeEnd(30000000), 30000000);
    });

    test('位置不在任何区间内', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeEnd(40000000), isNull);
    });

    test('合并后的区间返回正确端点', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 20000000, []);
      cache.addRange(20500000, 40000000, []); // gap 0.5s < 1s → 合并
      expect(cache.coveredRangeEnd(15000000), 40000000);
    });
  });

  group('KeyframeCache.coveredRangeStart', () {
    test('返回包含位置的区间左端点', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeStart(20000000), 10000000);
    });

    test('位置在边界上', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeStart(10000000), 10000000);
    });

    test('位置不在任何区间内', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(10000000, 30000000, []);
      expect(cache.coveredRangeStart(5000000), isNull);
    });
  });

  group('KeyframeCache 边界处理', () {
    test('start < 0 截断为 0', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(-5000000, 10000000, _kfs([0]));
      expect(cache.isCovered(0), true);
    });

    test('end > 视频时长截断', () {
      final cache = KeyframeCache(durationUs: 120000000);
      cache.addRange(100000000, 999000000, _kfs([110000000]));
      expect(cache.isCovered(120000000), true);
    });
  });
}
