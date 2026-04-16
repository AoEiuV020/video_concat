import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../log.dart';
import '../../../view_models/video_info/video_info_player_provider.dart';

/// 视频信息页真实预览层。
class VideoInfoPlaybackSurface extends ConsumerStatefulWidget {
  final String filePath;

  const VideoInfoPlaybackSurface({super.key, required this.filePath});

  @override
  ConsumerState<VideoInfoPlaybackSurface> createState() =>
      _VideoInfoPlaybackSurfaceState();
}

class _VideoInfoPlaybackSurfaceState
    extends ConsumerState<VideoInfoPlaybackSurface> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final player = ref.read(videoInfoPlayerProvider(widget.filePath));
      try {
        logger.i('打开视频信息页媒体 filePath=${widget.filePath}');
        await player.open(Media(widget.filePath), play: false);
        logger.i('打开视频信息页媒体完成 filePath=${widget.filePath}');
      } catch (e, s) {
        logger.e(
          '视频信息页打开媒体失败 filePath=${widget.filePath}',
          error: e,
          stackTrace: s,
        );
        if (mounted) {
          setState(() => _error = e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Text('播放器初始化失败: $_error');
    }

    final controller = ref.watch(
      videoInfoVideoControllerProvider(widget.filePath),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(
          controller: controller,
          controls: AdaptiveVideoControls,
          fit: BoxFit.contain,
          fill: Colors.black,
        ),
      ),
    );
  }
}
