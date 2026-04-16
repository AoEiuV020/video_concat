import 'package:flutter_test/flutter_test.dart';

import 'package:video_concat_app/src/view_models/trim/trim_state.dart';

void main() {
  group('TrimState.isTimeUnresolved', () {
    test('播放中也视为时间未吸附', () {
      const state = TrimState(
        videoId: 'v',
        filePath: '/tmp/a.mp4',
        fileName: 'a.mp4',
        durationUs: 1,
        isPlaying: true,
      );

      expect(state.isTimeUnresolved, true);
    });

    test('画面未同步时不再算时间未吸附', () {
      const state = TrimState(
        videoId: 'v',
        filePath: '/tmp/a.mp4',
        fileName: 'a.mp4',
        durationUs: 1,
        currentPositionUs: 5000000,
        isPreviewPending: true,
        pendingPreviewTargetUs: 5000000,
      );

      expect(state.isTimeUnresolved, false);
    });
  });
}
