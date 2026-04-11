import 'dart:typed_data';

import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trim_state.freezed.dart';

/// 裁剪页面状态
@freezed
abstract class TrimState with _$TrimState {
  const factory TrimState({
    /// 视频 ID
    required String videoId,

    /// 视频文件路径
    required String filePath,

    /// 视频文件名
    required String fileName,

    /// 视频总时长（微秒）
    required int durationUs,

    /// 当前滑块位置（微秒，已吸附到关键帧）
    @Default(0) int currentPositionUs,

    /// 待配对的 inpoint（微秒），null 表示无待配对
    int? pendingInpointUs,

    /// 滑块释放后正在吸附关键帧
    @Default(false) bool isSnapping,

    /// 已选片段列表
    @Default([]) List<TrimSegment> segments,

    /// 预览图字节数据
    Uint8List? previewImage,

    /// 是否正在加载预览
    @Default(false) bool isLoadingPreview,

    /// 是否正在加载（初始化中）
    @Default(true) bool isLoading,

    /// 错误消息
    String? errorMessage,
  }) = _TrimState;
}
