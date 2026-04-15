import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_concat_app/src/view_models/video_info/video_info_viewmodel.dart';
import 'package:video_concat_app/src/views/video_info/widgets/video_info_content.dart';

void main() {
  group('VideoInfoContent', () {
    testWidgets('存在视频流时在格式信息前渲染播放区', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoInfoContent(
              filePath: '/videos/sample.mp4',
              data: VideoInfoData(result: _videoProbeResult),
              playbackPreview: const SizedBox(key: Key('preview')),
            ),
          ),
        ),
      );

      expect(find.text('视频预览'), findsOneWidget);
      expect(find.text('格式信息'), findsOneWidget);
      expect(find.byKey(const Key('preview')), findsOneWidget);

      final previewTitleY = tester.getTopLeft(find.text('视频预览')).dy;
      final formatTitleY = tester.getTopLeft(find.text('格式信息')).dy;

      expect(previewTitleY, lessThan(formatTitleY));
    });

    testWidgets('不存在视频流时显示无法预览提示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoInfoContent(
              filePath: '/videos/sample.m4a',
              data: VideoInfoData(result: _audioOnlyProbeResult),
            ),
          ),
        ),
      );

      expect(find.text('视频预览'), findsOneWidget);
      expect(find.text('无视频流，无法预览'), findsOneWidget);
    });
  });
}

const _videoProbeResult = ProbeResult(
  format: FormatInfo(
    filename: 'sample.mp4',
    formatName: 'mov,mp4,m4a,3gp,3g2,mj2',
    formatLongName: 'QuickTime / MOV',
    duration: 12.5,
    size: 1024,
    bitRate: 4096,
    nbStreams: 2,
  ),
  streams: [
    StreamInfo(
      index: 0,
      codecName: 'h264',
      codecLongName: 'H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10',
      codecType: 'video',
      width: 1920,
      height: 1080,
      frameRate: '30/1',
    ),
    StreamInfo(
      index: 1,
      codecName: 'aac',
      codecLongName: 'AAC (Advanced Audio Coding)',
      codecType: 'audio',
      sampleRate: '48000',
      channels: 2,
      channelLayout: 'stereo',
    ),
  ],
);

const _audioOnlyProbeResult = ProbeResult(
  format: FormatInfo(
    filename: 'sample.m4a',
    formatName: 'ipod',
    formatLongName: 'iPod / MPEG-4 Part 14',
    duration: 8,
    size: 512,
    bitRate: 2048,
    nbStreams: 1,
  ),
  streams: [
    StreamInfo(
      index: 0,
      codecName: 'aac',
      codecLongName: 'AAC (Advanced Audio Coding)',
      codecType: 'audio',
      sampleRate: '48000',
      channels: 2,
      channelLayout: 'stereo',
    ),
  ],
);
