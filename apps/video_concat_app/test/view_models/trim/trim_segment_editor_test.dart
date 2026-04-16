import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_concat_app/src/view_models/trim/trim_segment_editor.dart';

void main() {
  group('applyTrimOutpoint', () {
    test('pending inpoint + 虚拟末尾会创建新片段并清空 pending', () {
      final result = applyTrimOutpoint(
        segments: const [],
        pendingInpointUs: 1000000,
        currentPositionUs: 5000000,
        durationUs: 5000000,
        outpointDtsUs: null,
      );

      expect(result.errorMessage, isNull);
      expect(result.pendingInpointUs, isNull);
      expect(result.segments, hasLength(1));
      expect(
        result.segments.single,
        const TrimSegment(
          inpoint: 1000000,
          outpoint: 5000000,
          outpointDtsUs: null,
        ),
      );
    });

    test('新增片段与已有片段重叠时返回错误', () {
      final result = applyTrimOutpoint(
        segments: const [
          TrimSegment(inpoint: 0, outpoint: 2000000, outpointDtsUs: 1900000),
        ],
        pendingInpointUs: 1500000,
        currentPositionUs: 3000000,
        durationUs: 6000000,
        outpointDtsUs: 2900000,
      );

      expect(result.errorMessage, '新片段与已有片段重叠');
      expect(result.pendingInpointUs, 1500000);
      expect(result.segments, hasLength(1));
    });

    test('无 pending 时会更新最后一个片段的 outpoint', () {
      final result = applyTrimOutpoint(
        segments: const [
          TrimSegment(inpoint: 0, outpoint: 2000000, outpointDtsUs: 1900000),
          TrimSegment(
            inpoint: 3000000,
            outpoint: 4000000,
            outpointDtsUs: 3900000,
          ),
        ],
        pendingInpointUs: null,
        currentPositionUs: 5000000,
        durationUs: 6000000,
        outpointDtsUs: 4900000,
      );

      expect(result.errorMessage, isNull);
      expect(result.pendingInpointUs, isNull);
      expect(
        result.segments.last,
        const TrimSegment(
          inpoint: 3000000,
          outpoint: 5000000,
          outpointDtsUs: 4900000,
        ),
      );
    });

    test('无 pending 且没有片段时返回错误', () {
      final result = applyTrimOutpoint(
        segments: const [],
        pendingInpointUs: null,
        currentPositionUs: 2000000,
        durationUs: 6000000,
        outpointDtsUs: 1900000,
      );

      expect(result.errorMessage, '没有可更新的片段');
      expect(result.segments, isEmpty);
    });
  });
}
