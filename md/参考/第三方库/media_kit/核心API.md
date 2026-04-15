# 核心 API

## Player

播放控制核心类。管理媒体加载、播放控制、状态查询和事件流。

### 创建与销毁

```dart
// 创建
final player = Player();

// 带配置创建
final player = Player(
  configuration: PlayerConfiguration(
    title: 'My Player',
    ready: () => print('Initialized'),
  ),
);

// 销毁（必须调用，释放原生资源）
await player.dispose();
```

### 打开媒体

```dart
// 单个文件
await player.open(Media('file:///path/to/video.mp4'));

// 不自动播放
await player.open(Media('/path/to/video.mp4'), play: false);

// 播放列表
await player.open(Playlist([
  Media('file:///a.mp4'),
  Media('file:///b.mp4'),
], index: 0));
```

### 播放控制

| 方法 | 说明 |
|------|------|
| `player.play()` | 开始/恢复播放 |
| `player.pause()` | 暂停 |
| `player.playOrPause()` | 切换播放/暂停 |
| `player.stop()` | 停止播放（不释放资源） |
| `player.seek(Duration)` | 跳转到指定位置 |
| `player.next()` | 下一曲 |
| `player.previous()` | 上一曲 |
| `player.jump(int index)` | 跳到播放列表指定位置 |

### 参数设置

| 方法 | 范围 | 说明 |
|------|------|------|
| `player.setVolume(double)` | 0.0 ~ 100.0 | 音量 |
| `player.setRate(double)` | 0.25 ~ 4.0 | 播放速率 |
| `player.setPitch(double)` | — | 音调（需配置中开启 `pitch: true`） |
| `player.setPlaylistMode(PlaylistMode)` | none/single/loop | 循环模式 |
| `player.setShuffle(bool)` | — | 随机播放 |

### 截图

```dart
// JPEG 格式
final Uint8List? jpeg = await player.screenshot(format: 'image/jpeg');

// PNG 格式
final Uint8List? png = await player.screenshot(format: 'image/png');

// BGRA 原始像素
final Uint8List? bgra = await player.screenshot();
```

### 音视频轨道选择

```dart
// 获取可用轨道
List<VideoTrack> videos = player.state.tracks.video;
List<AudioTrack> audios = player.state.tracks.audio;
List<SubtitleTrack> subs = player.state.tracks.subtitle;

// 选择轨道
await player.setVideoTrack(videos[0]);
await player.setAudioTrack(AudioTrack.auto());
await player.setSubtitleTrack(SubtitleTrack.no()); // 禁用字幕

// 外部字幕
await player.setSubtitleTrack(SubtitleTrack.uri(
  'https://example.com/subs.srt',
  title: 'English',
  language: 'en',
));
```

## 状态查询（同步）

通过 `player.state.*` 直接获取当前值：

| 属性 | 类型 | 说明 |
|------|------|------|
| `state.playing` | `bool` | 是否正在播放 |
| `state.completed` | `bool` | 是否播放完毕 |
| `state.position` | `Duration` | 当前播放位置 |
| `state.duration` | `Duration` | 媒体总时长 |
| `state.volume` | `double` | 当前音量 |
| `state.rate` | `double` | 当前播放速率 |
| `state.buffering` | `bool` | 是否正在缓冲 |
| `state.buffer` | `Duration` | 已缓冲位置 |
| `state.tracks` | `Tracks` | 可用轨道列表 |
| `state.track` | `Track` | 当前选中轨道 |
| `state.width` | `int?` | 视频宽度 |
| `state.height` | `int?` | 视频高度 |

## 事件流（异步）

通过 `player.stream.*` 订阅状态变化：

| Stream | 类型 | 触发时机 |
|--------|------|---------|
| `stream.playing` | `Stream<bool>` | 播放/暂停状态变化 |
| `stream.completed` | `Stream<bool>` | 播放到达末尾 |
| `stream.position` | `Stream<Duration>` | 播放位置更新（高频） |
| `stream.duration` | `Stream<Duration>` | 媒体时长确定/变化 |
| `stream.volume` | `Stream<double>` | 音量变化 |
| `stream.rate` | `Stream<double>` | 播放速率变化 |
| `stream.buffering` | `Stream<bool>` | 缓冲状态变化 |
| `stream.buffer` | `Stream<Duration>` | 缓冲位置更新 |
| `stream.videoParams` | `Stream<VideoParams>` | 视频参数变化（宽高、旋转等） |
| `stream.audioParams` | `Stream<AudioParams>` | 音频参数变化（采样率、声道等） |
| `stream.tracks` | `Stream<Tracks>` | 可用轨道列表变化 |
| `stream.track` | `Stream<Track>` | 选中轨道变化 |
| `stream.width` | `Stream<int>` | 视频宽度变化 |
| `stream.height` | `Stream<int>` | 视频高度变化 |
| `stream.error` | `Stream<String>` | 错误消息 |
| `stream.log` | `Stream<PlayerLog>` | 内部日志 |

### 典型用法

```dart
// 监听播放位置（用于进度条）
player.stream.position.listen((pos) {
  // pos 是 Duration
});

// seek 后等待当前位置真正追上目标
Future<void> seekAndWait(Player player, Duration target) async {
  await player.seek(target);
  await player.stream.position.firstWhere((pos) {
    return (pos - target).abs() <= const Duration(milliseconds: 100);
  });
}

// 监听暂停事件（用于关键帧定位）
player.stream.playing.listen((playing) {
  if (!playing) {
    final currentPos = player.state.position;
    // 在此做关键帧吸附
  }
});

// 监听错误
player.stream.error.listen((error) {
  print('Player error: $error');
});

// 监听播放完成
player.stream.completed.listen((completed) {
  if (completed) {
    print('Playback completed');
  }
});
```

## Media

媒体资源描述。

```dart
// 本地文件
final m1 = Media('file:///path/to/video.mp4');
final m2 = Media('/path/to/video.mp4'); // 自动加 file:// 前缀

// 网络地址
final m3 = Media('https://example.com/video.mp4');

// 带 HTTP 头
final m4 = Media(
  'https://example.com/video.mp4',
  httpHeaders: {'Authorization': 'Bearer token'},
);

// 附加数据
final m5 = Media(
  '/path/to/video.mp4',
  extras: {'title': 'My Video', 'artist': 'Author'},
);
```

`Media` 还支持 `start` 和 `end` 参数（通过 mpv hook 机制在加载时设置）。

## Playlist

播放列表。

```dart
final playlist = Playlist(
  [Media('/a.mp4'), Media('/b.mp4'), Media('/c.mp4')],
  index: 0, // 起始位置
);

// 修改播放列表
await player.add(Media('/d.mp4'));      // 追加
await player.remove(0);                 // 移除
await player.move(from: 1, to: 3);     // 移动
```

## NativePlayer 底层 API

通过 `player.platform as NativePlayer` 访问底层 [mpv 属性和命令](https://mpv.io/manual/master/#options)：

```dart
import 'package:media_kit/media_kit.dart';
// NativePlayer 在 native/player/real.dart 中定义

final native = player.platform as NativePlayer;

// 设置 mpv 属性
await native.setProperty('some-property', 'value');

// 读取 mpv 属性
final value = await native.getProperty('some-property');

// 监听 mpv 属性变化
await native.observeProperty('property-name', (String value) async {
  print('Property changed: $value');
});

// 取消监听
await native.unobserveProperty('property-name');

// 执行 mpv 命令
await native.command(['command', 'arg1', 'arg2']);
```

> 这些方法直接操作底层 libmpv 实例，用于标准 API 未覆盖的高级场景。
