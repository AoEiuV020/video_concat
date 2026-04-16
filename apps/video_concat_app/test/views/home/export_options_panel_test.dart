import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/models/export_options.dart';
import 'package:video_concat_app/src/view_models/home/home_state.dart';
import 'package:video_concat_app/src/view_models/home/home_viewmodel.dart';
import 'package:video_concat_app/src/views/home/widgets/export_options_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('导出选项面板显示自动打开信息页复选项', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportOptionsPanel(
            options: const ExportOptions(showOptions: true),
            vm: _StubHomeViewModel(),
            outputExtension: 'mp4',
            isGenerating: false,
          ),
        ),
      ),
    );

    expect(find.text('自动打开信息页'), findsOneWidget);
  });
}

final class _StubHomeViewModel extends HomeViewModel {
  @override
  HomeState build() => const HomeState();
}
