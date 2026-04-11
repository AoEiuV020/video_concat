# ffmpeg 拼接

基于 concat demuxer 的无损视频拼接。

## 基础命令

```bash
ffmpeg -y -f concat -safe 0 -i filelist.txt -c copy output.mp4
```

| 参数 | 说明 |
|------|------|
| [`-y`](https://ffmpeg.org/ffmpeg.html#Main-options) | 自动覆盖输出文件 |
| [`-f concat`](https://ffmpeg.org/ffmpeg-formats.html#concat-1) | 使用 concat demuxer 格式 |
| `-safe 0` | 允许文件列表中使用绝对路径和特殊字符 |
| `-i filelist.txt` | 文件列表输入 |
| `-c copy` 或 `-vcodec copy -acodec copy` | stream copy，不重编码 |

## 文件列表格式

```
file 'video1.mp4'
file 'video2.mp4'
file 'video3.mp4'
```

文件列表支持 `inpoint`/`outpoint`/`duration` 裁剪指令，详见 [ffmpeg-裁剪](ffmpeg-裁剪.md#concat-demuxer-裁剪指令)。

## 音频处理

| 参数 | 说明 |
|------|------|
| `-acodec copy` | 音频 [stream copy](https://ffmpeg.org/ffmpeg.html#Stream-copy)，保留原始音频 |
| [`-an`](https://ffmpeg.org/ffmpeg.html#Audio-Options) | 禁用所有音频输出流 |

> `-an` 与 `-acodec copy` **互斥**，不能同时使用。
