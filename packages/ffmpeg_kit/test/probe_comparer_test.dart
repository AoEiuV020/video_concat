import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/models/format_info.dart';
import 'package:ffmpeg_kit/src/models/probe_result.dart';
import 'package:ffmpeg_kit/src/models/stream_info.dart';
import 'package:ffmpeg_kit/src/probe_comparer.dart';

void main() {
  group('ProbeComparer.compare', () {
    test('完全一致时判定兼容', () {
      final comparer = ProbeComparer();
      final reference = _probeResult([_videoStream(), _audioStream()]);

      final result = comparer.compare(
        reference,
        _probeResult([_videoStream(), _audioStream()]),
      );

      expect(result.isCompatible, isTrue);
      expect(result.streamCountMismatch, isNull);
      expect(result.streamDiffs.every((diff) => diff.fields.isEmpty), isTrue);
    });

    test('流数量不一致时直接判定不兼容', () {
      final comparer = ProbeComparer();
      final result = comparer.compare(
        _probeResult([_videoStream(), _audioStream()]),
        _probeResult([_videoStream()]),
      );

      expect(result.isCompatible, isFalse);
      expect(result.streamCountMismatch, '流数量不同: 2 vs 1');
      expect(result.streamDiffs, isEmpty);
    });

    test('视频关键字段不同会记录差异', () {
      final comparer = ProbeComparer();
      final result = comparer.compare(
        _probeResult([_videoStream()]),
        _probeResult([
          _videoStream(width: 1280, height: 720, pixFmt: 'yuv420p'),
        ]),
      );

      expect(result.isCompatible, isFalse);
      expect(result.streamDiffs, hasLength(1));
      expect(
        result.streamDiffs.single.fields.keys,
        containsAll(['width', 'height', 'pixFmt']),
      );
      expect(result.streamDiffs.single.fields['width'], ('1920', '1280'));
    });

    test('音频关键字段不同会记录差异', () {
      final comparer = ProbeComparer();
      final result = comparer.compare(
        _probeResult([_audioStream()]),
        _probeResult([
          _audioStream(sampleRate: '44100', channels: 1, channelLayout: 'mono'),
        ]),
      );

      expect(result.isCompatible, isFalse);
      expect(result.streamDiffs, hasLength(1));
      expect(
        result.streamDiffs.single.fields.keys,
        containsAll(['sampleRate', 'channels', 'channelLayout']),
      );
      expect(result.streamDiffs.single.fields['channels'], ('2', '1'));
    });
  });
}

ProbeResult _probeResult(List<StreamInfo> streams) {
  return ProbeResult(
    format: FormatInfo(
      filename: '/tmp/demo.mp4',
      formatName: 'mov,mp4,m4a,3gp,3g2,mj2',
      formatLongName: 'QuickTime / MOV',
      duration: 10,
      size: 100,
      bitRate: 1000,
      nbStreams: streams.length,
    ),
    streams: streams,
  );
}

StreamInfo _videoStream({
  int width = 1920,
  int height = 1080,
  String pixFmt = 'yuv420p10le',
}) {
  return StreamInfo(
    index: 0,
    codecName: 'hevc',
    codecLongName: 'H.265 / HEVC',
    codecType: 'video',
    profile: 'Main 10',
    width: width,
    height: height,
    pixFmt: pixFmt,
    frameRate: '60/1',
    colorRange: 'tv',
    colorSpace: 'bt2020nc',
    colorTransfer: 'smpte2084',
    colorPrimaries: 'bt2020',
  );
}

StreamInfo _audioStream({
  String sampleRate = '48000',
  int channels = 2,
  String channelLayout = 'stereo',
}) {
  return StreamInfo(
    index: 1,
    codecName: 'aac',
    codecLongName: 'AAC',
    codecType: 'audio',
    profile: 'LC',
    sampleRate: sampleRate,
    channels: channels,
    channelLayout: channelLayout,
  );
}
