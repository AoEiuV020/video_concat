import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'providers.dart';

part 'video_info_viewmodel.g.dart';

/// 视频信息 ViewModel
@riverpod
Future<ProbeResult> videoInfo(Ref ref, String filePath) async {
  final ffprobe = ref.read(ffprobeServiceProvider);

  // 从 ffmpeg 路径推导 ffprobe 路径
  final ffmpeg = ref.read(ffmpegServiceProvider);
  ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);

  return ffprobe.probe(filePath);
}
