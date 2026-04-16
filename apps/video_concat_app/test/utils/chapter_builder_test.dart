import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/models/models.dart';
import 'package:video_concat_app/src/utils/chapter_builder.dart';

void main() {
  group('buildChaptersFromItems', () {
    test('无裁剪：使用 durationUs', () {
      final items = [
        VideoItem(
          id: '1',
          filePath: '/a.mp4',
          fileName: 'a.mp4',
          fileSize: 100,
          durationUs: 60000000,
        ),
        VideoItem(
          id: '2',
          filePath: '/b.mp4',
          fileName: 'b.mp4',
          fileSize: 200,
          durationUs: 120000000,
        ),
      ];
      final chapters = buildChaptersFromItems(items);
      expect(chapters!.length, 2);
      expect(chapters[0].title, 'a');
      expect(chapters[0].duration, closeTo(60.0, 0.001));
      expect(chapters[1].title, 'b');
      expect(chapters[1].duration, closeTo(120.0, 0.001));
    });

    test('单片段裁剪', () {
      final items = [
        VideoItem(
          id: '1',
          filePath: '/a.mp4',
          fileName: 'a.mp4',
          fileSize: 100,
          durationUs: 120000000,
          trimConfig: TrimConfig(
            segments: [TrimSegment(inpoint: 4004000, outpoint: 28028000)],
          ),
        ),
      ];
      final chapters = buildChaptersFromItems(items);
      expect(chapters!.length, 1);
      expect(chapters[0].title, 'a');
      expect(chapters[0].duration, closeTo(24.024, 0.001));
    });

    test('多片段裁剪：多个章节', () {
      final items = [
        VideoItem(
          id: '1',
          filePath: '/c.mp4',
          fileName: 'c.mp4',
          fileSize: 100,
          durationUs: 120000000,
          trimConfig: TrimConfig(
            segments: [
              TrimSegment(inpoint: 0, outpoint: 15015000),
              TrimSegment(inpoint: 60060000, outpoint: 90090000),
            ],
          ),
        ),
      ];
      final chapters = buildChaptersFromItems(items);
      expect(chapters!.length, 2);
      expect(chapters[0].title, 'c #1');
      expect(chapters[0].duration, closeTo(15.015, 0.001));
      expect(chapters[1].title, 'c #2');
      expect(chapters[1].duration, closeTo(30.03, 0.001));
    });

    test('缺少 durationUs 返回 null', () {
      final items = [
        VideoItem(
          id: '1',
          filePath: '/a.mp4',
          fileName: 'a.mp4',
          fileSize: 100,
        ),
      ];
      final chapters = buildChaptersFromItems(items);
      expect(chapters, isNull);
    });
  });
}
