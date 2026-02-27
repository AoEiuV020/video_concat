import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/format_utils.dart';
import '../../view_models/video_info_viewmodel.dart';

/// 视频信息页
class VideoInfoPage extends ConsumerWidget {
  final String filePath;

  const VideoInfoPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(videoInfoProvider(filePath));
    final fileName = filePath.split('/').last.split('\\').last;

    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: asyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('获取信息失败: $error', style: const TextStyle(color: Colors.red)),
          ),
        ),
        data: (result) => _buildContent(context, result),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProbeResult result) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFormatCard(context, result.format),
        const SizedBox(height: 12),
        for (final stream in result.streams) ...[
          _buildStreamCard(context, stream),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildFormatCard(BuildContext context, FormatInfo format) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('格式信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _infoRow('格式', format.formatLongName),
            _infoRow('时长', formatDuration(format.duration)),
            _infoRow('大小', formatFileSize(format.size)),
            _infoRow('码率', formatBitRate(format.bitRate)),
            _infoRow('流数量', '${format.nbStreams}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamCard(BuildContext context, StreamInfo stream) {
    final title = stream.isVideo
        ? '视频流 #${stream.index}'
        : stream.isAudio
            ? '音频流 #${stream.index}'
            : '流 #${stream.index} (${stream.codecType})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _infoRow('编码', '${stream.codecName} (${stream.codecLongName})'),
            if (stream.profile != null) _infoRow('配置', stream.profile!),
            if (stream.duration != null) _infoRow('时长', stream.duration!),
            if (stream.isVideo) ..._videoRows(stream),
            if (stream.isAudio) ..._audioRows(stream),
          ],
        ),
      ),
    );
  }

  List<Widget> _videoRows(StreamInfo stream) {
    return [
      if (stream.width != null && stream.height != null)
        _infoRow('分辨率', '${stream.width} × ${stream.height}'),
      _infoRow('帧率', formatFrameRate(stream.frameRate)),
      if (stream.pixFmt != null) _infoRow('像素格式', stream.pixFmt!),
      if (stream.colorSpace != null) _infoRow('色彩空间', stream.colorSpace!),
      if (stream.colorTransfer != null) _infoRow('传输特性', stream.colorTransfer!),
      if (stream.colorPrimaries != null) _infoRow('色域', stream.colorPrimaries!),
      if (stream.colorRange != null) _infoRow('色彩范围', stream.colorRange!),
    ];
  }

  List<Widget> _audioRows(StreamInfo stream) {
    return [
      if (stream.sampleRate != null)
        _infoRow('采样率', '${stream.sampleRate} Hz'),
      if (stream.channels != null) _infoRow('声道数', '${stream.channels}'),
      if (stream.channelLayout != null)
        _infoRow('声道布局', stream.channelLayout!),
    ];
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
