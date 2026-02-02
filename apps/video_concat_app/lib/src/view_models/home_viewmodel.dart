import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/models.dart';
import 'home_state.dart';
import 'providers.dart';

part 'home_viewmodel.g.dart';

/// 主页 ViewModel
@riverpod
class HomeViewModel extends _$HomeViewModel {
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
  void addVideos(List<String> filePaths) {
    final newItems = filePaths.map((path) {
      final fileName = path.split('/').last.split('\\').last;
      return VideoItem(
        id: DateTime.now().microsecondsSinceEpoch.toString() +
            filePaths.indexOf(path).toString(),
        filePath: path,
        fileName: fileName,
      );
    }).toList();

    final items = [...state.videoItems, ...newItems];
    state = state.copyWith(
      videoItems: items,
      outputConfig: _updateBaseName(items, state.outputConfig),
    );
  }

  /// 删除视频
  void removeVideo(String id) {
    final items = state.videoItems.where((v) => v.id != id).toList();
    state = state.copyWith(
      videoItems: items,
      outputConfig: _updateBaseName(items, state.outputConfig),
    );
  }

  /// 重新排序
  void reorderVideo(int oldIndex, int newIndex) {
    final items = [...state.videoItems];
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(videoItems: items);
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

      state = state.copyWith(
        isGenerating: false,
        generateResult: GenerateResult(
          state: exitCode == 0 ? GenerateState.success : GenerateState.failed,
          output: buffer.toString(),
          errorMessage: exitCode == 0 ? null : 'FFmpeg 退出码: $exitCode',
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
}
