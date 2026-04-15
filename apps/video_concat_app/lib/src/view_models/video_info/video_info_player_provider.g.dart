// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 视频信息页播放器（per-filePath，auto-dispose）。

@ProviderFor(videoInfoPlayer)
final videoInfoPlayerProvider = VideoInfoPlayerFamily._();

/// 视频信息页播放器（per-filePath，auto-dispose）。

final class VideoInfoPlayerProvider
    extends $FunctionalProvider<Raw<Player>, Raw<Player>, Raw<Player>>
    with $Provider<Raw<Player>> {
  /// 视频信息页播放器（per-filePath，auto-dispose）。
  VideoInfoPlayerProvider._({
    required VideoInfoPlayerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'videoInfoPlayerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoInfoPlayerHash();

  @override
  String toString() {
    return r'videoInfoPlayerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Raw<Player>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Raw<Player> create(Ref ref) {
    final argument = this.argument as String;
    return videoInfoPlayer(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Player> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Player>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoInfoPlayerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoInfoPlayerHash() => r'48e28a76ef39b6dcb0ff5c2981c19be7425c3248';

/// 视频信息页播放器（per-filePath，auto-dispose）。

final class VideoInfoPlayerFamily extends $Family
    with $FunctionalFamilyOverride<Raw<Player>, String> {
  VideoInfoPlayerFamily._()
    : super(
        retry: null,
        name: r'videoInfoPlayerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 视频信息页播放器（per-filePath，auto-dispose）。

  VideoInfoPlayerProvider call(String filePath) =>
      VideoInfoPlayerProvider._(argument: filePath, from: this);

  @override
  String toString() => r'videoInfoPlayerProvider';
}

/// 视频信息页视频渲染控制器。

@ProviderFor(videoInfoVideoController)
final videoInfoVideoControllerProvider = VideoInfoVideoControllerFamily._();

/// 视频信息页视频渲染控制器。

final class VideoInfoVideoControllerProvider
    extends
        $FunctionalProvider<
          Raw<VideoController>,
          Raw<VideoController>,
          Raw<VideoController>
        >
    with $Provider<Raw<VideoController>> {
  /// 视频信息页视频渲染控制器。
  VideoInfoVideoControllerProvider._({
    required VideoInfoVideoControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'videoInfoVideoControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoInfoVideoControllerHash();

  @override
  String toString() {
    return r'videoInfoVideoControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Raw<VideoController>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<VideoController> create(Ref ref) {
    final argument = this.argument as String;
    return videoInfoVideoController(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<VideoController> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<VideoController>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoInfoVideoControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoInfoVideoControllerHash() =>
    r'a00aa87e721c9272f7711b5317b55fa392e6501e';

/// 视频信息页视频渲染控制器。

final class VideoInfoVideoControllerFamily extends $Family
    with $FunctionalFamilyOverride<Raw<VideoController>, String> {
  VideoInfoVideoControllerFamily._()
    : super(
        retry: null,
        name: r'videoInfoVideoControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 视频信息页视频渲染控制器。

  VideoInfoVideoControllerProvider call(String filePath) =>
      VideoInfoVideoControllerProvider._(argument: filePath, from: this);

  @override
  String toString() => r'videoInfoVideoControllerProvider';
}
