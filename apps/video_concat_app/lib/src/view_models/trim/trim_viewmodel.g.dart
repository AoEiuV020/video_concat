// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trim_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 裁剪页面 ViewModel

@ProviderFor(TrimViewModel)
final trimViewModelProvider = TrimViewModelFamily._();

/// 裁剪页面 ViewModel
final class TrimViewModelProvider
    extends $NotifierProvider<TrimViewModel, TrimState> {
  /// 裁剪页面 ViewModel
  TrimViewModelProvider._({
    required TrimViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'trimViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trimViewModelHash();

  @override
  String toString() {
    return r'trimViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TrimViewModel create() => TrimViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrimState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrimState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrimViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trimViewModelHash() => r'001da913365f2ac9fcbc8590ad4da5ec8b8131c0';

/// 裁剪页面 ViewModel

final class TrimViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TrimViewModel,
          TrimState,
          TrimState,
          TrimState,
          String
        > {
  TrimViewModelFamily._()
    : super(
        retry: null,
        name: r'trimViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 裁剪页面 ViewModel

  TrimViewModelProvider call(String videoId) =>
      TrimViewModelProvider._(argument: videoId, from: this);

  @override
  String toString() => r'trimViewModelProvider';
}

/// 裁剪页面 ViewModel

abstract class _$TrimViewModel extends $Notifier<TrimState> {
  late final _$args = ref.$arg as String;
  String get videoId => _$args;

  TrimState build(String videoId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TrimState, TrimState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrimState, TrimState>,
              TrimState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
