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

    test('loadExportOptions 会读取分段输出选项', () async {
      SharedPreferences.setMockInitialValues({
        'export_enable_segment_output': true,
        'export_segment_duration_text': '120.5',
        'export_segment_filename_template': '%filename%_%03d',
      });

      final repo = PreferencesRepository();
      final options = await repo.loadExportOptions();

      expect(options.enableSegmentOutput, isTrue);
      expect(options.segmentDurationText, '120.5');
      expect(options.segmentFilenameTemplate, '%filename%_%03d');
    });

    test('rememberChoices=true 时会保存分段输出选项', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = PreferencesRepository();

      await repo.saveExportOptions(
        const ExportOptions(
          rememberChoices: true,
          enableSegmentOutput: true,
          segmentDurationText: '120',
          segmentFilenameTemplate: '%filename%_%03d',
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('export_enable_segment_output'), isTrue);
      expect(prefs.getString('export_segment_duration_text'), '120');
      expect(
        prefs.getString('export_segment_filename_template'),
        '%filename%_%03d',
      );
    });

    test('rememberChoices=false 时不会保留分段输出选项', () async {
      SharedPreferences.setMockInitialValues({
        'export_enable_segment_output': true,
        'export_segment_duration_text': '120',
        'export_segment_filename_template': '%filename%_%03d',
      });
      final repo = PreferencesRepository();

      await repo.saveExportOptions(
        const ExportOptions(
          rememberChoices: false,
          enableSegmentOutput: true,
          segmentDurationText: '120',
          segmentFilenameTemplate: '%filename%_%03d',
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('export_enable_segment_output'), isNull);
      expect(prefs.getString('export_segment_duration_text'), isNull);
      expect(prefs.getString('export_segment_filename_template'), isNull);
    });
  });
}
