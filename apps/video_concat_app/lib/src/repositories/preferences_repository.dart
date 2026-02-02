import 'package:shared_preferences/shared_preferences.dart';

/// 用户偏好存储
class PreferencesRepository {
  static const _keyExtension = 'output_extension';
  static const _keyFFmpegPath = 'ffmpeg_path';

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
}
