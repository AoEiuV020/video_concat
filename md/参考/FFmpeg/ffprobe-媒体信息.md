# ffprobe 媒体信息探测

获取视频文件的完整媒体信息（编码、分辨率、时长等）。

## 基础命令

```bash
ffprobe -v quiet -print_format json -show_format -show_streams input.mp4
```

| 参数 | 说明 |
|------|------|
| [`-v quiet`](https://ffmpeg.org/ffprobe.html) | 抑制日志输出，只输出结构化数据 |
| [`-print_format json`](https://ffmpeg.org/ffprobe.html#Writers) | JSON 格式输出，便于程序解析 |
| [`-show_format`](https://ffmpeg.org/ffprobe.html#show_005fformat) | 输出容器级信息（时长、码率、格式名） |
| [`-show_streams`](https://ffmpeg.org/ffprobe.html#show_005fstreams) | 输出各流信息（编码、分辨率、帧率、色彩空间） |

## 关键输出字段

### format 部分

| 字段 | 类型 | 说明 |
|------|------|------|
| `format_name` | string | 容器格式（如 `matroska,webm`、`mov,mp4,m4a`） |
| `duration` | string | 总时长（秒），**所有容器格式均可用** |
| `bit_rate` | string | 总码率（bps） |

### streams 部分（视频流）

| 字段 | 类型 | 说明 |
|------|------|------|
| `codec_name` | string | 编码格式（`hevc`、`h264`、`av1`） |
| `profile` | string | 编码配置（`Main 10`、`High`） |
| `width` / `height` | int | 分辨率 |
| `r_frame_rate` | string | 帧率（如 `120/1`、`30000/1001`） |
| `pix_fmt` | string | 像素格式（`yuv420p`、`yuv420p10le`） |
| `color_space` | string | 色彩空间（`bt709`、`bt2020nc`） |
| `color_transfer` | string | 传输特性（`smpte2084` = HDR PQ） |
| `color_primaries` | string | 色域（`bt2020`） |
| `duration` | string | 流时长。**MKV 容器可能返回 `N/A`**，此时用 `format.duration` |

### streams 部分（音频流）

| 字段 | 类型 | 说明 |
|------|------|------|
| `codec_name` | string | 编码格式（`aac`、`opus`、`flac`） |
| `sample_rate` | string | 采样率（Hz） |
| `channels` | int | 声道数 |

## 获取视频总时长

```bash
ffprobe -v quiet \
  -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 input.mp4
```

输出：

```
34197.290000
```

> MKV 容器的流级 `stream.duration` 可能为 `N/A`，应始终从 `format.duration` 获取时长。
