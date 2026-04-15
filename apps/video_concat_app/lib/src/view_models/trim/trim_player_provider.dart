import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trim_player_provider.g.dart';

/// 裁剪页面的视频播放器（per-videoId，auto-dispose）
@riverpod
Raw<Player> trimPlayer(Ref ref, String videoId) {
  final player = Player();
  ref.onDispose(() => player.dispose());
  return player;
}

/// 裁剪页面的视频渲染控制器
@riverpod
Raw<VideoController> trimVideoController(Ref ref, String videoId) {
  final player = ref.watch(trimPlayerProvider(videoId));
  return VideoController(player);
}
