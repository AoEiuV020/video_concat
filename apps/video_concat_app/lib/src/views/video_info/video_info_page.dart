import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/format_utils.dart';
import '../../view_models/video_info_viewmodel.dart';

/// 视频信息页
class VideoInfoPage extends ConsumerWidget {
  final String filePath;
  final String? refPath;

  const VideoInfoPage({super.key, required this.filePath, this.refPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(
      videoInfoProvider(filePath, refPath: refPath),
    );
    final fileName = filePath.split('/').last.split('\\').last;

    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: asyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '获取信息失败: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (data) => _buildContent(context, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideoInfoData data) {
    final diffFields = _collectDiffFields(data.compareResult);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (data.compareResult != null && !data.compareResult!.isCompatible)
          _buildWarningBanner(data.compareResult!),
        _buildFormatCard(context, data.result.format),
        const SizedBox(height: 12),
        for (final stream in data.result.streams) ...[
          _buildStreamCard(context, stream, diffFields),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// 从对比结果收集差异字段，按流索引+字段名索引。
  Map<int, StreamDiff> _collectDiffFields(ProbeCompareResult? compareResult) {
    if (compareResult == null) return {};
    return {
      for (final diff in compareResult.streamDiffs) diff.index: diff,
    };
  }

  Widget _buildWarningBanner(ProbeCompareResult compareResult) {
    final message = compareResult.streamCountMismatch ?? '编码参数与参考视频不一致，合并时需要重编码';
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
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

  Widget _buildStreamCard(
    BuildContext context,
    StreamInfo stream,
    Map<int, StreamDiff> diffFields,
  ) {
    final title = stream.isVideo
        ? '视频流 #${stream.index}'
        : stream.isAudio
            ? '音频流 #${stream.index}'
            : '流 #${stream.index} (${stream.codecType})';
    final diff = diffFields[stream.index];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _infoRow(
              '编码',
              '${stream.codecName} (${stream.codecLongName})',
              isDiff: diff?.fields.containsKey('codecName') ?? false,
            ),
            if (stream.profile != null)
              _infoRow(
                '配置',
                stream.profile!,
                isDiff: diff?.fields.containsKey('profile') ?? false,
              ),
            if (stream.duration != null) _infoRow('时长', stream.duration!),
            if (stream.isVideo) ..._videoRows(stream, diff),
            if (stream.isAudio) ..._audioRows(stream, diff),
          ],
        ),
      ),
    );
  }

  List<Widget> _videoRows(StreamInfo stream, StreamDiff? diff) {
    return [
      if (stream.width != null && stream.height != null)
        _infoRow(
          '分辨率',
          '${stream.width} × ${stream.height}',
          isDiff: (diff?.fields.containsKey('width') ?? false) ||
              (diff?.fields.containsKey('height') ?? false),
        ),
      _infoRow(
        '帧率',
        formatFrameRate(stream.frameRate),
        isDiff: diff?.fields.containsKey('frameRate') ?? false,
      ),
      if (stream.pixFmt != null)
        _infoRow(
          '像素格式',
          stream.pixFmt!,
          isDiff: diff?.fields.containsKey('pixFmt') ?? false,
        ),
      if (stream.colorSpace != null)
        _infoRow(
          '色彩空间',
          stream.colorSpace!,
          isDiff: diff?.fields.containsKey('colorSpace') ?? false,
        ),
      if (stream.colorTransfer != null)
        _infoRow(
          '传输特性',
          stream.colorTransfer!,
          isDiff: diff?.fields.containsKey('colorTransfer') ?? false,
        ),
      if (stream.colorPrimaries != null)
        _infoRow(
          '色域',
          stream.colorPrimaries!,
          isDiff: diff?.fields.containsKey('colorPrimaries') ?? false,
        ),
      if (stream.colorRange != null)
        _infoRow(
          '色彩范围',
          stream.colorRange!,
          isDiff: diff?.fields.containsKey('colorRange') ?? false,
        ),
    ];
  }

  List<Widget> _audioRows(StreamInfo stream, StreamDiff? diff) {
    return [
      if (stream.sampleRate != null)
        _infoRow(
          '采样率',
          '${stream.sampleRate} Hz',
          isDiff: diff?.fields.containsKey('sampleRate') ?? false,
        ),
      if (stream.channels != null)
        _infoRow(
          '声道数',
          '${stream.channels}',
          isDiff: diff?.fields.containsKey('channels') ?? false,
        ),
      if (stream.channelLayout != null)
        _infoRow(
          '声道布局',
          stream.channelLayout!,
          isDiff: diff?.fields.containsKey('channelLayout') ?? false,
        ),
    ];
  }

  Widget _infoRow(String label, String value, {bool isDiff = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: isDiff ? Colors.red : Colors.grey,
                fontWeight: isDiff ? FontWeight.bold : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isDiff ? const TextStyle(color: Colors.red) : null,
            ),
          ),
        ],
      ),
    );
  }
}
