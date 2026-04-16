import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/repositories/preferences_repository.dart';
import 'package:video_concat_app/src/view_models/providers.dart';
import 'package:video_concat_app/src/view_models/settings/settings_viewmodel.dart';

void main() {
  group('SettingsViewModel', () {
    test('启动时会加载已保存路径并校验可用性', () async {
      final prefs = _FakePreferencesRepository(ffmpegPath: '/usr/local/bin/ffmpeg');
      final ffmpeg = _FakeFFmpegService(validateResults: [true]);
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(prefs),
          ffmpegServiceProvider.overrideWithValue(ffmpeg),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(settingsViewModelProvider, (_, _) {});
      addTearDown(sub.close);

      expect(container.read(settingsViewModelProvider).isValidating, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final state = container.read(settingsViewModelProvider);
      expect(state.settings.ffmpegPath, '/usr/local/bin/ffmpeg');
      expect(state.isFFmpegValid, isTrue);
      expect(state.isValidating, isFalse);
      expect(ffmpeg.validatedPaths, ['/usr/local/bin/ffmpeg']);
    });

    test('更新路径后会保存并重新校验', () async {
      final prefs = _FakePreferencesRepository();
      final ffmpeg = _FakeFFmpegService(validateResults: [true, false]);
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(prefs),
          ffmpegServiceProvider.overrideWithValue(ffmpeg),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(settingsViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      final vm = container.read(settingsViewModelProvider.notifier);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await vm.updateFFmpegPath('/custom/ffmpeg');

      final state = container.read(settingsViewModelProvider);
      expect(prefs.savedPaths, ['/custom/ffmpeg']);
      expect(state.settings.ffmpegPath, '/custom/ffmpeg');
      expect(state.isFFmpegValid, isFalse);
      expect(ffmpeg.validatedPaths, ['ffmpeg', '/custom/ffmpeg']);
    });
  });
}

final class _FakePreferencesRepository extends PreferencesRepository {
  final String? ffmpegPath;
  final List<String> savedPaths = [];

  _FakePreferencesRepository({this.ffmpegPath});

  @override
  Future<String?> getFFmpegPath() async => ffmpegPath;

  @override
  Future<void> saveFFmpegPath(String path) async {
    savedPaths.add(path);
  }
}

final class _FakeFFmpegService extends FFmpegService {
  final List<bool> validateResults;
  final List<String> validatedPaths = [];
  int _index = 0;

  _FakeFFmpegService({required this.validateResults});

  @override
  Future<bool> validate() async {
    validatedPaths.add(ffmpegPath);
    final result = validateResults[_index];
    if (_index < validateResults.length - 1) {
      _index++;
    }
    return result;
  }
}
