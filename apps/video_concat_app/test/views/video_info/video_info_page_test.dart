import 'dart:async';

import 'package:flutter/material.dart';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/view_models/providers.dart';
import 'package:video_concat_app/src/views/video_info/video_info_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoInfoPage', () {
    testWidgets('加载中时显示进度圈', (tester) async {
      final completer = Completer<ProbeResult>();
      final container = ProviderContainer(
        overrides: [
          ffprobeServiceProvider.overrideWithValue(
            _DelayedFFprobeService(resultCompleter: completer),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: VideoInfoPage(filePath: '/videos/current.mp4'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('探测失败时显示错误信息', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ffprobeServiceProvider.overrideWithValue(
            _ThrowingFFprobeService(message: 'probe failed'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: VideoInfoPage(filePath: '/videos/current.mp4'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('获取信息失败'), findsOneWidget);
      expect(find.textContaining('probe failed'), findsOneWidget);
    });

    testWidgets('加载成功且不兼容时显示对比告警', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ffprobeServiceProvider.overrideWithValue(
            _FakeFFprobeService(
              byPath: {
                '/videos/current.mp4': _audioProbeResult(sampleRate: '44100'),
                '/videos/ref.mp4': _audioProbeResult(sampleRate: '48000'),
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: VideoInfoPage(
              filePath: '/videos/current.mp4',
              refPath: '/videos/ref.mp4',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('视频预览'), findsOneWidget);
      expect(find.text('无视频流，无法预览'), findsOneWidget);
      expect(find.text('格式信息'), findsOneWidget);
      expect(find.text('编码参数与参考视频不一致，合并时需要重编码'), findsOneWidget);
    });
  });
}

final class _FakeFFprobeService extends FFprobeService {
  final Map<String, ProbeResult> byPath;

  _FakeFFprobeService({required this.byPath});

  @override
  void deriveFromFFmpegPath(String ffmpegPath) {}

  @override
  Future<ProbeResult> probe(String filePath) async {
    final result = byPath[filePath];
    if (result == null) {
      throw StateError('missing probe result for $filePath');
    }
    return result;
  }
}

final class _DelayedFFprobeService extends FFprobeService {
  final Completer<ProbeResult> resultCompleter;

  _DelayedFFprobeService({required this.resultCompleter});

  @override
  void deriveFromFFmpegPath(String ffmpegPath) {}

  @override
  Future<ProbeResult> probe(String filePath) => resultCompleter.future;
}

final class _ThrowingFFprobeService extends FFprobeService {
  final String message;

  _ThrowingFFprobeService({required this.message});

  @override
  void deriveFromFFmpegPath(String ffmpegPath) {}

  @override
  Future<ProbeResult> probe(String filePath) async {
    throw StateError(message);
  }
}

ProbeResult _audioProbeResult({required String sampleRate}) {
  return ProbeResult(
    format: const FormatInfo(
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
        sampleRate: sampleRate,
        channels: 2,
        channelLayout: 'stereo',
      ),
    ],
  );
}
