import 'package:test/test.dart';

import 'package:ffmpeg_kit/src/video_concat_service.dart';

void main() {
  // 测试从 List<String> 到 List<ConcatEntry> 的向后兼容转换
  group('inputPathsToEntries', () {
    test('简单路径列表转换', () {
      final entries = inputPathsToEntries(['/a.mp4', '/b.mp4']);
      expect(entries.length, 2);
      expect(entries[0].filePath, '/a.mp4');
      expect(entries[0].trimConfig, isNull);
      expect(entries[1].filePath, '/b.mp4');
    });
  });
}
