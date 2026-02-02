import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/preferences_repository.dart';

part 'providers.g.dart';

/// 持久化仓库
@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) {
  return PreferencesRepository();
}

/// FFmpeg 服务
@Riverpod(keepAlive: true)
FFmpegService ffmpegService(Ref ref) {
  return FFmpegService();
}

/// 视频合并服务
@Riverpod(keepAlive: true)
VideoConcatService videoConcatService(Ref ref) {
  final ffmpeg = ref.watch(ffmpegServiceProvider);
  return VideoConcatService(ffmpegService: ffmpeg);
}
