// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 视频信息 ViewModel

@ProviderFor(videoInfo)
final videoInfoProvider = VideoInfoFamily._();

/// 视频信息 ViewModel

final class VideoInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProbeResult>,
          ProbeResult,
          FutureOr<ProbeResult>
        >
    with $FutureModifier<ProbeResult>, $FutureProvider<ProbeResult> {
  /// 视频信息 ViewModel
  VideoInfoProvider._({
    required VideoInfoFamily super.from,
    required String super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProbeResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProbeResult> create(Ref ref) {
    final argument = this.argument as String;
    return videoInfo(ref, argument);
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

String _$videoInfoHash() => r'cb345e7222fd0ae50e5193e4fedcb592306ddfa0';

/// 视频信息 ViewModel

final class VideoInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProbeResult>, String> {
  VideoInfoFamily._()
    : super(
        retry: null,
        name: r'videoInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 视频信息 ViewModel

  VideoInfoProvider call(String filePath) =>
      VideoInfoProvider._(argument: filePath, from: this);

  @override
  String toString() => r'videoInfoProvider';
}
