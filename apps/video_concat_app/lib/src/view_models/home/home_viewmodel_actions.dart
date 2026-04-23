part of 'home_viewmodel.dart';

final class _HomeViewModelActions {
  _HomeViewModelActions(this.vm);

  final HomeViewModel vm;

  HomeState get state => vm.currentState;
  set state(HomeState value) => vm.currentState = value;

  dynamic get preferencesRepository => vm.preferencesRepository;
  VideoConcatService get videoConcatService => vm.currentVideoConcatService;

  Future<void> addVideos(List<String> filePaths) async {
    logger.d('addVideos ${filePaths.length} 个文件');
    try {
      if (!state.areToolsReady) {
        vm._setErrorMessage(state.toolCheckMessage ?? '外部工具不可用');
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

      vm._checkAndProbe();
    } catch (e, s) {
      vm._reportError('addVideos 失败', e, s, userMessage: '添加视频失败：$e');
    }
  }

  void removeVideo(String id) {
    try {
      logger.d('removeVideo id=$id');
      final items = state.videoItems.where((v) => v.id != id).toList();
      state = state.copyWith(
        videoItems: items,
        outputConfig: _updateBaseName(items, state.outputConfig),
      );
      vm._checkAndProbe();
    } catch (e, s) {
      vm._reportError('removeVideo 失败', e, s, userMessage: '删除视频失败：$e');
    }
  }

  void reorderVideo(int oldIndex, int newIndex) {
    try {
      logger.d('reorderVideo $oldIndex -> $newIndex');
      final items = [...state.videoItems];
      if (newIndex > oldIndex) newIndex--;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      state = state.copyWith(videoItems: items);
      vm._checkAndProbe();
    } catch (e, s) {
      vm._reportError('reorderVideo 失败', e, s, userMessage: '排序失败：$e');
    }
  }

  void updateOutputBaseName(String baseName) {
    try {
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(baseName: baseName),
      );
    } catch (e, s) {
      vm._reportError(
        'updateOutputBaseName 失败',
        e,
        s,
        userMessage: '更新输出文件名失败：$e',
      );
    }
  }

  Future<void> updateOutputExtension(String extension) async {
    logger.d('updateOutputExtension ext=$extension');
    try {
      state = state.copyWith(
        outputConfig: state.outputConfig.copyWith(extension: extension),
      );
      await preferencesRepository.saveLastExtension(extension);

      final isMp4Like = extension == 'mp4' || extension == 'mov';
      if (!isMp4Like && state.exportOptions.fastStart) {
        state = state.copyWith(
          exportOptions: state.exportOptions.copyWith(fastStart: false),
        );
      }
    } catch (e, s) {
      vm._reportError(
        'updateOutputExtension 失败',
        e,
        s,
        userMessage: '更新输出后缀失败：$e',
      );
    }
  }

  void updateExportOptions(ExportOptions options) {
    try {
      final prev = state.exportOptions;
      var resolved = options;

      if (options.stripMetadata && options.addChapters) {
        if (!prev.stripMetadata && options.stripMetadata) {
          resolved = resolved.copyWith(addChapters: false);
        } else if (!prev.addChapters && options.addChapters) {
          resolved = resolved.copyWith(stripMetadata: false);
        }
      }

      if (options.enableCustomSplit && options.enableSegmentOutput) {
        if (!prev.enableCustomSplit && options.enableCustomSplit) {
          resolved = resolved.copyWith(enableSegmentOutput: false);
        } else if (!prev.enableSegmentOutput && options.enableSegmentOutput) {
          resolved = resolved.copyWith(enableCustomSplit: false);
        }
      }

      if (options.enableCustomSplit && options.addChapters) {
        if (!prev.enableCustomSplit && options.enableCustomSplit) {
          resolved = resolved.copyWith(addChapters: false);
        } else if (!prev.addChapters && options.addChapters) {
          resolved = resolved.copyWith(enableCustomSplit: false);
        }
      }

      state = state.copyWith(exportOptions: resolved);
    } catch (e, s) {
      vm._reportError(
        'updateExportOptions 失败',
        e,
        s,
        userMessage: '更新导出选项失败：$e',
      );
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

  void cancelGenerate() {
    try {
      logger.i('cancelGenerate');
      videoConcatService.cancel();
    } catch (e, s) {
      vm._reportError('cancelGenerate 失败', e, s, userMessage: '中断失败：$e');
    }
  }

  void clearResult() {
    state = state.copyWith(generateResult: null, errorMessage: null);
  }

  void reset() {
    try {
      logger.d('reset');
      vm._referenceFilePath = null;
      state = const HomeState();
      vm._initialize();
    } catch (e, s) {
      vm._reportError('reset 失败', e, s, userMessage: '重置失败：$e');
    }
  }
}
