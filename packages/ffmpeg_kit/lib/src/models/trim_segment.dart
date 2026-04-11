import 'package:meta/meta.dart';

/// 裁剪片段，由一对 inpoint/outpoint 定义。
///
/// 时间戳单位为微秒（µs），已对齐到关键帧。
@immutable
class TrimSegment {
  /// 片段起点（微秒）
  final int inpoint;

  /// 片段终点（微秒）
  final int outpoint;

  const TrimSegment({required this.inpoint, required this.outpoint});

  /// 片段是否有效
  bool get isValid => inpoint >= 0 && outpoint > inpoint;

  /// 片段时长（微秒）
  int get durationUs => outpoint - inpoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrimSegment &&
          inpoint == other.inpoint &&
          outpoint == other.outpoint;

  @override
  int get hashCode => Object.hash(inpoint, outpoint);

  @override
  String toString() => 'TrimSegment($inpoint → $outpoint)';
}
