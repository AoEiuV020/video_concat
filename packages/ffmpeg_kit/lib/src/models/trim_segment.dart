import 'package:meta/meta.dart';

/// 裁剪片段，由一对 inpoint/outpoint 定义。
///
/// 时间戳单位为微秒（µs），已对齐到关键帧。
/// 语义为左闭右开区间 [inpoint, outpoint)。
///
/// - [inpoint] 基于 PTS（seek 使用 PTS，正确包含起始关键帧）
/// - [outpoint] 基于 PTS（用于 UI 显示和时长计算）
/// - [outpointDtsUs] 基于 DTS（用于 concat demuxer outpoint，排除边界关键帧）
@immutable
class TrimSegment {
  /// 片段起点（微秒，PTS）
  final int inpoint;

  /// 片段终点（微秒，PTS），用于 UI 显示和时长计算
  final int outpoint;

  /// 片段终点的 DTS（微秒），用于 concat demuxer outpoint。
  ///
  /// 为 null 时回退到 [outpoint]（适用于无 B 帧的编码）。
  final int? outpointDtsUs;

  const TrimSegment({
    required this.inpoint,
    required this.outpoint,
    this.outpointDtsUs,
  });

  /// 片段是否有效
  bool get isValid => inpoint >= 0 && outpoint > inpoint;

  /// 片段时长（微秒），基于 PTS 计算
  int get durationUs => outpoint - inpoint;

  /// 用于 concat demuxer 的 outpoint 值（优先使用 DTS）
  int get effectiveOutpoint => outpointDtsUs ?? outpoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrimSegment &&
          inpoint == other.inpoint &&
          outpoint == other.outpoint &&
          outpointDtsUs == other.outpointDtsUs;

  @override
  int get hashCode => Object.hash(inpoint, outpoint, outpointDtsUs);

  @override
  String toString() =>
      'TrimSegment($inpoint → $outpoint${outpointDtsUs != null ? ' dts=$outpointDtsUs' : ''})';
}
