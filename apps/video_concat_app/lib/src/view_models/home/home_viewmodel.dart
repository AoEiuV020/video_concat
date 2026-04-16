import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
import '../../utils/chapter_builder.dart';
import '../../utils/segment_output_parser.dart';
import '../providers.dart';
import 'home_state.dart';

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
    try {
      final prefs = ref.read(preferencesRepositoryProvider);
      final ext = await prefs.getLastExtension();
      final exportOptions = await prefs.loadExportOptions();
      if (!ref.mounted) return;
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(extension: ext),
        exportOptions: exportOptions,
      );
      logger.d('偏好加载完成 ext=$ext exportOptions=$exportOptions');
    } catch (e, s) {
      if (!ref.mounted) return;
      logger.e('偏好加载失败', error: e, stackTrace: s);
    }
  }

  /// 添加视频文件
  Future<void> addVideos(List<String> filePaths) async {
    logger.d('addVideos ${filePaths.length} 个文件');
    try {
      final newItems = <VideoItem>[];
      for (final path in filePaths) {
        final file = File(path);
        final fileName = path.split('/').last.split('\\').last;
        final fileSize = await file.length();
        newItems.add(
          VideoItem(
            id:
                DateTime.now().microsecondsSinceEpoch.toString() +
                filePaths.indexOf(path).toString(),
            filePath: path,
            fileName: fileName,
            fileSize: fileSize,
          ),
        );
      }

      final items = [...state.videoItems, ...newItems];
      state = state.copyWith(
        videoItems: items,
        outputConfig: _updateBaseName(items, state.outputConfig),
      );
      logger.d('addVideos 完成 总数=${items.length}');

      _checkAndProbe();
    } catch (e, s) {
      logger.e('addVideos 失败', error: e, stackTrace: s);
    }
  }

  /// 删除视频
  void removeVideo(String id) {
    logger.d('removeVideo id=$id');
    final items = state.videoItems.where((v) => v.id != id).toList();
    state = state.copyWith(
      videoItems: items,
      outputConfig: _updateBaseName(items, state.outputConfig),
    );

    _checkAndProbe();
  }

  /// 重新排序
  void reorderVideo(int oldIndex, int newIndex) {
    logger.d('reorderVideo $oldIndex -> $newIndex');
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
    logger.d('updateOutputExtension ext=$extension');
    try {
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(extension: extension),
      );
      await ref
          .read(preferencesRepositoryProvider)
          .saveLastExtension(extension);

      // 切换到不支持快速启动的格式时自动关闭
      final isMp4Like = extension == 'mp4' || extension == 'mov';
      if (!isMp4Like && state.exportOptions.fastStart) {
        state = state.copyWith(
          exportOptions: state.exportOptions.copyWith(fastStart: false),
        );
      }
    } catch (e, s) {
      logger.e('updateOutputExtension 失败', error: e, stackTrace: s);
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
    logger.d(
      'setTrimConfig videoId=$videoId '
      'segments=${config?.segments.length ?? 0}',
    );
    final items = state.videoItems.map((v) {
      if (v.id == videoId) return v.copyWith(trimConfig: config);
      return v;
    }).toList();
    state = state.copyWith(videoItems: items);
  }

  /// 开始生成
  Future<void> startGenerate(String outputPath) async {
    logger.i(
      'startGenerate outputPath=$outputPath '
      'videos=${state.videoItems.length}',
    );

    SegmentOutputOptions? segmentOutput;
    var extraArgs = state.exportOptions.toFFmpegArgs(
      outputExtension: state.outputConfig.extension,
    );
    try {
      segmentOutput = _buildSegmentOutputOptions(outputPath);
      if (segmentOutput != null) {
        extraArgs = _removeFastStartArgs(extraArgs);
      }
    } on FormatException catch (e) {
      state = state.copyWith(
        isGenerating: false,
        lastGeneratedVideo: null,
        segmentedOutputSummary: null,
        generateResult: GenerateResult(
          state: GenerateState.failed,
          output: '',
          errorMessage: e.message,
        ),
      );
      return;
    }

    // 保存导出选项（remember 开关始终保存）
    try {
      await ref
          .read(preferencesRepositoryProvider)
          .saveExportOptions(state.exportOptions);
    } catch (e, s) {
      logger.e('保存导出选项失败', error: e, stackTrace: s);
    }

    state = state.copyWith(
      isGenerating: true,
      lastGeneratedVideo: null,
      segmentedOutputSummary: null,
      generateResult: const GenerateResult(
        state: GenerateState.running,
        output: '',
      ),
    );

    final service = ref.read(videoConcatServiceProvider);
    final buffer = StringBuffer();
    final preInputArgs = state.exportOptions.toPreInputArgs();
    logger.d('extraArgs=$extraArgs preInputArgs=$preInputArgs');

    try {
      // 构建章节信息（需要 ffprobe 获取每个视频时长）
      List<ChapterInfo>? chapters;
      if (state.exportOptions.addChapters) {
        logger.d('构建章节信息...');
        chapters = await buildChapters(
          ffprobe: _getFfprobeService(),
          items: state.videoItems,
        );
        logger.d('章节数=${chapters?.length}');
      }

      final entries = state.videoItems
          .map(
            (v) => ConcatEntry(
              filePath: v.filePath,
              trimConfig: v.trimConfig,
              durationUs: v.durationUs,
            ),
          )
          .toList();
      logger.d('entries=${entries.length}');

      final exitCode = await service.concat(
        entries: entries,
        outputPath: outputPath,
        preInputArguments: preInputArgs,
        extraArguments: extraArgs,
        segmentOutput: segmentOutput,
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

      logger.i('生成完成 resultState=$resultState exitCode=$exitCode');

      state = state.copyWith(
        isGenerating: false,
        lastGeneratedVideo:
            resultState == GenerateState.success && segmentOutput == null
            ? GeneratedVideoInfo(
                outputPath: outputPath,
                fileName: outputPath.split('/').last.split('\\').last,
              )
            : null,
        segmentedOutputSummary:
            resultState == GenerateState.success && segmentOutput != null
            ? SegmentedOutputSummary(
                directoryPath: _directoryPathOf(outputPath),
                fileNamePattern: _fileNameOf(segmentOutput.outputPattern),
              )
            : null,
        generateResult: GenerateResult(
          state: resultState,
          output: buffer.toString(),
          errorMessage: resultState == GenerateState.failed
              ? 'FFmpeg 退出码: $exitCode'
              : null,
        ),
      );
    } catch (e, s) {
      logger.e('startGenerate 异常', error: e, stackTrace: s);
      state = state.copyWith(
        isGenerating: false,
        lastGeneratedVideo: null,
        segmentedOutputSummary: null,
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
    logger.i('cancelGenerate');
    ref.read(videoConcatServiceProvider).cancel();
  }

  /// 清除生成结果
  void clearResult() {
    state = state.copyWith(generateResult: null);
  }

  /// 重置所有状态，开始新任务
  void reset() {
    logger.d('reset');
    _referenceFilePath = null;
    state = const HomeState();
    _loadPreferences();
  }

  SegmentOutputOptions? _buildSegmentOutputOptions(String outputPath) {
    if (!state.exportOptions.enableSegmentOutput) {
      return null;
    }

    final segmentTime = parseSegmentDurationText(
      state.exportOptions.segmentDurationText,
    );
    final template = validateSegmentFilenameTemplate(
      state.exportOptions.segmentFilenameTemplate,
    );
    final extension = state.outputConfig.extension;
    final fileName = _fileNameOf(outputPath);
    final baseName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final patternName = template.replaceAll('%filename%', baseName);

    return SegmentOutputOptions(
      segmentTime: segmentTime,
      outputPattern: '${_directoryPathOf(outputPath)}/$patternName.$extension',
      formatOptions:
          state.exportOptions.fastStart &&
              (extension == 'mp4' || extension == 'mov')
          ? 'movflags=+faststart'
          : null,
    );
  }

  List<String> _removeFastStartArgs(List<String> args) {
    final result = <String>[];
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-movflags' &&
          i + 1 < args.length &&
          args[i + 1] == '+faststart') {
        i++;
        continue;
      }
      result.add(args[i]);
    }
    return result;
  }

  String _directoryPathOf(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? '.' : normalized.substring(0, index);
  }

  String _fileNameOf(String path) => path.split('/').last.split('\\').last;

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
    logger.d('_probeAll refPath=$refPath items=${items.length}');
    ProbeResult refResult;
    try {
      refResult = await _getFfprobeService().probe(refPath);
    } catch (e, s) {
      logger.e('探测参考视频失败 path=$refPath', error: e, stackTrace: s);
      return;
    }
    if (_referenceFilePath != refPath) return;

    // 更新首视频时长
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
  Future<void> _probeAndCompare(VideoItem item, ProbeResult refResult) async {
    bool compatible;
    int? durationUs;
    try {
      final result = await _getFfprobeService().probe(item.filePath);
      compatible = _comparer.compare(refResult, result).isCompatible;
      durationUs = (result.format.duration * 1000000).round();
      logger.d(
        '探测 ${item.fileName} compatible=$compatible '
        'durationUs=$durationUs',
      );
    } catch (e, s) {
      logger.e('探测失败 ${item.fileName}', error: e, stackTrace: s);
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
