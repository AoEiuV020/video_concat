// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 持久化仓库

@ProviderFor(preferencesRepository)
final preferencesRepositoryProvider = PreferencesRepositoryProvider._();

/// 持久化仓库

final class PreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          PreferencesRepository,
          PreferencesRepository,
          PreferencesRepository
        >
    with $Provider<PreferencesRepository> {
  /// 持久化仓库
  PreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreferencesRepository create(Ref ref) {
    return preferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesRepository>(value),
    );
  }
}

String _$preferencesRepositoryHash() =>
    r'8216035d34b688e010186d1902695f829e123afe';

/// FFmpeg 服务

@ProviderFor(ffmpegService)
final ffmpegServiceProvider = FfmpegServiceProvider._();

/// FFmpeg 服务

final class FfmpegServiceProvider
    extends $FunctionalProvider<FFmpegService, FFmpegService, FFmpegService>
    with $Provider<FFmpegService> {
  /// FFmpeg 服务
  FfmpegServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ffmpegServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ffmpegServiceHash();

  @$internal
  @override
  $ProviderElement<FFmpegService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FFmpegService create(Ref ref) {
    return ffmpegService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FFmpegService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FFmpegService>(value),
    );
  }
}

String _$ffmpegServiceHash() => r'9ebd72b866e2cb147204a6fdb2dca53acae5dab2';

/// FFprobe 服务

@ProviderFor(ffprobeService)
final ffprobeServiceProvider = FfprobeServiceProvider._();

/// FFprobe 服务

final class FfprobeServiceProvider
    extends $FunctionalProvider<FFprobeService, FFprobeService, FFprobeService>
    with $Provider<FFprobeService> {
  /// FFprobe 服务
  FfprobeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ffprobeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ffprobeServiceHash();

  @$internal
  @override
  $ProviderElement<FFprobeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FFprobeService create(Ref ref) {
    return ffprobeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FFprobeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FFprobeService>(value),
    );
  }
}

String _$ffprobeServiceHash() => r'dec624f3dc1ffaac89ba62447fbaa98696e61f09';

/// 视频合并服务

@ProviderFor(videoConcatService)
final videoConcatServiceProvider = VideoConcatServiceProvider._();

/// 视频合并服务

final class VideoConcatServiceProvider
    extends
        $FunctionalProvider<
          VideoConcatService,
          VideoConcatService,
          VideoConcatService
        >
    with $Provider<VideoConcatService> {
  /// 视频合并服务
  VideoConcatServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoConcatServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoConcatServiceHash();

  @$internal
  @override
  $ProviderElement<VideoConcatService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VideoConcatService create(Ref ref) {
    return videoConcatService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoConcatService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoConcatService>(value),
    );
  }
}

String _$videoConcatServiceHash() =>
    r'd1c1e215115411ec60eedfb072e17d289fbda846';
