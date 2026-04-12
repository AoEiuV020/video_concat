import 'package:meta/meta.dart';

import 'trim_segment.dart';

/// 裁剪配置，包含零到多个裁剪片段。
///
/// 空列表表示不裁剪，使用完整视频。
@immutable
class TrimConfig {
  /// 裁剪片段列表，按 inpoint 升序排列，片段间不重叠
  final List<TrimSegment> segments;

  const TrimConfig({required this.segments});

  bool get isEmpty => segments.isEmpty;
  bool get isNotEmpty => segments.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrimConfig) return false;
    if (segments.length != other.segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  String toString() => 'TrimConfig(${segments.length} segments)';
}
