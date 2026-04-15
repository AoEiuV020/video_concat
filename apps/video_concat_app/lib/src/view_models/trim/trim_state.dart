import 'package:ffmpeg_kit/ffmpeg_kit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trim_state.freezed.dart';

/// 裁剪页面状态
@freezed
abstract class TrimState with _$TrimState {
  const TrimState._();

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

    /// 拖动中的滑块位置（微秒），null 表示未拖动
    int? draggingPositionUs,

    /// 已选片段列表
    @Default([]) List<TrimSegment> segments,

    /// 是否正在播放
    @Default(false) bool isPlaying,

    /// 关键帧已确定，但播放器画面尚未跳到目标位置
    @Default(false) bool isPreviewPending,

    /// 当前等待播放器追上的目标位置
    int? pendingPreviewTargetUs,

    /// 是否正在加载（初始化中）
    @Default(true) bool isLoading,

    /// 错误消息
    String? errorMessage,
  }) = _TrimState;

  /// 当前时间不可用（未吸附到关键帧），拖动中和吸附中都属此状态。
  ///
  /// 此状态下 prev/next 和 In/Out 按钮禁用。
  bool get isTimeUnresolved =>
      isPlaying || isSnapping || draggingPositionUs != null;
}
