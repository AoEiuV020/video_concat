# sliver_tools

提供 Flutter 框架缺失的 Sliver 工具集，本项目用于实现主页钉住区域（导出选项面板始终可见）。

## 核心用途

| 用途 | 说明 |
|------|------|
| `SliverPinnedHeader` | 自动尺寸的钉住头部，子组件到达视口顶部时固定不动 |
| `MultiSliver` | 将多个 Sliver 组合为一个，支持 `pushPinnedChildren` 实现粘性头部效果 |
| `SliverAnimatedPaintExtent` | Sliver 内容尺寸变化时平滑过渡 |

## API 用法

### SliverPinnedHeader

自动测量子组件高度，滚动到顶部时钉住。无需手动指定 `maxExtent` / `minExtent`。

```dart
import 'package:sliver_tools/sliver_tools.dart';

CustomScrollView(
  slivers: [
    SliverList(...),
    // 子组件到达视口顶部时自动钉住
    SliverPinnedHeader(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ConfigBar(),
            OptionsPanel(),
            ActionButtons(),
          ],
        ),
      ),
    ),
    SliverFillRemaining(child: OutputPanel()),
  ],
);
```

**关键特性**：

| 特性 | 说明 |
|------|------|
| 自动尺寸 | 子组件 layout 后取自然高度，无需预设 |
| 动态高度 | 子组件高度变化（如展开/收起）自动跟随 |
| `paintOrigin` | 使用 `constraints.overlap` 正确处理多个钉住头部的堆叠 |
| `maxScrollObstructionExtent` | 设为子组件高度，确保钉住时正确遮挡滚动内容 |

### SliverAnimatedPaintExtent

包裹 Sliver 子组件，当子组件占用空间变化时平滑动画过渡。

```dart
SliverAnimatedPaintExtent(
  duration: const Duration(milliseconds: 200),
  child: SliverList(
    delegate: SliverChildListDelegate(items),
  ),
);
```

## 本项目使用场景

| 场景 | 使用方式 |
|------|----------|
| 主页钉住区域 | `SliverPinnedHeader` 包裹导出选项面板 + 配置栏 + 操作按钮 |
| 视频列表增删动画 | `SliverAnimatedPaintExtent` 包裹 `SliverReorderableList` |
