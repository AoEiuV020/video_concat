import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../providers.dart';

part 'video_info_viewmodel.g.dart';

/// 视频信息页数据
class VideoInfoData {
  final ProbeResult result;
  final ProbeCompareResult? compareResult;

  const VideoInfoData({required this.result, this.compareResult});
}

/// 视频信息 ViewModel
///
/// [refPath] 不为空时，与参考视频对比并返回差异。
@riverpod
Future<VideoInfoData> videoInfo(
  Ref ref,
  String filePath, {
  String? refPath,
}) async {
  logger.d('videoInfo filePath=$filePath refPath=$refPath');
  try {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);

    final result = await ffprobe.probe(filePath);
    logger.d(
      'videoInfo 探测完成 '
      'duration=${result.format.duration}',
    );

    if (refPath == null || refPath.isEmpty) {
      return VideoInfoData(result: result);
    }

    final refResult = await ffprobe.probe(refPath);
    final compareResult = ProbeComparer().compare(refResult, result);
    logger.d(
      'videoInfo 对比完成 '
      'compatible=${compareResult.isCompatible}',
    );
    return VideoInfoData(result: result, compareResult: compareResult);
  } catch (e, s) {
    logger.e('videoInfo 失败 filePath=$filePath', error: e, stackTrace: s);
    rethrow;
  }
}
