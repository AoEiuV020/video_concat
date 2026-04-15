// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trim_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 裁剪页面的视频播放器（per-videoId，auto-dispose）

@ProviderFor(trimPlayer)
final trimPlayerProvider = TrimPlayerFamily._();

/// 裁剪页面的视频播放器（per-videoId，auto-dispose）

final class TrimPlayerProvider
    extends $FunctionalProvider<Raw<Player>, Raw<Player>, Raw<Player>>
    with $Provider<Raw<Player>> {
  /// 裁剪页面的视频播放器（per-videoId，auto-dispose）
  TrimPlayerProvider._({
    required TrimPlayerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trimPlayerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trimPlayerHash();

  @override
  String toString() {
    return r'trimPlayerProvider'
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
    return trimPlayer(ref, argument);
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
    return other is TrimPlayerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trimPlayerHash() => r'afbe60ebb36eaf03c801b4eb333d79bb016c5572';

/// 裁剪页面的视频播放器（per-videoId，auto-dispose）

final class TrimPlayerFamily extends $Family
    with $FunctionalFamilyOverride<Raw<Player>, String> {
  TrimPlayerFamily._()
    : super(
        retry: null,
        name: r'trimPlayerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 裁剪页面的视频播放器（per-videoId，auto-dispose）

  TrimPlayerProvider call(String videoId) =>
      TrimPlayerProvider._(argument: videoId, from: this);

  @override
  String toString() => r'trimPlayerProvider';
}

/// 裁剪页面的视频渲染控制器

@ProviderFor(trimVideoController)
final trimVideoControllerProvider = TrimVideoControllerFamily._();

/// 裁剪页面的视频渲染控制器

final class TrimVideoControllerProvider
    extends
        $FunctionalProvider<
          Raw<VideoController>,
          Raw<VideoController>,
          Raw<VideoController>
        >
    with $Provider<Raw<VideoController>> {
  /// 裁剪页面的视频渲染控制器
  TrimVideoControllerProvider._({
    required TrimVideoControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trimVideoControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trimVideoControllerHash();

  @override
  String toString() {
    return r'trimVideoControllerProvider'
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
    return trimVideoController(ref, argument);
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
    return other is TrimVideoControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trimVideoControllerHash() =>
    r'2f0e29404ce09e3652029fd0ec001f11cd0ec95d';

/// 裁剪页面的视频渲染控制器

final class TrimVideoControllerFamily extends $Family
    with $FunctionalFamilyOverride<Raw<VideoController>, String> {
  TrimVideoControllerFamily._()
    : super(
        retry: null,
        name: r'trimVideoControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 裁剪页面的视频渲染控制器

  TrimVideoControllerProvider call(String videoId) =>
      TrimVideoControllerProvider._(argument: videoId, from: this);

  @override
  String toString() => r'trimVideoControllerProvider';
}
