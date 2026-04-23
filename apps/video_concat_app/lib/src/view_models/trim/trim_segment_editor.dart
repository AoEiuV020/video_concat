import 'package:ffmpeg_kit/ffmpeg_kit.dart';

typedef TrimOutpointResult = ({
  List<TrimSegment> segments,
  int? pendingInpointUs,
  String? errorMessage,
});

/// 应用当前 outpoint 到片段列表。
TrimOutpointResult applyTrimOutpoint({
  required List<TrimSegment> segments,
  required int? pendingInpointUs,
  required int currentPositionUs,
  required int durationUs,
  required int? outpointDtsUs,
}) {
  final isVirtualEnd = currentPositionUs == durationUs;
  final outpoint = isVirtualEnd ? durationUs : currentPositionUs;
  final resolvedOutpointDtsUs = isVirtualEnd ? null : outpointDtsUs;

  if (pendingInpointUs != null) {
    if (outpoint <= pendingInpointUs) {
      return (
        segments: segments,
        pendingInpointUs: pendingInpointUs,
        errorMessage: '终点必须在起点之后',
      );
    }

    final newSegment = TrimSegment(
      inpoint: pendingInpointUs,
      outpoint: outpoint,
      outpointDtsUs: resolvedOutpointDtsUs,
    );

    for (final existing in segments) {
      if (_overlaps(newSegment, existing)) {
        return (
          segments: segments,
          pendingInpointUs: pendingInpointUs,
          errorMessage: '新片段与已有片段重叠',
        );
      }
    }

    final nextSegments = [...segments, newSegment]
      ..sort((a, b) => a.inpoint.compareTo(b.inpoint));
    return (segments: nextSegments, pendingInpointUs: null, errorMessage: null);
  }

  if (segments.isEmpty) {
    return (
      segments: segments,
      pendingInpointUs: null,
      errorMessage: '没有可更新的片段',
    );
  }

  final lastIndex = segments.length - 1;
  final lastSegment = segments[lastIndex];
  if (outpoint <= lastSegment.inpoint) {
    return (
      segments: segments,
      pendingInpointUs: null,
      errorMessage: '终点必须在起点之后',
    );
  }

  final updatedSegment = TrimSegment(
    inpoint: lastSegment.inpoint,
    outpoint: outpoint,
    outpointDtsUs: resolvedOutpointDtsUs,
  );

  for (var i = 0; i < segments.length - 1; i++) {
    if (_overlaps(updatedSegment, segments[i])) {
      return (
        segments: segments,
        pendingInpointUs: null,
        errorMessage: '更新后的片段与已有片段重叠',
      );
    }
  }

  final nextSegments = [...segments];
  nextSegments[lastIndex] = updatedSegment;
  return (segments: nextSegments, pendingInpointUs: null, errorMessage: null);
}

bool _overlaps(TrimSegment a, TrimSegment b) {
  return a.inpoint < b.outpoint && b.inpoint < a.outpoint;
}
