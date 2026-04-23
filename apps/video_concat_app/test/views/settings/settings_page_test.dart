import 'dart:async';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/repositories/preferences_repository.dart';
import 'package:video_concat_app/src/view_models/providers.dart';
import 'package:video_concat_app/src/view_models/settings/settings_viewmodel.dart';
import 'package:video_concat_app/src/views/settings/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsPage', () {
    testWidgets('首次进入时显示校验中而不是直接报不可用', (tester) async {
      final completer = Completer<bool>();
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
          ffmpegServiceProvider.overrideWithValue(
            _DelayedFFmpegService(resultCompleter: completer),
          ),
          ffprobeServiceProvider.overrideWithValue(
            _ImmediateFFprobeService(isValid: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      expect(find.text('正在检查...'), findsNWidgets(2));
      expect(find.text('FFmpeg 路径 不可用，请检查路径'), findsNothing);
    });

    testWidgets('校验失败后显示不可用提示', (tester) async {
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(ffmpegPath: '/bad/ffmpeg'),
          ),
          ffmpegServiceProvider.overrideWithValue(
            _ImmediateFFmpegService(isValid: false),
          ),
          ffprobeServiceProvider.overrideWithValue(
            _ImmediateFFprobeService(isValid: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      final state = container.read(settingsViewModelProvider);
      expect(state.isFFmpegValid, isFalse);
    });
  });
}

final class _FakePreferencesRepository extends PreferencesRepository {
  final String? ffmpegPath;

  _FakePreferencesRepository({this.ffmpegPath});

  @override
  Future<String?> getFFmpegPath() async => ffmpegPath;

  @override
  Future<String?> getFFprobePath() async => null;
}

final class _DelayedFFmpegService extends FFmpegService {
  final Completer<bool> resultCompleter;

  _DelayedFFmpegService({required this.resultCompleter});

  @override
  Future<bool> validate() => resultCompleter.future;
}

final class _ImmediateFFmpegService extends FFmpegService {
  final bool isValid;

  _ImmediateFFmpegService({required this.isValid});

  @override
  Future<bool> validate() async => isValid;

  @override
  Future<String?> readVersion() async => 'ffmpeg-test';
}

final class _ImmediateFFprobeService extends FFprobeService {
  final bool isValid;

  _ImmediateFFprobeService({required this.isValid});

  @override
  Future<bool> validate() async => isValid;

  @override
  Future<String?> readVersion() async => 'ffprobe-test';
}
