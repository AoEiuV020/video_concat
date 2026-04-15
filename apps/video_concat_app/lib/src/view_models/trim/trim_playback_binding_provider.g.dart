// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trim_playback_binding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 在裁剪页生命周期内稳定持有播放器渲染资源。

@ProviderFor(trimPlaybackBinding)
final trimPlaybackBindingProvider = TrimPlaybackBindingFamily._();

/// 在裁剪页生命周期内稳定持有播放器渲染资源。

final class TrimPlaybackBindingProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// 在裁剪页生命周期内稳定持有播放器渲染资源。
  TrimPlaybackBindingProvider._({
    required TrimPlaybackBindingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trimPlaybackBindingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trimPlaybackBindingHash();

  @override
  String toString() {
    return r'trimPlaybackBindingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    final argument = this.argument as String;
    return trimPlaybackBinding(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrimPlaybackBindingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trimPlaybackBindingHash() =>
    r'ef52fcf4fa94c7dcee42ad817f47c33672676a1d';

/// 在裁剪页生命周期内稳定持有播放器渲染资源。

final class TrimPlaybackBindingFamily extends $Family
    with $FunctionalFamilyOverride<void, String> {
  TrimPlaybackBindingFamily._()
    : super(
        retry: null,
        name: r'trimPlaybackBindingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 在裁剪页生命周期内稳定持有播放器渲染资源。

  TrimPlaybackBindingProvider call(String videoId) =>
      TrimPlaybackBindingProvider._(argument: videoId, from: this);

  @override
  String toString() => r'trimPlaybackBindingProvider';
}
