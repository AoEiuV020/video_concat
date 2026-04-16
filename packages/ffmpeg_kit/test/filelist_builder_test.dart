import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/filelist_builder.dart';
import 'package:ffmpeg_kit/src/models/concat_entry.dart';
import 'package:ffmpeg_kit/src/models/trim_config.dart';
import 'package:ffmpeg_kit/src/models/trim_segment.dart';

void main() {
  group('buildFilelistContent', () {
    test('无裁剪：单条 file 行', () {
      final entries = [ConcatEntry(filePath: '/path/to/A.mp4')];
      expect(buildFilelistContent(entries), "file '/path/to/A.mp4'");
    });

    test('多文件无裁剪', () {
      final entries = [
        ConcatEntry(filePath: '/path/A.mp4'),
        ConcatEntry(filePath: '/path/B.mp4'),
      ];
      expect(
        buildFilelistContent(entries),
        "file '/path/A.mp4'\nfile '/path/B.mp4'",
      );
    });

    test('单片段裁剪：含 inpoint 和 outpoint', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/B.mp4',
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 4004000, outpoint: 28028000)],
          ),
          durationUs: 120000000,
        ),
      ];
      expect(
        buildFilelistContent(entries),
        "file '/path/B.mp4'\ninpoint 4.004000\noutpoint 28.028000",
      );
    });

    test('inpoint = 0 时省略 inpoint 行', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/C.mp4',
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 0, outpoint: 15015000)],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      expect(content, contains("file '/path/C.mp4'"));
      expect(content, isNot(contains('inpoint')));
      expect(content, contains('outpoint 15.015000'));
    });

    test('outpoint = 视频时长时省略 outpoint 行', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/D.mp4',
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 5000000, outpoint: 120000000)],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      expect(content, contains('inpoint 5.000000'));
      expect(content, isNot(contains('outpoint')));
    });

    test('多片段裁剪：同一文件出现多次', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/C.mp4',
          trimConfig: TrimConfig(
            segments: [
              TrimSegment(inpoint: 0, outpoint: 15015000),
              TrimSegment(inpoint: 60060000, outpoint: 90090000),
            ],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      final lines = content.split('\n');
      // 第一片段
      expect(lines[0], "file '/path/C.mp4'");
      expect(lines[1], 'outpoint 15.015000');
      // 第二片段
      expect(lines[2], "file '/path/C.mp4'");
      expect(lines[3], 'inpoint 60.060000');
      expect(lines[4], 'outpoint 90.090000');
    });

    test('混合场景：设计文档示例', () {
      // A 不裁剪，B 取中间一段，C 取两段
      final entries = [
        ConcatEntry(filePath: 'A.mp4'),
        ConcatEntry(
          filePath: 'B.mp4',
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 4004000, outpoint: 28028000)],
          ),
          durationUs: 120000000,
        ),
        ConcatEntry(
          filePath: 'C.mp4',
          trimConfig: TrimConfig(
            segments: [
              TrimSegment(inpoint: 0, outpoint: 15015000),
              TrimSegment(inpoint: 60060000, outpoint: 90090000),
            ],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      expect(content, contains("file 'A.mp4'"));
      expect(content, contains("file 'B.mp4'"));
      expect(content, contains('inpoint 4.004000'));
      expect(content, contains('outpoint 28.028000'));
      // C 第一片段无 inpoint
      final lines = content.split('\n');
      final cFirstIdx = lines.indexWhere((l) => l == "file 'C.mp4'");
      expect(lines[cFirstIdx + 1], 'outpoint 15.015000');
    });

    test('Windows 路径反斜杠转正斜杠', () {
      final entries = [ConcatEntry(filePath: r'C:\Users\test\video.mp4')];
      expect(buildFilelistContent(entries), "file 'C:/Users/test/video.mp4'");
    });

    test("路径含单引号时正确转义", () {
      final entries = [ConcatEntry(filePath: "/path/it's a video.mp4")];
      expect(
        buildFilelistContent(entries),
        "file '/path/it'\\''s a video.mp4'",
      );
    });

    test('outpointDtsUs 存在时使用 DTS 作为 outpoint', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/E.mp4',
          trimConfig: TrimConfig(
            segments: [
              TrimSegment(
                inpoint: 0,
                outpoint: 2083000,
                outpointDtsUs: 2075000,
              ),
            ],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      expect(content, contains('outpoint 2.075000'));
      expect(content, isNot(contains('outpoint 2.083000')));
    });

    test('outpointDtsUs 为 null 时回退到 outpoint', () {
      final entries = [
        ConcatEntry(
          filePath: '/path/F.mp4',
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 0, outpoint: 2083000)],
          ),
          durationUs: 120000000,
        ),
      ];
      final content = buildFilelistContent(entries);
      expect(content, contains('outpoint 2.083000'));
    });
  });
}
