// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 List<VideoItem> get videoItems; OutputConfig get outputConfig; GenerateResult? get generateResult; bool get isGenerating;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&const DeepCollectionEquality().equals(other.videoItems, videoItems)&&(identical(other.outputConfig, outputConfig) || other.outputConfig == outputConfig)&&(identical(other.generateResult, generateResult) || other.generateResult == generateResult)&&(identical(other.isGenerating, isGenerating) || other.isGenerating == isGenerating));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(videoItems),outputConfig,generateResult,isGenerating);

@override
String toString() {
  return 'HomeState(videoItems: $videoItems, outputConfig: $outputConfig, generateResult: $generateResult, isGenerating: $isGenerating)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 List<VideoItem> videoItems, OutputConfig outputConfig, GenerateResult? generateResult, bool isGenerating
});


$OutputConfigCopyWith<$Res> get outputConfig;$GenerateResultCopyWith<$Res>? get generateResult;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoItems = null,Object? outputConfig = null,Object? generateResult = freezed,Object? isGenerating = null,}) {
  return _then(_self.copyWith(
videoItems: null == videoItems ? _self.videoItems : videoItems // ignore: cast_nullable_to_non_nullable
as List<VideoItem>,outputConfig: null == outputConfig ? _self.outputConfig : outputConfig // ignore: cast_nullable_to_non_nullable
as OutputConfig,generateResult: freezed == generateResult ? _self.generateResult : generateResult // ignore: cast_nullable_to_non_nullable
as GenerateResult?,isGenerating: null == isGenerating ? _self.isGenerating : isGenerating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputConfigCopyWith<$Res> get outputConfig {
  
  return $OutputConfigCopyWith<$Res>(_self.outputConfig, (value) {
    return _then(_self.copyWith(outputConfig: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerateResultCopyWith<$Res>? get generateResult {
    if (_self.generateResult == null) {
    return null;
  }

  return $GenerateResultCopyWith<$Res>(_self.generateResult!, (value) {
    return _then(_self.copyWith(generateResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VideoItem> videoItems,  OutputConfig outputConfig,  GenerateResult? generateResult,  bool isGenerating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.videoItems,_that.outputConfig,_that.generateResult,_that.isGenerating);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VideoItem> videoItems,  OutputConfig outputConfig,  GenerateResult? generateResult,  bool isGenerating)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.videoItems,_that.outputConfig,_that.generateResult,_that.isGenerating);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VideoItem> videoItems,  OutputConfig outputConfig,  GenerateResult? generateResult,  bool isGenerating)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.videoItems,_that.outputConfig,_that.generateResult,_that.isGenerating);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({final  List<VideoItem> videoItems = const [], this.outputConfig = const OutputConfig(baseName: '', extension: 'mp4'), this.generateResult, this.isGenerating = false}): _videoItems = videoItems;
  

 final  List<VideoItem> _videoItems;
@override@JsonKey() List<VideoItem> get videoItems {
  if (_videoItems is EqualUnmodifiableListView) return _videoItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videoItems);
}

@override@JsonKey() final  OutputConfig outputConfig;
@override final  GenerateResult? generateResult;
@override@JsonKey() final  bool isGenerating;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&const DeepCollectionEquality().equals(other._videoItems, _videoItems)&&(identical(other.outputConfig, outputConfig) || other.outputConfig == outputConfig)&&(identical(other.generateResult, generateResult) || other.generateResult == generateResult)&&(identical(other.isGenerating, isGenerating) || other.isGenerating == isGenerating));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videoItems),outputConfig,generateResult,isGenerating);

@override
String toString() {
  return 'HomeState(videoItems: $videoItems, outputConfig: $outputConfig, generateResult: $generateResult, isGenerating: $isGenerating)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 List<VideoItem> videoItems, OutputConfig outputConfig, GenerateResult? generateResult, bool isGenerating
});


@override $OutputConfigCopyWith<$Res> get outputConfig;@override $GenerateResultCopyWith<$Res>? get generateResult;

}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoItems = null,Object? outputConfig = null,Object? generateResult = freezed,Object? isGenerating = null,}) {
  return _then(_HomeState(
videoItems: null == videoItems ? _self._videoItems : videoItems // ignore: cast_nullable_to_non_nullable
as List<VideoItem>,outputConfig: null == outputConfig ? _self.outputConfig : outputConfig // ignore: cast_nullable_to_non_nullable
as OutputConfig,generateResult: freezed == generateResult ? _self.generateResult : generateResult // ignore: cast_nullable_to_non_nullable
as GenerateResult?,isGenerating: null == isGenerating ? _self.isGenerating : isGenerating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputConfigCopyWith<$Res> get outputConfig {
  
  return $OutputConfigCopyWith<$Res>(_self.outputConfig, (value) {
    return _then(_self.copyWith(outputConfig: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerateResultCopyWith<$Res>? get generateResult {
    if (_self.generateResult == null) {
    return null;
  }

  return $GenerateResultCopyWith<$Res>(_self.generateResult!, (value) {
    return _then(_self.copyWith(generateResult: value));
  });
}
}

// dart format on
