import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import 'trim_player_provider.dart';

part 'trim_playback_binding_provider.g.dart';

/// 在裁剪页生命周期内稳定持有播放器渲染资源。
@riverpod
void trimPlaybackBinding(Ref ref, String videoId) {
  logger.i('绑定裁剪播放资源 videoId=$videoId');
  ref.onDispose(() {
    logger.i('释放裁剪播放资源 videoId=$videoId');
  });
  ref.watch(trimVideoControllerProvider(videoId));
}
