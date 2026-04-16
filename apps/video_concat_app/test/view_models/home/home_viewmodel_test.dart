import 'dart:async';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/models/models.dart';
import 'package:video_concat_app/src/repositories/preferences_repository.dart';
import 'package:video_concat_app/src/view_models/home/home_viewmodel.dart';
import 'package:video_concat_app/src/view_models/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeViewModel', () {
    test('分段时长非法时不会启动合并', () async {
      final fakeService = _FakeVideoConcatService(exitCode: 0);
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          videoConcatServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
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

    test('合并成功后会记录最近一次成功产物', () async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          videoConcatServiceProvider.overrideWithValue(
            _FakeVideoConcatService(exitCode: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
      await vm.startGenerate('/tmp/output.mp4');

      final state = container.read(homeViewModelProvider);
      expect(state.lastGeneratedVideo?.outputPath, '/tmp/output.mp4');
      expect(state.lastGeneratedVideo?.fileName, 'output.mp4');
    });

    test('分段成功后会记录多文件摘要并清空单文件产物', () async {
      final fakeService = _FakeVideoConcatService(exitCode: 0);
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          videoConcatServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
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
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          videoConcatServiceProvider.overrideWithValue(
            _FakeVideoConcatService(exitCode: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(homeViewModelProvider.notifier);
      await vm.startGenerate('/tmp/output.mp4');
      vm.reset();

      final state = container.read(homeViewModelProvider);
      expect(state.lastGeneratedVideo, isNull);
    });

    test('dispose 后异步偏好加载不会再访问失效 ref', () async {
      final logs = <String>[];

      await runZoned(
        () async {
          final container = ProviderContainer(
            overrides: [
              preferencesRepositoryProvider.overrideWithValue(
                _DelayedPreferencesRepository(),
              ),
            ],
          );

          container.read(homeViewModelProvider);
          container.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 20));
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
  @override
  Future<String> getLastExtension() async => 'mp4';

  @override
  Future<ExportOptions> loadExportOptions() async => const ExportOptions();

  @override
  Future<void> saveExportOptions(ExportOptions options) async {}
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
}
