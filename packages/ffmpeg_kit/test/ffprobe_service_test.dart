import 'package:ffmpeg_kit/src/ffprobe_service.dart';
import 'package:test/test.dart';

void main() {
  group('FFprobeService.buildFindKeyframesArgs', () {
    test('局部探测参数构建', () {
      final args = FFprobeService.buildFindKeyframesArgs(
        filePath: '/path/video.mp4',
        startUs: 10000000,
        endUs: 30000000,
      );
      expect(args, contains('-read_intervals'));
      expect(args, contains('10.000000%30.000000'));
      expect(args, contains('-skip_frame'));
      expect(args, contains('nokey'));
      expect(args, contains('-select_streams'));
      expect(args, contains('v:0'));
      expect(args.last, '/path/video.mp4');
    });

    test('全量探测参数构建', () {
      final args = FFprobeService.buildFindKeyframesArgs(
        filePath: '/path/video.mp4',
      );
      expect(args, isNot(contains('-read_intervals')));
      expect(args, contains('-skip_frame'));
      expect(args, contains('nokey'));
      expect(args.last, '/path/video.mp4');
    });
  });

  group('FFprobeService.parseKeyframeOutput', () {
    test('解析多行时间戳', () {
      const output = '0.000000\n4.004000\n8.008000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result, [0, 4004000, 8008000]);
    });

    test('解析空输出', () {
      expect(FFprobeService.parseKeyframeOutput(''), isEmpty);
      expect(FFprobeService.parseKeyframeOutput('\n'), isEmpty);
    });

    test('忽略非数字行', () {
      const output = '0.000000\nN/A\n4.004000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result, [0, 4004000]);
    });

    test('结果按升序排列', () {
      const output = '8.008000\n0.000000\n4.004000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result, [0, 4004000, 8008000]);
    });
  });
}
