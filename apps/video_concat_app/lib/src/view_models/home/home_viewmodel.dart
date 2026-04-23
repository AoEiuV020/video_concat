import 'dart:io';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../log.dart';
import '../../models/models.dart';
import '../../utils/chapter_builder.dart';
import '../../utils/external_tools.dart';
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
    _initialize();
    return const HomeState();
  }

  Future<void> _initialize() async {
    try {
      await _loadPreferences();
      if (!ref.mounted) return;
      await _setupExternalTools();
      if (!ref.mounted) return;
      await _validateExternalTools();
    } catch (e, s) {
      if (!ref.mounted) return;
      _reportError('初始化失败', e, s, userMessage: '初始化失败：$e');
    }
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
      _reportError('偏好加载失败', e, s, userMessage: '读取偏好失败：$e');
    }
  }

  Future<void> _setupExternalTools() async {
    if (!ref.mounted) return;
    final prefs = ref.read(preferencesRepositoryProvider);
    final ffmpeg = ref.read(ffmpegServiceProvider);
    final ffprobe = ref.read(ffprobeServiceProvider);
    final specs = externalToolSpecsForCurrentPlatform();

    String ffmpegPath = await prefs.getFFmpegPath() ?? '';
    if (!ref.mounted) return;
    String ffprobePath = await prefs.getFFprobePath() ?? '';
    if (!ref.mounted) return;

    ffmpegPath = await _resolveToolPath(
      tool: ExternalTool.ffmpeg,
      currentPath: ffmpegPath,
      fallbackCommand: specs[ExternalTool.ffmpeg]!.commandName,
      onPersist: prefs.saveFFmpegPath,
      validateCandidate: (candidate) async {
        final old = ffmpeg.ffmpegPath;
        ffmpeg.ffmpegPath = candidate;
        final ok = await ffmpeg.validate();
        ffmpeg.ffmpegPath = old;
        return ok;
      },
    );
    if (!ref.mounted) return;

    ffprobePath = await _resolveToolPath(
      tool: ExternalTool.ffprobe,
      currentPath: ffprobePath,
      fallbackCommand: specs[ExternalTool.ffprobe]!.commandName,
      onPersist: prefs.saveFFprobePath,
      validateCandidate: (candidate) async {
        final old = ffprobe.ffprobePath;
        ffprobe.ffprobePath = candidate;
        final ok = await ffprobe.validate();
        ffprobe.ffprobePath = old;
        return ok;
      },
    );
    if (!ref.mounted) return;

    ffmpeg.ffmpegPath = ffmpegPath;
    ffprobe.ffprobePath = ffprobePath;
    logger.i('工具路径已设置 ffmpeg=$ffmpegPath ffprobe=$ffprobePath');
  }

  Future<String> _resolveToolPath({
    required ExternalTool tool,
    required String currentPath,
    required String fallbackCommand,
    required Future<void> Function(String) onPersist,
    required Future<bool> Function(String) validateCandidate,
  }) async {
    final specs = externalToolSpecsForCurrentPlatform();
    final spec = specs[tool]!;
    final trimmed = currentPath.trim();

    if (trimmed.isNotEmpty && await validateCandidate(trimmed)) {
      return trimmed;
    }

    for (final candidate in spec.candidatePaths) {
      try {
        if (!await toolPathExistsIfAbsolute(candidate)) {
          continue;
        }
        if (await validateCandidate(candidate)) {
          await onPersist(candidate);
          logger.i('自动发现 ${spec.displayName}=$candidate');
          return candidate;
        }
      } catch (e, s) {
        logger.w('探测 ${spec.displayName} 失败 candidate=$candidate error=$e');
        logger.d('探测异常堆栈: $s');
      }
    }

    return trimmed.isNotEmpty ? trimmed : fallbackCommand;
  }

  Future<void> _validateExternalTools() async {
    if (!ref.mounted) return;
    state = state.copyWith(isCheckingTools: true, toolCheckMessage: null);
    try {
      final ffmpeg = ref.read(ffmpegServiceProvider);
      final ffprobe = ref.read(ffprobeServiceProvider);
      final ffmpegOk = await ffmpeg.validate();
      if (!ref.mounted) return;
      final ffprobeOk = await ffprobe.validate();
      if (!ref.mounted) return;
      final ready = ffmpegOk && ffprobeOk;
      final msg = ready ? null : 'FFmpeg 或 FFprobe 不可用，请到设置页修复路径';
      state = state.copyWith(
        isCheckingTools: false,
        areToolsReady: ready,
        toolCheckMessage: msg,
      );
    } catch (e, s) {
      if (!ref.mounted) return;
      _reportError('工具校验失败', e, s, userMessage: '工具校验失败：$e');
      state = state.copyWith(
        isCheckingTools: false,
        areToolsReady: false,
        toolCheckMessage: '工具校验失败，请前往设置页修复路径',
      );
    }
  }

  /// 添加视频文件
  Future<void> addVideos(List<String> filePaths) async {
    logger.d('addVideos ${filePaths.length} 个文件');
    try {
      if (!state.areToolsReady) {
        state = state.copyWith(
          errorMessage: state.toolCheckMessage ?? '外部工具不可用',
        );
        return;
      }

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
      _reportError('addVideos 失败', e, s, userMessage: '添加视频失败：$e');
    }
  }

  /// 删除视频
  void removeVideo(String id) {
    try {
      logger.d('removeVideo id=$id');
      final items = state.videoItems.where((v) => v.id != id).toList();
      state = state.copyWith(
        videoItems: items,
        outputConfig: _updateBaseName(items, state.outputConfig),
      );
      _checkAndProbe();
    } catch (e, s) {
      _reportError('removeVideo 失败', e, s, userMessage: '删除视频失败：$e');
    }
  }

  /// 重新排序
  void reorderVideo(int oldIndex, int newIndex) {
    try {
      logger.d('reorderVideo $oldIndex -> $newIndex');
      final items = [...state.videoItems];
      if (newIndex > oldIndex) newIndex--;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      state = state.copyWith(videoItems: items);
      _checkAndProbe();
    } catch (e, s) {
      _reportError('reorderVideo 失败', e, s, userMessage: '排序失败：$e');
    }
  }

  /// 更新输出文件名
  void updateOutputBaseName(String baseName) {
    try {
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(baseName: baseName),
      );
    } catch (e, s) {
      _reportError(
        'updateOutputBaseName 失败',
        e,
        s,
        userMessage: '更新输出文件名失败：$e',
      );
    }
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
      _reportError(
        'updateOutputExtension 失败',
        e,
        s,
        userMessage: '更新输出后缀失败：$e',
      );
    }
  }

  /// 更新导出选项
  ///
  /// 自动处理互斥：
  /// - 清除元数据与拼接点章节不能同时启用
  /// - 片段拆分与时长分段不能同时启用
  /// - 按裁剪分段与拼接点章节不能同时启用
  void updateExportOptions(ExportOptions options) {
    try {
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

      // 片段拆分与时长分段互斥
      if (options.enableCustomSplit && options.enableSegmentOutput) {
        if (!prev.enableCustomSplit && options.enableCustomSplit) {
          resolved = resolved.copyWith(enableSegmentOutput: false);
        } else if (!prev.enableSegmentOutput && options.enableSegmentOutput) {
          resolved = resolved.copyWith(enableCustomSplit: false);
        }
      }

      // 按裁剪分段与拼接点章节互斥
      if (options.enableCustomSplit && options.addChapters) {
        if (!prev.enableCustomSplit && options.enableCustomSplit) {
          resolved = resolved.copyWith(addChapters: false);
        } else if (!prev.addChapters && options.addChapters) {
          resolved = resolved.copyWith(enableCustomSplit: false);
        }
      }

      state = state.copyWith(exportOptions: resolved);
    } catch (e, s) {
      _reportError('updateExportOptions 失败', e, s, userMessage: '更新导出选项失败：$e');
    }
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

    if (!state.areToolsReady) {
      state = state.copyWith(
        isGenerating: false,
        generateResult: const GenerateResult(
          state: GenerateState.failed,
          output: '',
          errorMessage: '外部工具不可用，请先在设置页配置 FFmpeg/FFprobe',
        ),
      );
      return;
    }

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

    final startTime = DateTime.now();

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
        useCustomSegments: state.exportOptions.enableCustomSplit,
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

      final elapsedDuration = DateTime.now().difference(startTime);
      logger.i(
        '生成完成 resultState=$resultState exitCode=$exitCode 耗时=$elapsedDuration',
      );

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
          elapsedDuration: elapsedDuration,
        ),
      );
    } catch (e, s) {
      final elapsedDuration = DateTime.now().difference(startTime);
      logger.e('startGenerate 异常 耗时=$elapsedDuration', error: e, stackTrace: s);
      state = state.copyWith(
        isGenerating: false,
        lastGeneratedVideo: null,
        segmentedOutputSummary: null,
        errorMessage: '合并失败：$e',
        generateResult: GenerateResult(
          state: GenerateState.failed,
          output: buffer.toString(),
          errorMessage: e.toString(),
          elapsedDuration: elapsedDuration,
        ),
      );
    }
  }

  /// 中断生成
  void cancelGenerate() {
    try {
      logger.i('cancelGenerate');
      ref.read(videoConcatServiceProvider).cancel();
    } catch (e, s) {
      _reportError('cancelGenerate 失败', e, s, userMessage: '中断失败：$e');
    }
  }

  /// 清除生成结果
  void clearResult() {
    state = state.copyWith(generateResult: null, errorMessage: null);
  }

  /// 重置所有状态，开始新任务
  void reset() {
    try {
      logger.d('reset');
      _referenceFilePath = null;
      state = const HomeState();
      _initialize();
    } catch (e, s) {
      _reportError('reset 失败', e, s, userMessage: '重置失败：$e');
    }
  }

  SegmentOutputOptions? _buildSegmentOutputOptions(String outputPath) {
    // 启用自定义片段拆分时，不使用分段输出选项
    if (state.exportOptions.enableCustomSplit) {
      return null;
    }

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
      _reportError(
        '探测参考视频失败 path=$refPath',
        e,
        s,
        userMessage: '读取参考视频信息失败：$e',
      );
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
      _reportError(
        '探测失败 ${item.fileName}',
        e,
        s,
        userMessage: '探测失败：${item.fileName}',
      );
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
    if (ffprobe.ffprobePath.trim().isEmpty ||
        ffprobe.ffprobePath == 'ffprobe') {
      ffprobe.deriveFromFFmpegPath(ffmpeg.ffmpegPath);
    }
    return ffprobe;
  }

  void _reportError(
    String action,
    Object error,
    StackTrace stackTrace, {
    required String userMessage,
  }) {
    if (!ref.mounted) return;
    logger.e(action, error: error, stackTrace: stackTrace);
    state = state.copyWith(errorMessage: userMessage);
  }
}
