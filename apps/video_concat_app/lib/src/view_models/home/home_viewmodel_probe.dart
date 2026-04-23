part of 'home_viewmodel.dart';

final class _HomeViewModelProbe {
  _HomeViewModelProbe(this.vm);

  final HomeViewModel vm;

  HomeState get state => vm.currentState;
  set state(HomeState value) => vm.currentState = value;

  ProbeComparer get comparer => vm._comparer;

  void checkAndProbe() {
    final items = state.videoItems;
    if (items.isEmpty) {
      vm._referenceFilePath = null;
      state = state.copyWith(referenceResult: null, videoCompatibility: {});
      return;
    }

    final firstPath = items.first.filePath;
    if (firstPath != vm._referenceFilePath) {
      vm._referenceFilePath = firstPath;
      state = state.copyWith(referenceResult: null, videoCompatibility: {});
      _probeAll(firstPath, items);
    } else {
      _probeNewItems(items);
    }
  }

  Future<void> _probeAll(String refPath, List<VideoItem> items) async {
    logger.d('_probeAll refPath=$refPath items=${items.length}');
    ProbeResult refResult;
    try {
      refResult = await getFfprobeService().probe(refPath);
    } catch (e, s) {
      vm._reportError(
        '探测参考视频失败 path=$refPath',
        e,
        s,
        userMessage: '读取参考视频信息失败：$e',
      );
      return;
    }
    if (vm._referenceFilePath != refPath) return;

    final durationUs = (refResult.format.duration * 1000000).round();
    logger.d('参考视频 durationUs=$durationUs');
    final updatedItems = state.videoItems.map((v) {
      if (v.filePath == refPath && v.durationUs == null) {
        return v.copyWith(durationUs: durationUs);
      }
      return v;
    }).toList();

    state = state.copyWith(
      referenceResult: refResult,
      videoItems: updatedItems,
    );

    for (final item in items.skip(1)) {
      await _probeAndCompare(item, refResult);
      if (vm._referenceFilePath != refPath) return;
    }
  }

  Future<void> _probeNewItems(List<VideoItem> items) async {
    final refResult = state.referenceResult;
    if (refResult == null) return;

    for (final item in items.skip(1)) {
      if (state.videoCompatibility.containsKey(item.id)) continue;
      await _probeAndCompare(item, refResult);
      if (vm._referenceFilePath != items.first.filePath) return;
    }
  }

  Future<void> _probeAndCompare(VideoItem item, ProbeResult refResult) async {
    bool compatible;
    int? durationUs;
    try {
      final result = await getFfprobeService().probe(item.filePath);
      compatible = comparer.compare(refResult, result).isCompatible;
      durationUs = (result.format.duration * 1000000).round();
      logger.d(
        '探测 ${item.fileName} compatible=$compatible '
        'durationUs=$durationUs',
      );
    } catch (e, s) {
      vm._reportError(
        '探测失败 ${item.fileName}',
        e,
        s,
        userMessage: '探测失败：${item.fileName}',
      );
      compatible = false;
    }

    var updatedItems = state.videoItems;
    if (durationUs != null) {
      updatedItems = updatedItems.map((v) {
        if (v.id == item.id && v.durationUs == null) {
          return v.copyWith(durationUs: durationUs);
        }
        return v;
      }).toList();
    }

    state = state.copyWith(
      videoItems: updatedItems,
      videoCompatibility: {...state.videoCompatibility, item.id: compatible},
    );
  }

  FFprobeService getFfprobeService() {
    final ffprobe = vm.currentFFprobeService;
    final ffmpeg = vm.currentFFmpegService;
    if (ffprobe.ffprobePath.trim().isEmpty ||
        ffprobe.ffprobePath == 'ffprobe') {
      ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    }
    return ffprobe;
  }
}
