import 'package:flutter/material.dart';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:video_concat_app/src/models/export_options.dart';
import 'package:video_concat_app/src/repositories/preferences_repository.dart';
import 'package:video_concat_app/src/view_models/home/home_viewmodel.dart';
import 'package:video_concat_app/src/view_models/providers.dart';
import 'package:video_concat_app/src/views/home/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePage', () {
    testWidgets('点击查看信息会跳转到 video-info 且只带 path', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          ffmpegServiceProvider.overrideWithValue(_ImmediateFFmpegService()),
          ffprobeServiceProvider.overrideWithValue(_ImmediateFFprobeService()),
          videoConcatServiceProvider.overrideWithValue(
            _FakeVideoConcatService(exitCode: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_TestApp(container: container));
      await container
          .read(homeViewModelProvider.notifier)
          .startGenerate('/tmp/output.mp4');
      await tester.pumpAndSettle();

      await tester.tap(find.text('查看信息'));
      await tester.pumpAndSettle();

      expect(find.text('path=/tmp/output.mp4'), findsOneWidget);
      expect(find.text('ref=<none>'), findsOneWidget);
    });

    testWidgets('开启自动打开后成功会直接跳到 video-info', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(
              exportOptions: const ExportOptions(autoOpenVideoInfo: true),
            ),
          ),
          ffmpegServiceProvider.overrideWithValue(_ImmediateFFmpegService()),
          ffprobeServiceProvider.overrideWithValue(_ImmediateFFprobeService()),
          videoConcatServiceProvider.overrideWithValue(
            _FakeVideoConcatService(exitCode: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_TestApp(container: container));
      await tester.pump();

      await container
          .read(homeViewModelProvider.notifier)
          .startGenerate('/tmp/output.mp4');
      await tester.pumpAndSettle();

      expect(find.text('path=/tmp/output.mp4'), findsOneWidget);
      expect(find.text('ref=<none>'), findsOneWidget);
    });

    testWidgets('分段模式成功后不会自动跳到 video-info', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(
              exportOptions: const ExportOptions(
                autoOpenVideoInfo: true,
                enableSegmentOutput: true,
                segmentDurationText: '120',
                segmentFilenameTemplate: '%filename%_%03d',
              ),
            ),
          ),
          ffmpegServiceProvider.overrideWithValue(_ImmediateFFmpegService()),
          ffprobeServiceProvider.overrideWithValue(_ImmediateFFprobeService()),
          videoConcatServiceProvider.overrideWithValue(
            _FakeVideoConcatService(exitCode: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_TestApp(container: container));
      await tester.pump();

      await container
          .read(homeViewModelProvider.notifier)
          .startGenerate('/tmp/output.mp4');
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('path=/tmp/output.mp4'), findsNothing);
    });
  });
}

final class _TestApp extends StatelessWidget {
  final ProviderContainer container;

  const _TestApp({required this.container});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/video-info',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                Text('path=${state.uri.queryParameters['path'] ?? ''}'),
                Text('ref=${state.uri.queryParameters['ref'] ?? '<none>'}'),
              ],
            ),
          ),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }
}

final class _FakePreferencesRepository extends PreferencesRepository {
  final ExportOptions exportOptions;

  _FakePreferencesRepository({this.exportOptions = const ExportOptions()});

  @override
  Future<String> getLastExtension() async => 'mp4';

  @override
  Future<ExportOptions> loadExportOptions() async => exportOptions;

  @override
  Future<String?> getFFmpegPath() async => 'ffmpeg';

  @override
  Future<String?> getFFprobePath() async => 'ffprobe';

  @override
  Future<void> saveExportOptions(ExportOptions options) async {}
}

final class _ImmediateFFmpegService extends FFmpegService {
  @override
  Future<bool> validate() async => true;
}

final class _ImmediateFFprobeService extends FFprobeService {
  @override
  Future<bool> validate() async => true;
}

final class _FakeVideoConcatService extends VideoConcatService {
  final int exitCode;

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
    onOutput?.call('done');
    return exitCode;
  }
}
