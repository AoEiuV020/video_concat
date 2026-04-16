import 'package:shared_preferences/shared_preferences.dart';

import '../models/export_options.dart';

/// 用户偏好存储
class PreferencesRepository {
  static const _keyExtension = 'output_extension';
  static const _keyFFmpegPath = 'ffmpeg_path';

  // 导出选项键
  static const _keyExportRemember = 'export_remember';
  static const _keyExportShowOptions = 'export_show_options';
  static const _keyExportRotation = 'export_rotation';
  static const _keyExportRemoveAudio = 'export_remove_audio';
  static const _keyExportRemoveSubtitles = 'export_remove_subtitles';
  static const _keyExportFastStart = 'export_fast_start';
  static const _keyExportStripMetadata = 'export_strip_metadata';
  static const _keyExportAddChapters = 'export_add_chapters';
  static const _keyExportAutoOpenVideoInfo = 'export_auto_open_video_info';
  static const _keyExportEnableSegmentOutput = 'export_enable_segment_output';
  static const _keyExportSegmentDurationText = 'export_segment_duration_text';
  static const _keyExportSegmentFilenameTemplate =
      'export_segment_filename_template';

  /// 获取上次使用的输出后缀
  Future<String> getLastExtension() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyExtension) ?? 'mp4';
  }

  /// 保存输出后缀
  Future<void> saveLastExtension(String extension) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExtension, extension);
  }

  /// 获取 FFmpeg 路径
  Future<String?> getFFmpegPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFFmpegPath);
  }

  /// 保存 FFmpeg 路径
  Future<void> saveFFmpegPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFFmpegPath, path);
  }

  /// 加载导出选项
  Future<ExportOptions> loadExportOptions() async {
    final prefs = await SharedPreferences.getInstance();
    return ExportOptions(
      rememberChoices: prefs.getBool(_keyExportRemember) ?? false,
      showOptions: prefs.getBool(_keyExportShowOptions) ?? false,
      rotation: prefs.containsKey(_keyExportRotation)
          ? prefs.getInt(_keyExportRotation)
          : null,
      removeAudio: prefs.getBool(_keyExportRemoveAudio) ?? false,
      removeSubtitles: prefs.getBool(_keyExportRemoveSubtitles) ?? false,
      fastStart: prefs.getBool(_keyExportFastStart) ?? false,
      stripMetadata: prefs.getBool(_keyExportStripMetadata) ?? false,
      addChapters: prefs.getBool(_keyExportAddChapters) ?? false,
      autoOpenVideoInfo: prefs.getBool(_keyExportAutoOpenVideoInfo) ?? false,
      enableSegmentOutput:
          prefs.getBool(_keyExportEnableSegmentOutput) ?? false,
      segmentDurationText: prefs.getString(_keyExportSegmentDurationText) ?? '',
      segmentFilenameTemplate:
          prefs.getString(_keyExportSegmentFilenameTemplate) ??
          '%filename%_%03d',
    );
  }

  /// 保存导出选项（仅在开始合并时调用）
  ///
  /// [rememberChoices] 开关本身始终保存。
  /// 其余选项仅在 rememberChoices 为 true 时保存。
  Future<void> saveExportOptions(ExportOptions options) async {
    final prefs = await SharedPreferences.getInstance();

    // 始终保存 remember 开关本身
    await prefs.setBool(_keyExportRemember, options.rememberChoices);

    // 仅在 remember 为 true 时保存其余选项
    if (options.rememberChoices) {
      await prefs.setBool(_keyExportShowOptions, options.showOptions);
      if (options.rotation != null) {
        await prefs.setInt(_keyExportRotation, options.rotation!);
      } else {
        await prefs.remove(_keyExportRotation);
      }
      await prefs.setBool(_keyExportRemoveAudio, options.removeAudio);
      await prefs.setBool(_keyExportRemoveSubtitles, options.removeSubtitles);
      await prefs.setBool(_keyExportFastStart, options.fastStart);
      await prefs.setBool(_keyExportStripMetadata, options.stripMetadata);
      await prefs.setBool(_keyExportAddChapters, options.addChapters);
      await prefs.setBool(
        _keyExportAutoOpenVideoInfo,
        options.autoOpenVideoInfo,
      );
      await prefs.setBool(
        _keyExportEnableSegmentOutput,
        options.enableSegmentOutput,
      );
      await prefs.setString(
        _keyExportSegmentDurationText,
        options.segmentDurationText,
      );
      await prefs.setString(
        _keyExportSegmentFilenameTemplate,
        options.segmentFilenameTemplate,
      );
    } else {
      await prefs.remove(_keyExportShowOptions);
      await prefs.remove(_keyExportRotation);
      await prefs.remove(_keyExportRemoveAudio);
      await prefs.remove(_keyExportRemoveSubtitles);
      await prefs.remove(_keyExportFastStart);
      await prefs.remove(_keyExportStripMetadata);
      await prefs.remove(_keyExportAddChapters);
      await prefs.remove(_keyExportAutoOpenVideoInfo);
      await prefs.remove(_keyExportEnableSegmentOutput);
      await prefs.remove(_keyExportSegmentDurationText);
      await prefs.remove(_keyExportSegmentFilenameTemplate);
    }
  }
}
