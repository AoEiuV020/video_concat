# ffprobe 关键帧探测

> 基于 **ffprobe 7.1.1**。旧版 `pkt_pts_time` 字段已废弃（[Trac #9543](https://trac.ffmpeg.org/ticket/9543)），使用 `pts_time` 替代。

## 基础命令

```bash
ffprobe -v quiet -select_streams v:0 -skip_frame nokey \
  -show_entries frame=pts_time \
  -of default=noprint_wrappers=1:nokey=1 input.mp4
```

输出：

```
0.000000
2.083000
4.167000
6.250000
```

| 参数 | 说明 |
|------|------|
| `-v quiet` | 抑制日志输出 |
| [`-select_streams v:0`](https://ffmpeg.org/ffprobe.html#Stream-specifiers-1) | 只处理第一条视频流 |
| [`-skip_frame nokey`](https://ffmpeg.org/ffprobe.html) | 跳过非关键帧，只解码关键帧，大幅提升性能 |
| [`-show_entries frame=pts_time`](https://ffmpeg.org/ffprobe.html#show_005fentries) | 只输出 PTS 时间戳字段，隐式启用帧级输出（无需 `-show_frames`） |
| [`-of default=noprint_wrappers=1:nokey=1`](https://ffmpeg.org/ffprobe.html#default) | 纯值输出，每行一个时间戳，无节名包裹和字段名 |

## 局部探测（`-read_intervals`）

[`-read_intervals`](https://ffmpeg.org/ffprobe.html#read_005fintervals) 限制 ffprobe 只读取指定时间范围内的帧，避免遍历整个文件。

### 语法

```
-read_intervals INTERVAL[,INTERVAL...]
```

每个 INTERVAL 格式为 `[START]%[END]`：

| 语法 | 含义 | 示例 |
|------|------|------|
| `START%END` | 从 START 到 END（绝对时间，秒） | `50%70` = 50s 到 70s |
| `START%+DURATION` | 从 START 开始读 DURATION 时长 | `50%+20` = 50s 到 70s |
| `%END` | 从文件开头到 END | `%10` = 0s 到 10s |
| `START%` | 从 START 到文件末尾 | `50%` = 50s 到末尾 |
| 多区间（逗号分隔） | 读取多个不连续区间 | `0%10,50%60` |

> **注意**：多区间查询在边界处可能产生重复关键帧（实测确认），调用方需去重。

### 查找指定时间附近的关键帧

场景：用户指定时间 T=60s，需要找到 T 前后最近的关键帧。

```bash
ffprobe -v quiet -read_intervals 50%70 \
  -select_streams v:0 -skip_frame nokey \
  -show_entries frame=pts_time \
  -of default=noprint_wrappers=1:nokey=1 input.mp4
```

从输出中找 ≤ T 的最大值（前一个关键帧）和 > T 的最小值（后一个关键帧）。

### 窗口大小选择

| GOP 典型长度 | 建议窗口 | 说明 |
|-------------|---------|------|
| 1~2 秒（手机 H.264） | ±5 秒 | 窗口内通常有 3~5 个关键帧 |
| 2~4 秒（运动相机 HEVC） | ±10 秒 | 保证至少覆盖 2 个 GOP |
| 5~10 秒（屏幕录制） | ±15 秒 | GOP 较长时需要更大窗口 |

如果窗口内未找到关键帧，应逐步扩大窗口重试（如 ±10s → ±20s → ±30s）。

### 性能优势

| 方案 | 1分钟视频 | 1小时视频 | 说明 |
|------|----------|----------|------|
| 全量扫描 `-skip_frame nokey` | ~0.5s | ~10s | 与文件时长线性相关 |
| `-read_intervals` 20s 窗口 | ~0.1s | ~0.1s | 与窗口大小相关，不受文件时长影响 |

## 输出格式

| 格式 | 参数 | 特点 |
|------|------|------|
| default（推荐） | `-of default=noprint_wrappers=1:nokey=1` | 每行一个值，无尾逗号，适合单字段查询 |
| CSV | `-of csv=p=0` | **单字段有尾逗号**（`0.000000,`），多字段末尾也有尾逗号，需 trim |
| JSON | `-of json` | 结构化输出，但 HDR 视频会包含空的 `side_data_list` 节点 |

> 项目代码使用 `default` 格式解析时间戳，避免 CSV 尾逗号导致 `double.tryParse()` 失败。

## 附加字段

多字段查询时使用 CSV 格式：

```bash
ffprobe -v quiet -select_streams v:0 -skip_frame nokey \
  -show_entries frame=pts_time,pkt_pos,pkt_size \
  -of csv=p=0 input.mp4
```

输出：

```
0.000000,978,20043,
2.083000,1696325,427724,
```

| 字段 | 说明 |
|------|------|
| `pts_time` | 展示时间戳（秒） |
| `pkt_pos` | 包在文件中的字节偏移 |
| `pkt_size` | 包大小（字节） |

## 探测方案对比

| 方案 | 命令核心 | 原理 | 性能 |
|------|---------|------|------|
| `-read_intervals` + `-skip_frame nokey`（推荐） | 局部区间 + 只处理关键帧 | 只读目标时间窗口内的关键帧 | 最快，与视频时长无关 |
| `-skip_frame nokey` 全量 | 遍历全文件 | [解码器只处理关键帧](https://blog.programster.org/ffmpeg-extract-keyframe-indexes) | 快，仅遍历 I帧 |
| 帧级过滤 | `-show_entries frame=pts_time,key_frame` + grep | 输出所有帧后过滤 | 慢，遍历全部帧 |
| 包级过滤 | `-show_entries packet=pts_time,flags` + grep `K` | 包级别输出后过滤 | 中等，不需解码但数据量大 |
