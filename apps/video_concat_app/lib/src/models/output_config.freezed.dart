// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'output_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutputConfig {

 String get baseName; String get extension;
/// Create a copy of OutputConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutputConfigCopyWith<OutputConfig> get copyWith => _$OutputConfigCopyWithImpl<OutputConfig>(this as OutputConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputConfig&&(identical(other.baseName, baseName) || other.baseName == baseName)&&(identical(other.extension, extension) || other.extension == extension));
}


@override
int get hashCode => Object.hash(runtimeType,baseName,extension);

@override
String toString() {
  return 'OutputConfig(baseName: $baseName, extension: $extension)';
}


}

/// @nodoc
abstract mixin class $OutputConfigCopyWith<$Res>  {
  factory $OutputConfigCopyWith(OutputConfig value, $Res Function(OutputConfig) _then) = _$OutputConfigCopyWithImpl;
@useResult
$Res call({
 String baseName, String extension
});




}
/// @nodoc
class _$OutputConfigCopyWithImpl<$Res>
    implements $OutputConfigCopyWith<$Res> {
  _$OutputConfigCopyWithImpl(this._self, this._then);

  final OutputConfig _self;
  final $Res Function(OutputConfig) _then;

/// Create a copy of OutputConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseName = null,Object? extension = null,}) {
  return _then(_self.copyWith(
baseName: null == baseName ? _self.baseName : baseName // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutputConfig].
extension OutputConfigPatterns on OutputConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutputConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutputConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutputConfig value)  $default,){
final _that = this;
switch (_that) {
case _OutputConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutputConfig value)?  $default,){
final _that = this;
switch (_that) {
case _OutputConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String baseName,  String extension)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutputConfig() when $default != null:
return $default(_that.baseName,_that.extension);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String baseName,  String extension)  $default,) {final _that = this;
switch (_that) {
case _OutputConfig():
return $default(_that.baseName,_that.extension);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String baseName,  String extension)?  $default,) {final _that = this;
switch (_that) {
case _OutputConfig() when $default != null:
return $default(_that.baseName,_that.extension);case _:
  return null;

}
}

}

/// @nodoc


class _OutputConfig extends OutputConfig {
  const _OutputConfig({required this.baseName, required this.extension}): super._();
  

@override final  String baseName;
@override final  String extension;

/// Create a copy of OutputConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutputConfigCopyWith<_OutputConfig> get copyWith => __$OutputConfigCopyWithImpl<_OutputConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutputConfig&&(identical(other.baseName, baseName) || other.baseName == baseName)&&(identical(other.extension, extension) || other.extension == extension));
}


@override
int get hashCode => Object.hash(runtimeType,baseName,extension);

@override
String toString() {
  return 'OutputConfig(baseName: $baseName, extension: $extension)';
}


}

/// @nodoc
abstract mixin class _$OutputConfigCopyWith<$Res> implements $OutputConfigCopyWith<$Res> {
  factory _$OutputConfigCopyWith(_OutputConfig value, $Res Function(_OutputConfig) _then) = __$OutputConfigCopyWithImpl;
@override @useResult
$Res call({
 String baseName, String extension
});




}
/// @nodoc
class __$OutputConfigCopyWithImpl<$Res>
    implements _$OutputConfigCopyWith<$Res> {
  __$OutputConfigCopyWithImpl(this._self, this._then);

  final _OutputConfig _self;
  final $Res Function(_OutputConfig) _then;

/// Create a copy of OutputConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseName = null,Object? extension = null,}) {
  return _then(_OutputConfig(
baseName: null == baseName ? _self.baseName : baseName // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
