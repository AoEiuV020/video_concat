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
      _buildPanel(const ExportOptions(showOptions: true)),
    );

    expect(find.text('自动打开信息页'), findsOneWidget);
  });

  testWidgets('分段输出关闭时不显示额外输入', (tester) async {
    await tester.pumpWidget(
      _buildPanel(const ExportOptions(showOptions: true)),
    );

    expect(find.text('按目标时长分段'), findsOneWidget);
    expect(find.text('分段时长'), findsNothing);
    expect(find.text('文件名模板'), findsNothing);
    expect(find.text('切点按关键帧对齐，时长可能略有偏差。'), findsNothing);
  });

  testWidgets('分段输出开启时显示额外输入和提示', (tester) async {
    await tester.pumpWidget(
      _buildPanel(
        const ExportOptions(showOptions: true, enableSegmentOutput: true),
      ),
    );

    expect(find.text('分段时长'), findsOneWidget);
    expect(find.text('文件名模板'), findsOneWidget);
    expect(find.text('切点按关键帧对齐，时长可能略有偏差。'), findsOneWidget);
  });
}

Widget _buildPanel(ExportOptions options) {
  return MaterialApp(
    home: Scaffold(
      body: ExportOptionsPanel(
        options: options,
        vm: _StubHomeViewModel(),
        outputExtension: 'mp4',
        isGenerating: false,
      ),
    ),
  );
}

final class _StubHomeViewModel extends HomeViewModel {
  @override
  HomeState build() => const HomeState();
}
