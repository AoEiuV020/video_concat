import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';

part 'trim_player_provider.g.dart';

/// 裁剪页面的视频播放器（per-videoId，auto-dispose）
@riverpod
Raw<Player> trimPlayer(Ref ref, String videoId) {
  logger.i('创建裁剪播放器 videoId=$videoId');
  final player = Player();
  ref.onDispose(() {
    logger.i('释放裁剪播放器 videoId=$videoId');
    player.dispose();
  });
  return player;
}

/// 裁剪页面的视频渲染控制器
@riverpod
Raw<VideoController> trimVideoController(Ref ref, String videoId) {
  final player = ref.watch(trimPlayerProvider(videoId));
  logger.i('创建裁剪视频控制器 videoId=$videoId');
  ref.onDispose(() {
    logger.i('释放裁剪视频控制器 videoId=$videoId');
  });
  return VideoController(player);
}
