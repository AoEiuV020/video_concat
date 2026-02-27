import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';
import 'home_state.dart';
import 'providers.dart';

part 'home_viewmodel.g.dart';

/// 主页 ViewModel
@riverpod
class HomeViewModel extends _$HomeViewModel {
  String? _referenceFilePath;
  final _comparer = ProbeComparer();

  @override
  HomeState build() {
    _loadPreferences();
    return const HomeState();
  }

  Future<void> _loadPreferences() async {
    final prefs = ref.read(preferencesRepositoryProvider);
    final ext = await prefs.getLastExtension();
    state = state.copyWith(
      outputConfig: state.outputConfig.copyWith(extension: ext),
    );
  }

  /// 添加视频文件
  Future<void> addVideos(List<String> filePaths) async {
    final newItems = <VideoItem>[];
    for (final path in filePaths) {
      final file = File(path);
      final fileName = path.split('/').last.split('\\').last;
      final fileSize = await file.length();
      newItems.add(VideoItem(
        id: DateTime.now().microsecondsSinceEpoch.toString() +
            filePaths.indexOf(path).toString(),
        filePath: path,
        fileName: fileName,
        fileSize: fileSize,
      ));
    }

    final items = [...state.videoItems, ...newItems];
    state = state.copyWith(
      videoItems: items,
      outputConfig: _updateBaseName(items, state.outputConfig),
    );

    _checkAndProbe();
  }

  /// 删除视频
  void removeVideo(String id) {
    final items = state.videoItems.where((v) => v.id != id).toList();
    state = state.copyWith(
      videoItems: items,
      outputConfig: _updateBaseName(items, state.outputConfig),
    );

    _checkAndProbe();
  }

  /// 重新排序
  void reorderVideo(int oldIndex, int newIndex) {
    final items = [...state.videoItems];
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(videoItems: items);

    _checkAndProbe();
  }

  /// 更新输出文件名
  void updateOutputBaseName(String baseName) {
    state = state.copyWith(
      outputConfig: state.outputConfig.copyWith(baseName: baseName),
    );
  }

  /// 更新输出后缀
  Future<void> updateOutputExtension(String extension) async {
    state = state.copyWith(
      outputConfig: state.outputConfig.copyWith(extension: extension),
    );
    await ref.read(preferencesRepositoryProvider).saveLastExtension(extension);
  }

  OutputConfig _updateBaseName(List<VideoItem> items, OutputConfig config) {
    if (items.isEmpty) {
      return config.copyWith(baseName: '');
    }
    final firstName = items.first.fileName;
    final nameWithoutExt = firstName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return config.copyWith(baseName: '${nameWithoutExt}_merged');
  }

  /// 开始生成
  Future<void> startGenerate(String outputPath) async {
    state = state.copyWith(
      isGenerating: true,
      generateResult: const GenerateResult(
        state: GenerateState.running,
        output: '',
      ),
    );

    final service = ref.read(videoConcatServiceProvider);
    final buffer = StringBuffer();

    try {
      final exitCode = await service.concat(
        inputPaths: state.videoItems.map((v) => v.filePath).toList(),
        outputPath: outputPath,
        onOutput: (output) {
          buffer.write(output);
          state = state.copyWith(
            generateResult: GenerateResult(
              state: GenerateState.running,
              output: buffer.toString(),
            ),
          );
        },
      );

      // 判断是否为取消
      final resultState = service.isCancelled
          ? GenerateState.cancelled
          : (exitCode == 0 ? GenerateState.success : GenerateState.failed);

      state = state.copyWith(
        isGenerating: false,
        generateResult: GenerateResult(
          state: resultState,
          output: buffer.toString(),
          errorMessage: resultState == GenerateState.failed
              ? 'FFmpeg 退出码: $exitCode'
              : null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        generateResult: GenerateResult(
          state: GenerateState.failed,
          output: buffer.toString(),
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 中断生成
  void cancelGenerate() {
    ref.read(videoConcatServiceProvider).cancel();
  }

  /// 清除生成结果
  void clearResult() {
    state = state.copyWith(generateResult: null);
  }

  /// 重置所有状态，开始新任务
  void reset() {
    _referenceFilePath = null;
    state = const HomeState();
    _loadPreferences();
  }

  /// 检查第一个视频是否变化，触发探测。
  void _checkAndProbe() {
    final items = state.videoItems;

    if (items.isEmpty) {
      _referenceFilePath = null;
      state = state.copyWith(
        referenceResult: null,
        videoCompatibility: {},
      );
      return;
    }

    final firstPath = items.first.filePath;

    if (firstPath != _referenceFilePath) {
      // 第一个视频变化，全部重新探测
      _referenceFilePath = firstPath;
      state = state.copyWith(
        referenceResult: null,
        videoCompatibility: {},
      );
      _probeAll(firstPath, items);
    } else {
      // 第一个视频没变，只探测未检查的视频
      _probeNewItems(items);
    }
  }

  /// 探测所有视频。
  Future<void> _probeAll(String refPath, List<VideoItem> items) async {
    final ffprobe = _getFfprobeService();

    // 先探测标准视频
    ProbeResult refResult;
    try {
      refResult = await ffprobe.probe(refPath);
    } catch (_) {
      return; // 标准视频探测失败则跳过
    }

    // 探测期间第一个视频可能已变化
    if (_referenceFilePath != refPath) return;

    state = state.copyWith(referenceResult: refResult);

    // 逐个对比其余视频
    for (final item in items.skip(1)) {
      await _probeAndCompare(item, refResult);
      if (_referenceFilePath != refPath) return;
    }
  }

  /// 只探测新增的未检查视频。
  Future<void> _probeNewItems(List<VideoItem> items) async {
    final refResult = state.referenceResult;
    if (refResult == null) return;

    for (final item in items.skip(1)) {
      if (state.videoCompatibility.containsKey(item.id)) continue;
      await _probeAndCompare(item, refResult);
      if (_referenceFilePath != items.first.filePath) return;
    }
  }

  /// 探测单个视频并与标准对比。
  Future<void> _probeAndCompare(
    VideoItem item,
    ProbeResult refResult,
  ) async {
    final ffprobe = _getFfprobeService();

    try {
      final result = await ffprobe.probe(item.filePath);
      final compareResult = _comparer.compare(refResult, result);

      state = state.copyWith(
        videoCompatibility: {
          ...state.videoCompatibility,
          item.id: compareResult.isCompatible,
        },
      );
    } catch (_) {
      // 探测失败标记为不兼容
      state = state.copyWith(
        videoCompatibility: {
          ...state.videoCompatibility,
          item.id: false,
        },
      );
    }
  }

  FFprobeService _getFfprobeService() {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    return ffprobe;
  }
}
