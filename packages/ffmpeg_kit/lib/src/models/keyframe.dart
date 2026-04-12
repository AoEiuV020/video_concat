import 'package:meta/meta.dart';

/// 关键帧信息，包含 PTS 和 DTS 时间戳。
///
/// - [ptsUs] 显示时间戳（微秒），用于 seek/inpoint 和 UI 显示
/// - [dtsUs] 解码时间戳（微秒），用于 concat demuxer 的 outpoint
///
/// 对于无 B 帧的编码，DTS = PTS 或 DTS 为 null。
/// 对于含 B 帧的编码（HEVC、H.264 等），DTS < PTS。
@immutable
class Keyframe {
  /// 显示时间戳（微秒）
  final int ptsUs;

  /// 解码时间戳（微秒），null 表示不可用
  final int? dtsUs;

  const Keyframe({required this.ptsUs, this.dtsUs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyframe && ptsUs == other.ptsUs && dtsUs == other.dtsUs;

  @override
  int get hashCode => Object.hash(ptsUs, dtsUs);

  @override
  String toString() => 'Keyframe(pts=$ptsUs, dts=$dtsUs)';
}
