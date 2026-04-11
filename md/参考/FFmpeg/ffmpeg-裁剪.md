# ffmpeg 裁剪定位

无损裁剪（`-c copy`）的时间定位参数，包括命令行直接裁剪和 concat demuxer 文件列表裁剪。

## 命令行裁剪

### `-ss`（Seek Start）

指定输入或输出的起始时间点。

```bash
# 输入级寻址（放在 -i 之前）
ffmpeg -ss 00:01:30 -i input.mp4 -c copy output.mp4

# 输出级寻址（放在 -i 之后）
ffmpeg -i input.mp4 -ss 00:01:30 -c copy output.mp4
```

| 位置 | 行为 | 速度 | 精度 |
|------|------|------|------|
| `-i` 之前（[输入级寻址](https://ffmpeg.org/ffmpeg.html#Main-options)） | 直接跳转到目标时间附近的关键帧 | 快（不解码跳过的帧） | 关键帧级，起点为目标时间前最近的 I帧 |
| `-i` 之后（输出级寻址） | 解码后丢弃目标时间前的帧 | 慢（需解码所有跳过的帧） | 帧级（但 `-c copy` 下仍受关键帧限制，可能出现花屏） |

**无损裁剪推荐**：`-ss` 放在 `-i` 之前，配合预先对齐到关键帧的时间戳。

### `-to`（End Time）

指定结束时间点（绝对时间戳）。

```bash
ffmpeg -ss 00:01:30 -to 00:03:00 -i input.mp4 -c copy output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-to`](https://ffmpeg.org/ffmpeg.html#Main-options) | 在指定的时间戳处停止输出。当与 `-ss` 同时使用且都在 `-i` 之前时，`-to` 是相对于输入文件的绝对时间 |

### `-t`（Duration）

指定输出时长。

```bash
ffmpeg -ss 00:01:30 -t 90 -i input.mp4 -c copy output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-t`](https://ffmpeg.org/ffmpeg.html#Main-options) | 限制输出时长（秒或 `HH:MM:SS` 格式）。与 `-to` 互斥 |

### `-to` 与 `-t` 的区别

| 参数 | 含义 | 示例 | 实际输出范围 |
|------|------|------|-------------|
| `-ss 60 -to 120` | 从 60s 到 120s | 60 秒片段 | 60s → 120s |
| `-ss 60 -t 30` | 从 60s 开始取 30 秒 | 30 秒片段 | 60s → 90s |

> 当 `-ss` 和 `-to` 都放在 `-i` 之前时，`-to` 是输入文件的绝对时间。当 `-ss` 在 `-i` 之前、`-to` 在 `-i` 之后时，`-to` 变为相对于 `-ss` 的偏移（等效于 `-t`）。为避免混淆，建议 `-ss` 和 `-to`/`-t` 放在同一侧。

## concat demuxer 裁剪指令

concat demuxer 的文件列表支持 [`inpoint` 和 `outpoint` 指令](https://ffmpeg.org/ffmpeg-formats.html#concat-1)，可在拼接时对单个文件进行裁剪。

### 语法

```
file 'video1.mp4'

file 'video2.mp4'
inpoint 4.004
outpoint 28.028

file 'video3.mp4'
outpoint 15.015
```

```bash
ffmpeg -y -f concat -safe 0 -i filelist.txt -c copy output.mp4
```

### `inpoint`

```
inpoint timestamp
```

| 属性 | 说明 |
|------|------|
| 作用 | demuxer 打开文件后立即 [seek 到指定时间戳](https://ffmpeg.org/ffmpeg-formats.html#concat-1) |
| 寻址方式 | "Seeking is done so that all streams can be presented successfully at In point" |
| intra 编码 | 效果最佳，可精确定位 |
| inter 编码（H.264/HEVC） | 会包含 inpoint 之前的额外包（从前一个关键帧开始），解码内容也可能包含 inpoint 之前的帧 |
| 时间戳影响 | inpoint 之前的包的时间戳会小于文件的计算起始时间（首个文件时为负值） |
| 时长影响 | 未指定 `duration` 时，文件时长会根据 inpoint 自动缩减 |

### `outpoint`

```
outpoint timestamp
```

| 属性 | 说明 |
|------|------|
| 作用 | 当任意流的解码时间戳达到指定值时，[停止读取并跳过后续所有包](https://ffmpeg.org/ffmpeg-formats.html#concat-1) |
| 排他性 | **outpoint 是排他的**：不会输出解码时间戳 ≥ outpoint 的包 |
| intra 编码 | 效果最佳 |
| inter 编码 | 可能输出展示时间戳（PTS）超过 outpoint 的额外包，解码内容可能包含 outpoint 之后的帧 |
| 流交织 | 如果流的交织不紧密，可能无法获取所有流在 outpoint 之前的全部包 |
| 时长影响 | 未指定 `duration` 时，文件时长会根据 outpoint 自动缩减 |

### `duration`

```
duration dur
```

| 属性 | 说明 |
|------|------|
| 作用 | [覆盖文件的时长信息](https://ffmpeg.org/ffmpeg-formats.html#concat-1)，用于计算下一个文件的起始时间戳 |
| 使用场景 | 文件内嵌时长不准确时（如码率估算或文件截断），或配合 `inpoint`/`outpoint` 使用时 |
| 全局定位 | 如果所有文件都设置了 duration，整个拼接视频支持 seek |

## 组合使用注意事项

| 场景 | 注意 |
|------|------|
| `inpoint` + 章节注入 | 章节时长需用裁剪后的实际时长（`outpoint - inpoint`），而非原始文件时长 |
| `inpoint`/`outpoint` + `-an` | 正常兼容，音频流同样在 inpoint/outpoint 范围内截取 |
| `inpoint`/`outpoint` + `-map_metadata -1` | 正常兼容 |
| `inpoint`/`outpoint` + `-movflags +faststart` | 正常兼容 |
| 多文件混合裁剪 | 部分文件有 inpoint/outpoint、部分没有，完全合法 |
| `duration` + `inpoint`/`outpoint` | 设置 `duration` 可覆盖自动计算的时长，确保时间戳连续性 |

## 关键帧边界测试结果

测试环境：120fps HEVC MKV，关键帧间隔约 2.083s。

| 片段 | 帧数 |
|------|------|
| A: 0 → 2.083s | 251 |
| B: 2.083s → 4.167s | 251 |
| A+B 拼接 | 502 |
| 直接 0 → 4.167s | 501 |

**结论**：相邻片段在关键帧边界有 **1 帧重复**。`-c copy` 模式下，concat demuxer 的 outpoint 并非严格排他，边界关键帧同时出现在前后两段。

**影响评估**：120fps 下 1 帧 = 8.3ms，肉眼不可见，暂不修复。
