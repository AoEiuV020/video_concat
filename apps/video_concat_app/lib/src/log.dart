import 'package:logger/logger.dart';

export 'package:logger/logger.dart' show Logger, Level;

/// App 全局 Logger 实例。库内部文件直接 import 使用。
///
/// Dart 顶层变量惰性初始化，首次访问时才创建，
/// 因此 [setupLogging] 在 main() 中先调用即可保证默认值生效。
final logger = Logger();

/// 设置全局日志默认配置。在 main() 中调用一次。
void setupLogging() {
  Logger.defaultFilter = () => ProductionFilter();
  Logger.defaultPrinter = () =>
      PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 80);
}
