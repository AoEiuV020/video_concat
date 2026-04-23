import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/models/models.dart';
import 'package:video_concat_app/src/repositories/preferences_repository.dart';
import 'package:video_concat_app/src/view_models/home/home_viewmodel.dart';
import 'package:video_concat_app/src/view_models/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer(
    List overrides, {
    FFmpegService? ffmpegService,
    FFprobeService? ffprobeService,
  }) {
    return ProviderContainer(
      overrides: [
        ffmpegServiceProvider.overrideWithValue(
          ffmpegService ?? _ImmediateFFmpegService(),
        ),
        ffprobeServiceProvider.overrideWithValue(
          ffprobeService ?? _ImmediateFFprobeService(),
        ),
        ...overrides,
      ],
    );
  }

  Future<void> waitInit() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  group('HomeViewModel', () {
    test('启用清除元数据时会关闭拼接点章节', () {
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
      ]);
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
      vm.updateExportOptions(
        const ExportOptions(addChapters: true, stripMetadata: true),
      );

      final options = container.read(homeViewModelProvider).exportOptions;
      expect(options.stripMetadata, isTrue);
      expect(options.addChapters, isFalse);
    });

    test('启用拼接点章节时会关闭清除元数据', () {
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
      ]);
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
      vm.updateExportOptions(const ExportOptions(stripMetadata: true));
      vm.updateExportOptions(
        const ExportOptions(stripMetadata: true, addChapters: true),
      );

      final options = container.read(homeViewModelProvider).exportOptions;
      expect(options.stripMetadata, isFalse);
      expect(options.addChapters, isTrue);
    });

    test('分段时长非法时不会启动合并', () async {
      final fakeService = _FakeVideoConcatService(exitCode: 0);
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
        videoConcatServiceProvider.overrideWithValue(fakeService),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(sub.close);

      final vm = container.read(homeViewModelProvider.notifier);
      await waitInit();
      vm.updateExportOptions(
        const ExportOptions(
          enableSegmentOutput: true,
          segmentDurationText: 'abc',
          segmentFilenameTemplate: '%filename%_%03d',
        ),
      );

      await vm.startGenerate('/tmp/output.mp4');

      final state = container.read(homeViewModelProvider);
      expect(state.generateResult?.state, GenerateState.failed);
      expect(state.generateResult?.errorMessage, '分段时长格式无效');
      expect(fakeService.concatCallCount, 0);
    });

    test('添加视频后会探测参考视频并记录后续兼容性', () async {
      final tempDir = await Directory.systemTemp.createTemp('home-vm-test-');
      addTearDown(() => tempDir.delete(recursive: true));

      final fileA = File('${tempDir.path}/a.mp4')..writeAsStringSync('a');
      final fileB = File('${tempDir.path}/b.mp4')..writeAsStringSync('b');

      final container = createContainer(
        [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
        ],
        ffprobeService: _FakeFFprobeService(
          byPath: {
            fileA.path: _probeResult(duration: 10, width: 1920),
            fileB.path: _probeResult(duration: 8, width: 1280),
          },
        ),
      );
      addTearDown(container.dispose);

      final subscription = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(subscription.close);
      final vm = container.read(homeViewModelProvider.notifier);
      await waitInit();
      await vm.addVideos([fileA.path, fileB.path]);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final state = container.read(homeViewModelProvider);
      expect(state.referenceResult, isNotNull);
      expect(state.videoItems.first.durationUs, 10000000);
      expect(state.videoItems[1].durationUs, 8000000);
      expect(state.videoCompatibility[state.videoItems[1].id], isFalse);
    });

    test('合并成功后会记录最近一次成功产物', () async {
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
        videoConcatServiceProvider.overrideWithValue(
          _FakeVideoConcatService(exitCode: 0),
        ),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(sub.close);

      final vm = container.read(homeViewModelProvider.notifier);
      await waitInit();
      await vm.startGenerate('/tmp/output.mp4');

      final state = container.read(homeViewModelProvider);
      expect(state.lastGeneratedVideo?.outputPath, '/tmp/output.mp4');
      expect(state.lastGeneratedVideo?.fileName, 'output.mp4');
    });

    test('分段成功后会记录多文件摘要并清空单文件产物', () async {
      final fakeService = _FakeVideoConcatService(exitCode: 0);
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
        videoConcatServiceProvider.overrideWithValue(fakeService),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(sub.close);

      final vm = container.read(homeViewModelProvider.notifier);
      await waitInit();
      vm.updateExportOptions(
        const ExportOptions(
          enableSegmentOutput: true,
          segmentDurationText: '120',
          segmentFilenameTemplate: '%filename%_%03d',
        ),
      );

      await vm.startGenerate('/tmp/output.mp4');

      final state = container.read(homeViewModelProvider);
      expect(state.lastGeneratedVideo, isNull);
      expect(state.segmentedOutputSummary?.directoryPath, '/tmp');
      expect(state.segmentedOutputSummary?.fileNamePattern, 'output_%03d.mp4');
      expect(fakeService.lastSegmentOutput?.segmentTime, '120.000000');
      expect(
        fakeService.lastSegmentOutput?.outputPattern,
        '/tmp/output_%03d.mp4',
      );
    });

    test('重置后会清空最近一次成功产物', () async {
      final container = createContainer([
        preferencesRepositoryProvider.overrideWithValue(
          _FakePreferencesRepository(),
        ),
        videoConcatServiceProvider.overrideWithValue(
          _FakeVideoConcatService(exitCode: 0),
        ),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(homeViewModelProvider, (_, _) {});
      addTearDown(sub.close);

      final vm = container.read(homeViewModelProvider.notifier);
      await waitInit();
      await vm.startGenerate('/tmp/output.mp4');
      vm.reset();

      final state = container.read(homeViewModelProvider);
      expect(state.lastGeneratedVideo, isNull);
    });

    test('dispose 后异步偏好加载不会再访问失效 ref', () async {
      final logs = <String>[];

      await runZoned(
        () async {
          final container = createContainer([
            preferencesRepositoryProvider.overrideWithValue(
              _DelayedPreferencesRepository(),
            ),
          ]);

          container.read(homeViewModelProvider);
          container.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 120));
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, message) {
            logs.add(message);
          },
        ),
      );

      expect(
        logs.where((line) => line.contains('Cannot use the Ref')),
        isEmpty,
      );
    });
  });
}

