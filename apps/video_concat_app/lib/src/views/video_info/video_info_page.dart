import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/video_info/video_info_viewmodel.dart';
import 'widgets/video_info_content.dart';

/// 视频信息页
class VideoInfoPage extends ConsumerWidget {
  final String filePath;
  final String? refPath;

  const VideoInfoPage({super.key, required this.filePath, this.refPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(videoInfoProvider(filePath, refPath: refPath));
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
        data: (data) => VideoInfoContent(data: data),
      ),
    );
  }
}
