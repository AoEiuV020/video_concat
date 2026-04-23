part of 'home_viewmodel.dart';

final class _HomeViewModelGenerate {
  _HomeViewModelGenerate(this.vm);

  final HomeViewModel vm;

  HomeState get state => vm.currentState;
  set state(HomeState value) => vm.currentState = value;

  dynamic get preferencesRepository => vm.preferencesRepository;
  VideoConcatService get videoConcatService => vm.currentVideoConcatService;

  Future<void> startGenerate(String outputPath) async {
    logger.i(
      'startGenerate outputPath=$outputPath '
      'videos=${state.videoItems.length}',
    );

    if (!state.areToolsReady) {
      const message = '外部工具不可用，请先在设置页配置 FFmpeg/FFprobe';
      state = state.copyWith(
        isGenerating: false,
        generateResult: const GenerateResult(
          state: GenerateState.failed,
          output: '',
          errorMessage: message,
        ),
      );
      vm._setErrorMessage(message);
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
      vm._setErrorMessage(e.message);
      return;
    }

    try {
      await preferencesRepository.saveExportOptions(state.exportOptions);
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

    final service = videoConcatService;
    final buffer = StringBuffer();
    final preInputArgs = state.exportOptions.toPreInputArgs();
    logger.d('extraArgs=$extraArgs preInputArgs=$preInputArgs');

    final startTime = DateTime.now();

    try {
      List<ChapterInfo>? chapters;
      if (state.exportOptions.addChapters) {
        logger.d('构建章节信息...');
        chapters = await buildChapters(
          ffprobe: vm._getFfprobeService(),
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
        generateResult: GenerateResult(
          state: GenerateState.failed,
          output: buffer.toString(),
          errorMessage: e.toString(),
          elapsedDuration: elapsedDuration,
        ),
      );
      vm._setErrorMessage('合并失败：$e');
    }
  }

  SegmentOutputOptions? _buildSegmentOutputOptions(String outputPath) {
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
}