final class _FakePreferencesRepository extends PreferencesRepository {
  _FakePreferencesRepository();

  @override
  Future<String> getLastExtension() async => 'mp4';

  @override
  Future<ExportOptions> loadExportOptions() async => const ExportOptions();

  @override
  Future<void> saveExportOptions(ExportOptions options) async {}

  @override
  Future<String?> getFFmpegPath() async => 'ffmpeg';

  @override
  Future<String?> getFFprobePath() async => 'ffprobe';
}

final class _FakeVideoConcatService extends VideoConcatService {
  final int exitCode;
  int concatCallCount = 0;
  SegmentOutputOptions? lastSegmentOutput;

  _FakeVideoConcatService({required this.exitCode})
    : super(ffmpegService: FFmpegService());

  @override
  Future<int> concat({
    required List<ConcatEntry> entries,
    required String outputPath,
    List<String> preInputArguments = const [],
    List<String> extraArguments = const [],
    SegmentOutputOptions? segmentOutput,
    List<ChapterInfo>? chapters,
    bool useCustomSegments = false,
    OutputCallback? onOutput,
  }) async {
    concatCallCount++;
    lastSegmentOutput = segmentOutput;
    onOutput?.call('done');
    return exitCode;
  }
}

final class _DelayedPreferencesRepository extends PreferencesRepository {
  @override
  Future<String> getLastExtension() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return 'mp4';
  }

  @override
  Future<ExportOptions> loadExportOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return const ExportOptions();
  }

  @override
  Future<String?> getFFmpegPath() async => 'ffmpeg';

  @override
  Future<String?> getFFprobePath() async => 'ffprobe';
}

final class _FakeFFprobeService extends FFprobeService {
  final Map<String, ProbeResult> byPath;

  _FakeFFprobeService({required this.byPath});

  @override
  void deriveFromFFmpegPath(String ffmpegPath) {}

  @override
  Future<bool> validate() async => true;

  @override
  Future<ProbeResult> probe(String filePath) async {
    final result = byPath[filePath];
    if (result == null) {
      throw StateError('missing probe result for $filePath');
    }
    return result;
  }
}

final class _ImmediateFFmpegService extends FFmpegService {
  @override
  Future<bool> validate() async => true;
}

final class _ImmediateFFprobeService extends FFprobeService {
  @override
  Future<bool> validate() async => true;
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
