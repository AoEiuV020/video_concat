# HDR 预览 Tone Mapping

HDR 视频（HDR10、HDR10+、HLG）直接提取帧为 JPEG 时，由于色彩空间和传输特性不匹配，画面会明显发白/过曝。需要在帧提取时进行 HDR→SDR tone mapping。

## HDR 判断

通过 ffprobe 的 `color_transfer` 字段识别：

| color_transfer | 标准 |
|---|---|
| `smpte2084` | HDR10 / HDR10+ |
| `arib-std-b67` | HLG |

其他值（如 `bt709`、`unknown`）均为 SDR，无需处理。

## CPU 方案：zscale + tonemap

兼容性最好，不依赖 GPU。需要 FFmpeg 编译时启用 [libzimg](https://github.com/sekrit-tw/zimg)。

```bash
ffmpeg -ss 00:01:00 -i input.mp4 -vframes 1 -q:v 5 \
  -vf "zscale=t=linear:npl=100,format=gbrpf32le,\
       zscale=p=bt709,tonemap=tonemap=hable:desat=0,\
       zscale=t=bt709:m=bt709:r=tv,format=yuv420p,\
       scale=640:-1" \
  -f image2pipe -vcodec mjpeg pipe:1
```

### 滤镜链说明

| 步骤 | 滤镜 | 作用 |
|---|---|---|
| 线性化 | `zscale=t=linear:npl=100` | PQ/HLG 传输曲线 → 线性光，npl=100 为标称亮度 |
| 格式转换 | `format=gbrpf32le` | 转为 32 位浮点，避免 tone mapping 精度丢失 |
| 色域转换 | `zscale=p=bt709` | BT.2020 色域 → BT.709 |
| Tone mapping | `tonemap=tonemap=hable:desat=0` | Hable 曲线压缩亮度范围，desat=0 保留饱和度 |
| 传输/矩阵 | `zscale=t=bt709:m=bt709:r=tv` | 应用 BT.709 传输曲线和颜色矩阵 |
| 像素格式 | `format=yuv420p` | 转为 JPEG 兼容格式 |
| 缩放 | `scale=W:-1` | 按指定宽度等比缩放 |

### Tone mapping 算法对比

| 算法 | 特点 |
|---|---|
| `hable` | 胶片感，高光压缩自然，推荐默认选择 |
| `reinhard` | 整体偏亮，简单线性映射 |
| `mobius` | 类似 reinhard 但高光过渡更平滑 |
| `bt2390` | ITU-R BT.2390 标准算法 |

## GPU 方案

### OpenCL（FFmpeg 4.2+）

```bash
-vf "format=p010,hwupload,tonemap_opencl=tonemap=hable:format=yuv420p:range=pc,hwdownload,format=yuv420p"
```

### libplacebo / Vulkan（FFmpeg 5.0+）

```bash
-vf "libplacebo=colorspace=bt709:color_primaries=bt709:color_trc=bt709:tonemapping=hable:format=yuv420p"
```

GPU 方案速度更快，但依赖硬件和编译选项，帧提取场景下 CPU 方案延迟足够低（< 100ms），优先使用 CPU 方案。
