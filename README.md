# Video Concat

视频合并工具 - 快速无损合并多个视频文件。

## 特性

- 🚀 **无损合并** - 不重新编码，保持原始画质
- 📁 **拖放支持** - 直接拖放视频文件到窗口
- 🔄 **自由排序** - 拖动调整视频顺序
- ⚡ **极速处理** - 直接复制流，秒级完成

## 重要说明

### 无损合并的要求

本工具使用 FFmpeg 的 `concat demuxer` 方式，**直接复制视频流而不重新编码**。这意味着：

- ✅ 合并速度极快（几乎是文件复制速度）
- ✅ 不损失任何画质
- ⚠️ **要求所有视频片段参数完全一致**

### 必须一致的参数

| 参数 | 说明 |
|------|------|
| **视频编码** | 如 H.264、H.265/HEVC、VP9 |
| **分辨率** | 如 1920x1080、3840x2160 |
| **帧率** | 如 24fps、30fps、60fps |
| **音频编码** | 如 AAC、MP3、Opus |
| **音频采样率** | 如 44100Hz、48000Hz |
| **音频声道数** | 如 单声道、立体声、5.1 声道 |

### 参数不一致会怎样？

- 视频分辨率不同 → 播放可能花屏或黑屏
- 帧率不同 → 可能出现卡顿或跳帧
- 音频参数不同 → 音画不同步或无声

### 建议

1. 合并来自同一设备、同一设置录制的视频
2. 使用相同软件导出的视频片段
3. 如参数不一致，需先用其他工具统一转码

## 系统要求

| 平台 | 状态 | 说明 |
|------|------|------|
| **macOS** | ✅ 已测试 | macOS 10.15+ |
| **Windows** | 🔧 理论支持 | 未测试 |
| **Linux** | 🔧 理论支持 | 未测试 |

所有平台均需安装 FFmpeg 并在设置中指定路径。

## 安装 FFmpeg

### macOS

```bash
brew install ffmpeg
```

### Windows

从 [FFmpeg 官网](https://ffmpeg.org/download.html) 下载，解压后在设置中指定 ffmpeg.exe 路径。

### Linux

```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# Fedora
sudo dnf install ffmpeg

# Arch
sudo pacman -S ffmpeg
```

## 开发

```bash
# 安装依赖
melos bootstrap

# 代码生成
melos gen --no-select

# 运行应用
melos exec --scope=video_concat_app -- flutter run -d macos
# 或 Windows
melos exec --scope=video_concat_app -- flutter run -d windows
# 或 Linux
melos exec --scope=video_concat_app -- flutter run -d linux
```  
