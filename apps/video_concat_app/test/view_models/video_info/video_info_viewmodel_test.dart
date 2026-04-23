import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/view_models/providers.dart';
import 'package:video_concat_app/src/view_models/video_info/video_info_viewmodel.dart';

void main() {
  group('videoInfoProvider', () {
    test('无参考视频时只探测当前文件', () async {
      final ffprobe = _FakeFFprobeService(
        byPath: {
          '/videos/current.mp4': _probeResult(duration: 12, width: 1920),
        },
      );
      final ffmpeg = FFmpegService()..ffmpegPath = '/opt/homebrew/bin/ffmpeg';
      final container = ProviderContainer(
        overrides: [
          ffprobeServiceProvider.overrideWithValue(ffprobe),
          ffmpegServiceProvider.overrideWithValue(ffmpeg),
        ],
      );
      addTearDown(container.dispose);

      final data = await container.read(
        videoInfoProvider('/videos/current.mp4').future,
      );

      expect(ffprobe.probedPaths, ['/videos/current.mp4']);
      expect(ffprobe.ffprobePath, '/opt/homebrew/bin/ffprobe');
      expect(data.result.format.duration, 12);
      expect(data.compareResult, isNull);
    });

    test('有参考视频时会返回兼容性对比结果', () async {
      final ffprobe = _FakeFFprobeService(
        byPath: {
          '/videos/current.mp4': _probeResult(duration: 8, width: 1280),
          '/videos/ref.mp4': _probeResult(duration: 10, width: 1920),
        },
      );
      final container = ProviderContainer(
        overrides: [ffprobeServiceProvider.overrideWithValue(ffprobe)],
      );
      addTearDown(container.dispose);

      final data = await container.read(
        videoInfoProvider(
          '/videos/current.mp4',
          refPath: '/videos/ref.mp4',
        ).future,
      );

      expect(ffprobe.probedPaths, ['/videos/current.mp4', '/videos/ref.mp4']);
      expect(data.compareResult, isNotNull);
      expect(data.compareResult!.isCompatible, isFalse);
      expect(data.compareResult!.streamDiffs.single.fields['width'], (
        '1920',
        '1280',
      ));
    });

    test('探测失败时会向上抛出异常', () async {
      final ffprobe = _FakeFFprobeService(errors: {'/videos/bad.mp4': 'boom'});
      final container = ProviderContainer(
        overrides: [ffprobeServiceProvider.overrideWithValue(ffprobe)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(videoInfoProvider('/videos/bad.mp4').future),
        throwsA(isA<StateError>()),
      );
    });
  });
}

final class _FakeFFprobeService extends FFprobeService {
  final Map<String, ProbeResult> byPath;
  final Map<String, String> errors;
  final List<String> probedPaths = [];

  _FakeFFprobeService({this.byPath = const {}, this.errors = const {}});

  @override
  Future<ProbeResult> probe(String filePath) async {
    probedPaths.add(filePath);
    final error = errors[filePath];
    if (error != null) {
      throw StateError(error);
    }

    final result = byPath[filePath];
    if (result == null) {
      throw StateError('missing probe result for $filePath');
    }
    return result;
  }
}

ProbeResult _probeResult({required double duration, required int width}) {
  return ProbeResult(
    format: FormatInfo(
      filename: '/tmp/demo.mp4',
      formatName: 'mov,mp4,m4a,3gp,3g2,mj2',
      formatLongName: 'QuickTime / MOV',
      duration: duration,
      size: 100,
      bitRate: 1000,
      nbStreams: 1,
    ),
    streams: [
      StreamInfo(
        index: 0,
        codecName: 'hevc',
        codecLongName: 'H.265 / HEVC',
        codecType: 'video',
        profile: 'Main 10',
        width: width,
        height: 1080,
        pixFmt: 'yuv420p10le',
        frameRate: '60/1',
        colorRange: 'tv',
        colorSpace: 'bt2020nc',
        colorTransfer: 'smpte2084',
        colorPrimaries: 'bt2020',
      ),
    ],
  );
}
