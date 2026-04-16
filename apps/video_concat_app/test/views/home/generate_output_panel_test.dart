import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/models/models.dart';
import 'package:video_concat_app/src/views/home/widgets/generate_output_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('success 态显示查看信息入口', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateOutputPanel(
            result: const GenerateResult(
              state: GenerateState.success,
              output: 'done',
            ),
            generatedVideo: const GeneratedVideoInfo(
              outputPath: '/tmp/output.mp4',
              fileName: 'output.mp4',
            ),
            onOpenVideoInfo: () {},
          ),
        ),
      ),
    );

    expect(find.text('合并结果'), findsOneWidget);
    expect(find.text('output.mp4'), findsOneWidget);
    expect(find.text('查看信息'), findsOneWidget);
  });

  testWidgets('分段成功时显示多文件摘要且不显示查看信息', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateOutputPanel(
            result: const GenerateResult(
              state: GenerateState.success,
              output: 'done',
            ),
            segmentedOutputSummary: const SegmentedOutputSummary(
              directoryPath: '/tmp',
              fileNamePattern: 'output_%03d.mp4',
            ),
          ),
        ),
      ),
    );

    expect(find.text('分段输出'), findsOneWidget);
    expect(find.text('/tmp'), findsOneWidget);
    expect(find.text('output_%03d.mp4'), findsOneWidget);
    expect(find.text('查看信息'), findsNothing);
  });
}
