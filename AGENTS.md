# AGENTS.md

## Commands

```bash
# 依赖
melos bs                         # bootstrap，获取所有包的依赖

# 代码生成（freezed / riverpod_generator）
melos gen

# 静态分析
melos analyze

# 测试 → 加载 flutter-test skill

# 提交前格式化
melos precommit                  # = melos fix + melos format + melos sort

# 构建 → 加载 flutter-build skill
```

## Tech Stack

- **语言**: Dart 3.10+ / Flutter
- **结构**: Dart workspace（根 `pubspec.yaml` + `workspace:` 指令）
  - `apps/video_concat_app` — Flutter macOS 桌面应用
  - `packages/ffmpeg_kit` — 纯 Dart FFmpeg/FFprobe 封装库
- **状态管理**: Riverpod + riverpod_annotation（代码生成）
- **路由**: go_router
- **模型**: freezed + freezed_annotation
- **日志**: logger 包（见下方约定）
- **Lint**: flutter_lints（app）/ lints（package）

## Directory Structure

### App (`apps/video_concat_app/lib/src/`)

| 目录 | 职责 |
|------|------|
| `models/` | 业务数据模型（freezed） |
| `repositories/` | 持久化存储 |
| `router/` | 路由配置（go_router） |
| `utils/` | 工具函数 |
| `view_models/` | ViewModel + State，按功能分子目录（home/trim/settings/video_info） |
| `views/` | UI 页面和组件，按功能分子目录 |

### 文档 (`md/`)

| 目录 | 职责 |
|------|------|
| `参考/` | 与项目无关的外部知识参考（FFmpeg 命令、第三方库 API） |
| `设计/` | 本项目的设计决策（架构、功能设计、Flutter 选型） |
| `临时/` | 在 .gitignore 中，不提交 |

## Code Style

- 使用 `prefer_relative_imports`
- 分析选项在各子项目 `analysis_options.yaml` 中配置
- ViewModel 使用 `@riverpod` 注解，修改后需 `build_runner build`
- 提交前 `dart analyze` 无 error / warning

### 日志约定

- 使用 `logger` 包，**禁止 `print` / `dart:developer`**
- App 入口调用 `setupLogging()` 设置全局默认值
- 每个库在 `lib/src/log.dart` 定义一个不导出的 `Logger` 实例，仅库内部使用
- 只有 app 模块设置 `Logger` 静态默认值
- 用 `.d()` `.i()` `.w()` `.e()` 记录，error 级别传 `error:` 和 `stackTrace:`

## Boundaries

- **禁止重编码**: 所有视频操作必须无损（lossless），不允许 re-encoding
- **编译验证**: 提交代码前执行 `dart analyze` + `flutter test` + `flutter build macos --debug`
- **总结文档**: 完成复杂任务后在 `md/临时/` 新建总结文档（每次独立文件）
- `md/临时/` 在 .gitignore 中，不提交
- `md/指令/` 不可查看或修改
- `git add -f` 禁止使用

## Git Workflow

- 功能分支: `feat/<name>`
- Commit message 使用中文
- 提交前跑完整验证流程（analyze + test + build）
