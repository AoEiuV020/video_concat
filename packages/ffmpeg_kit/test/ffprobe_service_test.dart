import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/ffprobe_service.dart';
import 'package:ffmpeg_kit/src/models/keyframe.dart';

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
      expect(args, contains('-show_entries'));
      expect(args, contains('frame=pts_time,dts_time'));
      expect(args, contains('-of'));
      expect(args, contains('csv=p=0'));
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
    test('解析 PTS+DTS csv 输出', () {
      const output = '0.000000,N/A\n2.083000,2.075000\n4.167000,4.158000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result.length, 3);
      expect(result[0], const Keyframe(ptsUs: 0, dtsUs: null));
      expect(result[1], const Keyframe(ptsUs: 2083000, dtsUs: 2075000));
      expect(result[2], const Keyframe(ptsUs: 4167000, dtsUs: 4158000));
    });

    test('解析 DTS 全部可用', () {
      const output = '0.000000,0.000000\n4.004000,4.002000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result.length, 2);
      expect(result[0], const Keyframe(ptsUs: 0, dtsUs: 0));
      expect(result[1], const Keyframe(ptsUs: 4004000, dtsUs: 4002000));
    });

    test('解析空输出', () {
      expect(FFprobeService.parseKeyframeOutput(''), isEmpty);
      expect(FFprobeService.parseKeyframeOutput('\n'), isEmpty);
    });

    test('忽略非数字行', () {
      const output = '0.000000,N/A\nN/A,N/A\n4.004000,4.002000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result.length, 2);
      expect(result[0].ptsUs, 0);
      expect(result[1].ptsUs, 4004000);
    });

    test('结果按 PTS 升序排列', () {
      const output = '8.008000,8.000000\n0.000000,N/A\n4.004000,4.002000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result.map((k) => k.ptsUs).toList(), [0, 4004000, 8008000]);
    });

    test('仅 PTS 列（无 DTS 列）', () {
      const output = '0.000000\n4.004000\n';
      final result = FFprobeService.parseKeyframeOutput(output);
      expect(result.length, 2);
      expect(result[0], const Keyframe(ptsUs: 0, dtsUs: null));
      expect(result[1], const Keyframe(ptsUs: 4004000, dtsUs: null));
    });
  });
}
