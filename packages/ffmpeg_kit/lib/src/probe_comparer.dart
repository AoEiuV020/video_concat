import 'models/probe_compare_result.dart';
import 'models/probe_result.dart';
import 'models/stream_diff.dart';
import 'models/stream_info.dart';

/// 视频兼容性对比工具。
///
/// 对比两个 [ProbeResult]，找出影响免重编码合并的差异。
class ProbeComparer {
  /// 对比标准视频和目标视频。
  ///
  /// [reference] 标准视频（第一个视频）的探测结果
  /// [target] 目标视频的探测结果
  ProbeCompareResult compare(ProbeResult reference, ProbeResult target) {
    final refStreams = reference.streams;
    final tgtStreams = target.streams;

    // 流数量不同直接不兼容
    if (refStreams.length != tgtStreams.length) {
      return ProbeCompareResult(
        isCompatible: false,
        streamDiffs: [],
        streamCountMismatch:
            '流数量不同: ${refStreams.length} vs ${tgtStreams.length}',
      );
    }

    final diffs = <StreamDiff>[];
    var compatible = true;

    for (var i = 0; i < refStreams.length; i++) {
      final diff = _compareStream(refStreams[i], tgtStreams[i]);
      diffs.add(diff);
      if (diff.hasDifferences) compatible = false;
    }

    return ProbeCompareResult(
      isCompatible: compatible,
      streamDiffs: diffs,
    );
  }

  StreamDiff _compareStream(StreamInfo ref, StreamInfo tgt) {
    final fields = <String, (String, String)>{};

    if (ref.isVideo) {
      _addIfDiff(fields, 'codecName', ref.codecName, tgt.codecName);
      _addIfDiff(fields, 'profile', ref.profile ?? '', tgt.profile ?? '');
      _addIfDiff(fields, 'width', '${ref.width}', '${tgt.width}');
      _addIfDiff(fields, 'height', '${ref.height}', '${tgt.height}');
      _addIfDiff(fields, 'pixFmt', ref.pixFmt ?? '', tgt.pixFmt ?? '');
      _addIfDiff(fields, 'frameRate', ref.frameRate ?? '', tgt.frameRate ?? '');
      _addIfDiff(
          fields, 'colorRange', ref.colorRange ?? '', tgt.colorRange ?? '');
      _addIfDiff(
          fields, 'colorSpace', ref.colorSpace ?? '', tgt.colorSpace ?? '');
      _addIfDiff(fields, 'colorTransfer', ref.colorTransfer ?? '',
          tgt.colorTransfer ?? '');
      _addIfDiff(fields, 'colorPrimaries', ref.colorPrimaries ?? '',
          tgt.colorPrimaries ?? '');
    } else if (ref.isAudio) {
      _addIfDiff(fields, 'codecName', ref.codecName, tgt.codecName);
      _addIfDiff(fields, 'profile', ref.profile ?? '', tgt.profile ?? '');
      _addIfDiff(
          fields, 'sampleRate', ref.sampleRate ?? '', tgt.sampleRate ?? '');
      _addIfDiff(fields, 'channels', '${ref.channels}', '${tgt.channels}');
      _addIfDiff(fields, 'channelLayout', ref.channelLayout ?? '',
          tgt.channelLayout ?? '');
    }

    // 流类型本身不同也是差异
    _addIfDiff(fields, 'codecType', ref.codecType, tgt.codecType);

    return StreamDiff(
      index: ref.index,
      codecType: ref.codecType,
      fields: fields,
    );
  }

  void _addIfDiff(
    Map<String, (String, String)> fields,
    String name,
    String refValue,
    String tgtValue,
  ) {
    if (refValue != tgtValue) {
      fields[name] = (refValue, tgtValue);
    }
  }
}
