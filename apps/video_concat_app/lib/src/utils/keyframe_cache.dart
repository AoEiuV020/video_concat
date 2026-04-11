/// 关键帧区间缓存。
///
/// 维护已查询区间和关键帧列表，避免重复探测。
class KeyframeCache {
  /// 视频总时长（微秒）
  final int durationUs;

  /// 已查询区间列表，按 start 升序，不重叠
  final List<(int, int)> _searchedRanges = [];

  /// 已发现的关键帧时间戳列表，升序去重
  final List<int> _keyframes = [];

  /// 相邻区间合并阈值（微秒）：1 秒
  static const _mergeThreshold = 1000000;

  KeyframeCache({required this.durationUs});

  /// 已发现的关键帧列表（只读）
  List<int> get keyframes => List.unmodifiable(_keyframes);

  /// 判断目标时间是否在已查询区间内
  bool isCovered(int targetUs) {
    for (final (start, end) in _searchedRanges) {
      if (targetUs >= start && targetUs <= end) return true;
    }
    return false;
  }

  /// 添加新的查询结果并合并区间
  void addRange(int startUs, int endUs, List<int> newKeyframes) {
    // 边界截断
    final clampedStart = startUs < 0 ? 0 : startUs;
    final clampedEnd = endUs > durationUs ? durationUs : endUs;

    // 合并关键帧
    final keyframeSet = _keyframes.toSet()..addAll(newKeyframes);
    _keyframes
      ..clear()
      ..addAll(keyframeSet)
      ..sort();

    // 添加新区间并合并
    _searchedRanges.add((clampedStart, clampedEnd));
    _mergeRanges();
  }

  /// 合并所有重叠或相邻的区间
  void _mergeRanges() {
    if (_searchedRanges.length <= 1) return;

    _searchedRanges.sort((a, b) => a.$1.compareTo(b.$1));
    final merged = <(int, int)>[];
    var (currentStart, currentEnd) = _searchedRanges.first;

    for (var i = 1; i < _searchedRanges.length; i++) {
      final (nextStart, nextEnd) = _searchedRanges[i];
      if (nextStart <= currentEnd + _mergeThreshold) {
        currentEnd = currentEnd > nextEnd ? currentEnd : nextEnd;
      } else {
        merged.add((currentStart, currentEnd));
        currentStart = nextStart;
        currentEnd = nextEnd;
      }
    }
    merged.add((currentStart, currentEnd));

    _searchedRanges
      ..clear()
      ..addAll(merged);
  }

  /// 在缓存中查找最近关键帧（二分查找）
  ///
  /// 返回与 [targetUs] 时间差最小的关键帧时间戳，
  /// 缓存为空时返回 null。
  int? findNearest(int targetUs) {
    if (_keyframes.isEmpty) return null;

    // 二分查找 upper_bound
    var lo = 0;
    var hi = _keyframes.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_keyframes[mid] <= targetUs) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    // lo = 第一个 > targetUs 的位置
    final int? before = lo > 0 ? _keyframes[lo - 1] : null;
    final int? after = lo < _keyframes.length ? _keyframes[lo] : null;

    if (before == null) return after;
    if (after == null) return before;

    return (targetUs - before) <= (after - targetUs) ? before : after;
  }
}
