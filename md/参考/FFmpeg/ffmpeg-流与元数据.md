# ffmpeg 流与元数据

stream copy 模式下的流控制和元数据操作参数。

## 去除字幕

```bash
ffmpeg -i input.mp4 -c copy -sn output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-sn`](https://ffmpeg.org/ffmpeg.html#Subtitle-options) | 禁用所有字幕输出流 |

## 元数据旋转

通过 display matrix 标记旋转角度，不改变像素数据，播放器根据标记旋转显示。

```bash
ffmpeg -display_rotation:v:0 90 -i input.mp4 -c copy output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-display_rotation:v:0 X`](https://ffmpeg.org/ffmpeg.html#Advanced-Video-options) | 设置第一条视频流的旋转角度（逆时针），X 为角度（0/90/180/270） |

> `-display_rotation` 是**输入选项**，必须放在 `-i` 之前。于 [2022-10-19](https://github.com/FFmpeg/FFmpeg/commit/c889248647780753ec8b05138c7de4a707adb106) 加入 FFmpeg，首次包含在 FFmpeg 6.0 中。

### 已废弃的旋转方式

| 写法 | 状态 |
|------|------|
| `-metadata:s:v rotate=90` | ❌ 已废弃，[不生效](https://ffmpeg.org/pipermail/ffmpeg-user/2024-July/058428.html) |
| `-metadata:s:v:0 rotate=90` | ❌ 已废弃，FFmpeg 7.0+ 同样不生效 |

## 快速启动

将 MP4 的 moov atom 移至文件开头，优化网络流播放：

```bash
ffmpeg -i input.mp4 -c copy -movflags +faststart output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-movflags +faststart`](https://ffmpeg.org/ffmpeg-formats.html#Options-11) | moov atom 前置，仅对 MP4/MOV 容器有效 |

其他容器格式（MKV/AVI/WebM）设置此参数无效果，不会报错但会被忽略。

## 清除元数据

移除容器级别的所有元数据（拍摄设备、GPS、标题等）：

```bash
ffmpeg -i input.mp4 -c copy -map_metadata -1 output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-map_metadata -1`](https://ffmpeg.org/ffmpeg.html#Advanced-options) | 不从任何输入映射元数据到输出 |

> 此选项清除的是容器级元数据。流级别的 codec 信息（分辨率、编码格式）不受影响。

## 章节注入

使用 [FFMETADATA1 格式](https://ffmpeg.org/ffmpeg-formats.html#Metadata-1)注入章节标记：

### 元数据文件格式

```
;FFMETADATA1
[CHAPTER]
TIMEBASE=1/1000
START=0
END=149999
title=Part 1

[CHAPTER]
TIMEBASE=1/1000
START=150000
END=299999
title=Part 2
```

| 字段 | 说明 |
|------|------|
| `TIMEBASE=1/1000` | 时间单位为毫秒 |
| `START` / `END` | 章节起止时间（毫秒） |
| `title` | 章节标题 |

### 注入命令

```bash
ffmpeg -i input.mp4 -i chapters.txt -map_metadata 1 -c copy output.mp4
```

| 参数 | 说明 |
|------|------|
| `-i chapters.txt` | [元数据文件](https://ffmpeg.org/ffmpeg-formats.html#Metadata-1)作为第二输入 |
| [`-map_metadata 1`](https://ffmpeg.org/ffmpeg.html#Advanced-options) | 从输入索引 1（章节文件）映射元数据到输出 |

章节注入适用于 MP4、MKV 等[支持章节的容器](https://ikyle.me/blog/2020/add-mp4-chapters-ffmpeg)。

## 参数组合注意事项

| 场景 | 注意 |
|------|------|
| `-an` + `-acodec copy` | 互斥，不能同时使用 |
| `-map_metadata -1` + 章节注入 | 冲突：`-map_metadata -1` 清除元数据，`-map_metadata 1` 映射章节；需二选一 |
| 章节注入 + MP4 输出 | MP4 muxer 会自动创建 `bin_data`（text）流作为章节文本轨道，这是 QuickTime 章节格式的内部表示，无法通过 `-map`/`-dn` 去除；MKV 不会产生此流。实测 `-map 0`、`-map 0:v -map 0:a`、`-dn` 均无效 |
| `-movflags +faststart` + 非 mp4/mov | 参数被忽略，不报错 |
