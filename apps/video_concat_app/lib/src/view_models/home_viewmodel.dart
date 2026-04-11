import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';
import '../utils/chapter_builder.dart';
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
    final exportOptions = await prefs.loadExportOptions();
    state = state.copyWith(
      outputConfig: state.outputConfig.copyWith(extension: ext),
      exportOptions: exportOptions,
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

    // 切换到不支持快速启动的格式时自动关闭
    final isMp4Like = extension == 'mp4' || extension == 'mov';
    if (!isMp4Like && state.exportOptions.fastStart) {
      state = state.copyWith(
        exportOptions: state.exportOptions.copyWith(fastStart: false),
      );
    }
  }

  /// 更新导出选项
  ///
  /// 自动处理互斥：清除元数据与拼接点章节不能同时启用。
  void updateExportOptions(ExportOptions options) {
    final prev = state.exportOptions;
    var resolved = options;

    // 清除元数据(-map_metadata -1)与章节注入(-map_metadata 1)互斥
    if (options.stripMetadata && options.addChapters) {
      if (!prev.stripMetadata && options.stripMetadata) {
        resolved = resolved.copyWith(addChapters: false);
      } else if (!prev.addChapters && options.addChapters) {
        resolved = resolved.copyWith(stripMetadata: false);
      }
    }

    state = state.copyWith(exportOptions: resolved);
  }

  OutputConfig _updateBaseName(List<VideoItem> items, OutputConfig config) {
    if (items.isEmpty) {
      return config.copyWith(baseName: '');
    }
    final firstName = items.first.fileName;
    final nameWithoutExt = firstName.replaceAll(RegExp(r'\.[^.]+$'), '');
    return config.copyWith(baseName: '${nameWithoutExt}_merged');
  }

  /// 设置视频的裁剪配置
  void setTrimConfig(String videoId, TrimConfig? config) {
    final items = state.videoItems.map((v) {
      if (v.id == videoId) return v.copyWith(trimConfig: config);
      return v;
    }).toList();
    state = state.copyWith(videoItems: items);
  }

  /// 开始生成
  Future<void> startGenerate(String outputPath) async {
    // 保存导出选项（remember 开关始终保存）
    await ref
        .read(preferencesRepositoryProvider)
        .saveExportOptions(state.exportOptions);

    state = state.copyWith(
      isGenerating: true,
      generateResult: const GenerateResult(
        state: GenerateState.running,
        output: '',
      ),
    );

    final service = ref.read(videoConcatServiceProvider);
    final buffer = StringBuffer();
    final extraArgs = state.exportOptions.toFFmpegArgs(
      outputExtension: state.outputConfig.extension,
    );
    final preInputArgs = state.exportOptions.toPreInputArgs();

    try {
      // 构建章节信息（需要 ffprobe 获取每个视频时长）
      List<ChapterInfo>? chapters;
      if (state.exportOptions.addChapters) {
        chapters = await buildChapters(
          ffprobe: _getFfprobeService(),
          items: state.videoItems,
        );
      }

      final entries = state.videoItems.map((v) => ConcatEntry(
        filePath: v.filePath,
        trimConfig: v.trimConfig,
        durationUs: v.durationUs,
      )).toList();

      final exitCode = await service.concat(
        entries: entries,
        outputPath: outputPath,
        preInputArguments: preInputArgs,
        extraArguments: extraArgs,
        chapters: chapters,
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
      state = state.copyWith(referenceResult: null, videoCompatibility: {});
      return;
    }

    final firstPath = items.first.filePath;
    if (firstPath != _referenceFilePath) {
      _referenceFilePath = firstPath;
      state = state.copyWith(referenceResult: null, videoCompatibility: {});
      _probeAll(firstPath, items);
    } else {
      _probeNewItems(items);
    }
  }

  /// 探测所有视频。
  Future<void> _probeAll(String refPath, List<VideoItem> items) async {
    ProbeResult refResult;
    try {
      refResult = await _getFfprobeService().probe(refPath);
    } catch (_) {
      return;
    }
    if (_referenceFilePath != refPath) return;

    // 更新首视频时长
    final durationUs = (refResult.format.duration * 1000000).round();
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
    bool compatible;
    int? durationUs;
    try {
      final result = await _getFfprobeService().probe(item.filePath);
      compatible = _comparer.compare(refResult, result).isCompatible;
      durationUs = (result.format.duration * 1000000).round();
    } catch (_) {
      compatible = false;
    }

    // 更新视频时长
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

  FFprobeService _getFfprobeService() {
    final ffprobe = ref.read(ffprobeServiceProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    return ffprobe;
  }
}
