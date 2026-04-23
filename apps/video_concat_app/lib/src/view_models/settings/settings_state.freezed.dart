// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 AppSettings get settings; bool get isFFmpegValid; bool get isFFprobeValid; String? get ffmpegVersion; String? get ffprobeVersion; bool get isValidating; String? get errorMessage;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.isFFmpegValid, isFFmpegValid) || other.isFFmpegValid == isFFmpegValid)&&(identical(other.isFFprobeValid, isFFprobeValid) || other.isFFprobeValid == isFFprobeValid)&&(identical(other.ffmpegVersion, ffmpegVersion) || other.ffmpegVersion == ffmpegVersion)&&(identical(other.ffprobeVersion, ffprobeVersion) || other.ffprobeVersion == ffprobeVersion)&&(identical(other.isValidating, isValidating) || other.isValidating == isValidating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,settings,isFFmpegValid,isFFprobeValid,ffmpegVersion,ffprobeVersion,isValidating,errorMessage);

@override
String toString() {
  return 'SettingsState(settings: $settings, isFFmpegValid: $isFFmpegValid, isFFprobeValid: $isFFprobeValid, ffmpegVersion: $ffmpegVersion, ffprobeVersion: $ffprobeVersion, isValidating: $isValidating, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 AppSettings settings, bool isFFmpegValid, bool isFFprobeValid, String? ffmpegVersion, String? ffprobeVersion, bool isValidating, String? errorMessage
});


$AppSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? settings = null,Object? isFFmpegValid = null,Object? isFFprobeValid = null,Object? ffmpegVersion = freezed,Object? ffprobeVersion = freezed,Object? isValidating = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings,isFFmpegValid: null == isFFmpegValid ? _self.isFFmpegValid : isFFmpegValid // ignore: cast_nullable_to_non_nullable
as bool,isFFprobeValid: null == isFFprobeValid ? _self.isFFprobeValid : isFFprobeValid // ignore: cast_nullable_to_non_nullable
as bool,ffmpegVersion: freezed == ffmpegVersion ? _self.ffmpegVersion : ffmpegVersion // ignore: cast_nullable_to_non_nullable
as String?,ffprobeVersion: freezed == ffprobeVersion ? _self.ffprobeVersion : ffprobeVersion // ignore: cast_nullable_to_non_nullable
as String?,isValidating: null == isValidating ? _self.isValidating : isValidating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res> get settings {
  
  return $AppSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppSettings settings,  bool isFFmpegValid,  bool isFFprobeValid,  String? ffmpegVersion,  String? ffprobeVersion,  bool isValidating,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.settings,_that.isFFmpegValid,_that.isFFprobeValid,_that.ffmpegVersion,_that.ffprobeVersion,_that.isValidating,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppSettings settings,  bool isFFmpegValid,  bool isFFprobeValid,  String? ffmpegVersion,  String? ffprobeVersion,  bool isValidating,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SettingsState():
return $default(_that.settings,_that.isFFmpegValid,_that.isFFprobeValid,_that.ffmpegVersion,_that.ffprobeVersion,_that.isValidating,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppSettings settings,  bool isFFmpegValid,  bool isFFprobeValid,  String? ffmpegVersion,  String? ffprobeVersion,  bool isValidating,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SettingsState() when $default != null:
return $default(_that.settings,_that.isFFmpegValid,_that.isFFprobeValid,_that.ffmpegVersion,_that.ffprobeVersion,_that.isValidating,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsState implements SettingsState {
  const _SettingsState({this.settings = const AppSettings(ffmpegPath: 'ffmpeg', ffprobePath: 'ffprobe'), this.isFFmpegValid = false, this.isFFprobeValid = false, this.ffmpegVersion, this.ffprobeVersion, this.isValidating = true, this.errorMessage});
  

@override@JsonKey() final  AppSettings settings;
@override@JsonKey() final  bool isFFmpegValid;
@override@JsonKey() final  bool isFFprobeValid;
@override final  String? ffmpegVersion;
@override final  String? ffprobeVersion;
@override@JsonKey() final  bool isValidating;
@override final  String? errorMessage;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateCopyWith<_SettingsState> get copyWith => __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsState&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.isFFmpegValid, isFFmpegValid) || other.isFFmpegValid == isFFmpegValid)&&(identical(other.isFFprobeValid, isFFprobeValid) || other.isFFprobeValid == isFFprobeValid)&&(identical(other.ffmpegVersion, ffmpegVersion) || other.ffmpegVersion == ffmpegVersion)&&(identical(other.ffprobeVersion, ffprobeVersion) || other.ffprobeVersion == ffprobeVersion)&&(identical(other.isValidating, isValidating) || other.isValidating == isValidating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,settings,isFFmpegValid,isFFprobeValid,ffmpegVersion,ffprobeVersion,isValidating,errorMessage);

@override
String toString() {
  return 'SettingsState(settings: $settings, isFFmpegValid: $isFFmpegValid, isFFprobeValid: $isFFprobeValid, ffmpegVersion: $ffmpegVersion, ffprobeVersion: $ffprobeVersion, isValidating: $isValidating, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(_SettingsState value, $Res Function(_SettingsState) _then) = __$SettingsStateCopyWithImpl;
@override @useResult
$Res call({
 AppSettings settings, bool isFFmpegValid, bool isFFprobeValid, String? ffmpegVersion, String? ffprobeVersion, bool isValidating, String? errorMessage
});


@override $AppSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? settings = null,Object? isFFmpegValid = null,Object? isFFprobeValid = null,Object? ffmpegVersion = freezed,Object? ffprobeVersion = freezed,Object? isValidating = null,Object? errorMessage = freezed,}) {
  return _then(_SettingsState(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings,isFFmpegValid: null == isFFmpegValid ? _self.isFFmpegValid : isFFmpegValid // ignore: cast_nullable_to_non_nullable
as bool,isFFprobeValid: null == isFFprobeValid ? _self.isFFprobeValid : isFFprobeValid // ignore: cast_nullable_to_non_nullable
as bool,ffmpegVersion: freezed == ffmpegVersion ? _self.ffmpegVersion : ffmpegVersion // ignore: cast_nullable_to_non_nullable
as String?,ffprobeVersion: freezed == ffprobeVersion ? _self.ffprobeVersion : ffprobeVersion // ignore: cast_nullable_to_non_nullable
as String?,isValidating: null == isValidating ? _self.isValidating : isValidating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res> get settings {
  
  return $AppSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
