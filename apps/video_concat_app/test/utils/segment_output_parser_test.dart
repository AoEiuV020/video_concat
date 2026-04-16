import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/utils/segment_output_parser.dart';

void main() {
  group('parseSegmentDurationText', () {
    test('支持秒浮点数字符串', () {
      expect(parseSegmentDurationText('120.5'), '120.500000');
    });

    test('支持 HH:MM:SS.mmm 格式', () {
      expect(parseSegmentDurationText('00:02:00.500'), '120.500000');
    });

    test('支持 MM:SS.mmm 格式', () {
      expect(parseSegmentDurationText('01:05.500'), '65.500000');
    });

    test('空字符串时报错', () {
      expect(
        () => parseSegmentDurationText('  '),
        throwsA(
          isA<FormatException>().having((e) => e.message, 'message', '请输入分段时长'),
        ),
      );
    });

    test('非法格式时报错', () {
      expect(
        () => parseSegmentDurationText('abc'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            '分段时长格式无效',
          ),
        ),
      );
    });

    test('非正数时报错', () {
      expect(
        () => parseSegmentDurationText('0'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            '分段时长必须大于 0',
          ),
        ),
      );
    });
  });

  group('validateSegmentFilenameTemplate', () {
    test('空字符串回退默认模板', () {
      expect(validateSegmentFilenameTemplate('  '), '%filename%_%03d');
    });

    test('缺少 %filename% 时报错', () {
      expect(
        () => validateSegmentFilenameTemplate('%03d'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            '文件名模板必须包含 %filename%',
          ),
        ),
      );
    });

    test('缺少 %03d 时报错', () {
      expect(
        () => validateSegmentFilenameTemplate('%filename%'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            '文件名模板必须包含 %03d',
          ),
        ),
      );
    });
  });
}
