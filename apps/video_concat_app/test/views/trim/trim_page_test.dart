import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_concat_app/src/view_models/trim/trim_playback_binding_provider.dart';
import 'package:video_concat_app/src/view_models/trim/trim_state.dart';
import 'package:video_concat_app/src/view_models/trim/trim_viewmodel.dart';
import 'package:video_concat_app/src/views/trim/trim_page.dart';

final class _ProviderAddObserver extends ProviderObserver {
  final addedProviders = <String>[];

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    addedProviders.add(context.provider.toString());
  }
}

final class _TestTrimViewModel extends TrimViewModel {
  @override
  TrimState build(String videoId) {
    return TrimState(
      videoId: videoId,
      filePath: '/tmp/demo.mp4',
      fileName: 'demo.mp4',
      durationUs: 1,
      isLoading: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrimPage', () {
    testWidgets('loading 阶段也会持有播放绑定 provider', (tester) async {
      const videoId = 'video-1';
      final observer = _ProviderAddObserver();

      await tester.pumpWidget(
        ProviderScope(
          observers: [observer],
          overrides: [
            trimViewModelProvider(videoId).overrideWith(_TestTrimViewModel.new),
            trimPlaybackBindingProvider(videoId).overrideWithValue(null),
          ],
          child: const MaterialApp(
            home: TrimPage(videoId: videoId),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        observer.addedProviders,
        contains('trimPlaybackBindingProvider($videoId)'),
      );
    });
  });
}
