// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 视频信息 ViewModel
///
/// [refPath] 不为空时，与参考视频对比并返回差异。

@ProviderFor(videoInfo)
final videoInfoProvider = VideoInfoFamily._();

/// 视频信息 ViewModel
///
/// [refPath] 不为空时，与参考视频对比并返回差异。

final class VideoInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<VideoInfoData>,
          VideoInfoData,
          FutureOr<VideoInfoData>
        >
    with $FutureModifier<VideoInfoData>, $FutureProvider<VideoInfoData> {
  /// 视频信息 ViewModel
  ///
  /// [refPath] 不为空时，与参考视频对比并返回差异。
  VideoInfoProvider._({
    required VideoInfoFamily super.from,
    required (String, {String? refPath}) super.argument,
  }) : super(
         retry: null,
         name: r'videoInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoInfoHash();

  @override
  String toString() {
    return r'videoInfoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<VideoInfoData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VideoInfoData> create(Ref ref) {
    final argument = this.argument as (String, {String? refPath});
    return videoInfo(ref, argument.$1, refPath: argument.refPath);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoInfoHash() => r'bc55dadcbb2a5528d607f4a0ed0e0c40f482ee3a';

/// 视频信息 ViewModel
///
/// [refPath] 不为空时，与参考视频对比并返回差异。

final class VideoInfoFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<VideoInfoData>,
          (String, {String? refPath})
        > {
  VideoInfoFamily._()
    : super(
        retry: null,
        name: r'videoInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 视频信息 ViewModel
  ///
  /// [refPath] 不为空时，与参考视频对比并返回差异。

  VideoInfoProvider call(String filePath, {String? refPath}) =>
      VideoInfoProvider._(argument: (filePath, refPath: refPath), from: this);

  @override
  String toString() => r'videoInfoProvider';
}
