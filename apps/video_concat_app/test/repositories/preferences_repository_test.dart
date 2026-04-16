import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:video_concat_app/src/models/export_options.dart';
import 'package:video_concat_app/src/repositories/preferences_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PreferencesRepository', () {
    test('loadExportOptions 会读取 autoOpenVideoInfo', () async {
      SharedPreferences.setMockInitialValues({
        'export_auto_open_video_info': true,
      });

      final repo = PreferencesRepository();
      final options = await repo.loadExportOptions();

      expect(options.autoOpenVideoInfo, isTrue);
    });

    test('rememberChoices=true 时会保存 autoOpenVideoInfo', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = PreferencesRepository();

      await repo.saveExportOptions(
        const ExportOptions(rememberChoices: true, autoOpenVideoInfo: true),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('export_auto_open_video_info'), isTrue);
    });
  });
}
