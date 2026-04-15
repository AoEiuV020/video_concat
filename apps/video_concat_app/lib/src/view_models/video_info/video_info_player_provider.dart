import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';

part 'video_info_player_provider.g.dart';

/// 视频信息页播放器（per-filePath，auto-dispose）。
@riverpod
Raw<Player> videoInfoPlayer(Ref ref, String filePath) {
  logger.i('创建视频信息页播放器 filePath=$filePath');
  final player = Player();
  ref.onDispose(() {
    logger.i('释放视频信息页播放器 filePath=$filePath');
    player.dispose();
  });
  return player;
}

/// 视频信息页视频渲染控制器。
@riverpod
Raw<VideoController> videoInfoVideoController(Ref ref, String filePath) {
  final player = ref.watch(videoInfoPlayerProvider(filePath));
  logger.i('创建视频信息页视频控制器 filePath=$filePath');
  ref.onDispose(() {
    logger.i('释放视频信息页视频控制器 filePath=$filePath');
  });
  return VideoController(player);
}
