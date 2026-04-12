# logger 包 API 参考

Dart [logger](https://pub.dev/packages/logger) v2.x 核心 API。

## Logger 类

```dart
final logger = Logger(
  filter: ProductionFilter(),      // 日志过滤器
  printer: PrettyPrinter(),        // 输出格式化
  output: ConsoleOutput(),         // 输出目标
  level: Level.trace,              // 实例级别覆盖
);
```

### 日志方法

| 方法 | 级别 | 用途 |
|------|------|------|
| `logger.t(message)` | trace | 细粒度追踪 |
| `logger.d(message)` | debug | 开发调试 |
| `logger.i(message)` | info | 关键业务事件 |
| `logger.w(message)` | warning | 潜在问题 |
| `logger.e(message, error: e, stackTrace: s)` | error | 可恢复错误 |
| `logger.f(message, error: e, stackTrace: s)` | fatal | 致命错误 |

所有方法签名：`void x(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace})`

### 静态默认值

在 app 入口设置一次，所有后续 `Logger()` 实例继承：

```dart
Logger.defaultFilter = () => ProductionFilter();
Logger.defaultPrinter = () => PrettyPrinter(methodCount: 0);
Logger.defaultOutput = () => ConsoleOutput();
```

### 全局级别

```dart
Logger.level = Level.debug;  // 低于此级别的日志被过滤
```

## Level 枚举

从低到高：`trace < debug < info < warning < error < fatal`

另有 `Level.off`（禁用）和 `Level.all`（全部）。

## Filter（过滤器）

| 类型 | 行为 |
|------|------|
| `DevelopmentFilter()` | 仅 debug 模式输出（`kDebugMode`） |
| `ProductionFilter()` | 所有模式均输出 |

## Printer（格式化）

### PrettyPrinter

```dart
PrettyPrinter(
  methodCount: 0,        // 调用栈层数（0=不显示）
  errorMethodCount: 5,   // error 级别调用栈层数
  lineLength: 80,        // 分隔线长度
  colors: true,          // ANSI 颜色
  printEmojis: true,     // 级别 emoji 前缀
  dateTimeFormat: DateTimeFormat.none,
)
```

### PrefixPrinter

包装另一个 Printer，为每行添加前缀标签：

```dart
PrefixPrinter(
  PrettyPrinter(methodCount: 0),
  debug: 'MyModule',
  trace: 'MyModule',
  info: 'MyModule',
  warning: 'MyModule',
  error: 'MyModule',
  fatal: 'MyModule',
)
```

### 其他 Printer

| 类型 | 说明 |
|------|------|
| `SimplePrinter()` | 单行输出 |
| `LogfmtPrinter()` | logfmt 格式 |
| `HybridPrinter()` | 按级别使用不同 Printer |

## 项目约定

### 初始化

`apps/video_concat_app/lib/src/log.dart` 提供：

- `setupLogging()` — 设置全局默认 Filter/Printer，在 `main()` 中调用
- `logger` — App 全局 Logger 实例，库内文件直接 import 使用

### 库内使用

```dart
import '../log.dart';

// 常规日志
logger.d('操作详情 key=$value');

// 错误日志（必须传 error 和 stackTrace）
logger.e('操作失败', error: e, stackTrace: s);
```

### 多库架构

每个库（package）在 `lib/src/log.dart` 中定义一个不导出的 Logger 实例，仅供库内部文件 import 使用。只有 app 模块设置 `Logger` 静态默认值。
