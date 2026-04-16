import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/ffmpeg_service.dart';
import 'package:ffmpeg_kit/src/models/concat_entry.dart';
import 'package:ffmpeg_kit/src/models/segment_output_options.dart';
import 'package:ffmpeg_kit/src/video_concat_service.dart';

void main() {
  // 测试从 List<String> 到 List<ConcatEntry> 的向后兼容转换
  group('inputPathsToEntries', () {
    test('简单路径列表转换', () {
      final entries = inputPathsToEntries(['/a.mp4', '/b.mp4']);
      expect(entries.length, 2);
      expect(entries[0].filePath, '/a.mp4');
      expect(entries[0].trimConfig, isNull);
      expect(entries[1].filePath, '/b.mp4');
    });
  });

  group('VideoConcatService.concat', () {
    test('未提供 segmentOutput 时继续输出单文件', () async {
      final ffmpeg = _FakeFFmpegService();
      final service = VideoConcatService(ffmpegService: ffmpeg);

      await service.concat(
        entries: const [ConcatEntry(filePath: '/tmp/a.mp4')],
        outputPath: '/tmp/output.mp4',
      );

      expect(ffmpeg.arguments, isNotNull);
      expect(ffmpeg.arguments, contains('/tmp/output.mp4'));
      expect(ffmpeg.arguments, isNot(contains('segment')));
    });

    test('提供 segmentOutput 时切到 segment muxer', () async {
      final ffmpeg = _FakeFFmpegService();
      final service = VideoConcatService(ffmpegService: ffmpeg);

      await service.concat(
        entries: const [ConcatEntry(filePath: '/tmp/a.mp4')],
        outputPath: '/tmp/output.mp4',
        segmentOutput: const SegmentOutputOptions(
          segmentTime: '120.000000',
          outputPattern: '/tmp/output_%03d.mp4',
        ),
      );

      expect(
        ffmpeg.arguments,
        containsAllInOrder([
          '-f',
          'segment',
          '-segment_time',
          '120.000000',
          '-reset_timestamps',
          '1',
          '/tmp/output_%03d.mp4',
        ]),
      );
    });

    test('segmentOutput 带 formatOptions 时追加 segment_format_options', () async {
      final ffmpeg = _FakeFFmpegService();
      final service = VideoConcatService(ffmpegService: ffmpeg);

      await service.concat(
        entries: const [ConcatEntry(filePath: '/tmp/a.mp4')],
        outputPath: '/tmp/output.mp4',
        segmentOutput: const SegmentOutputOptions(
          segmentTime: '120.000000',
          outputPattern: '/tmp/output_%03d.mp4',
          formatOptions: 'movflags=+faststart',
        ),
      );

      expect(
        ffmpeg.arguments,
        containsAllInOrder(['-segment_format_options', 'movflags=+faststart']),
      );
    });
  });
}

final class _FakeFFmpegService extends FFmpegService {
  List<String>? arguments;

  @override
  Future<int> execute({
    required List<String> arguments,
    OutputCallback? onOutput,
  }) async {
    this.arguments = arguments;
    return 0;
  }
}
