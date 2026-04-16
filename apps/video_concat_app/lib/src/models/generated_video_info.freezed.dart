// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_video_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratedVideoInfo {

 String get outputPath; String get fileName;
/// Create a copy of GeneratedVideoInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedVideoInfoCopyWith<GeneratedVideoInfo> get copyWith => _$GeneratedVideoInfoCopyWithImpl<GeneratedVideoInfo>(this as GeneratedVideoInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedVideoInfo&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,outputPath,fileName);

@override
String toString() {
  return 'GeneratedVideoInfo(outputPath: $outputPath, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $GeneratedVideoInfoCopyWith<$Res>  {
  factory $GeneratedVideoInfoCopyWith(GeneratedVideoInfo value, $Res Function(GeneratedVideoInfo) _then) = _$GeneratedVideoInfoCopyWithImpl;
@useResult
$Res call({
 String outputPath, String fileName
});




}
/// @nodoc
class _$GeneratedVideoInfoCopyWithImpl<$Res>
    implements $GeneratedVideoInfoCopyWith<$Res> {
  _$GeneratedVideoInfoCopyWithImpl(this._self, this._then);

  final GeneratedVideoInfo _self;
  final $Res Function(GeneratedVideoInfo) _then;

/// Create a copy of GeneratedVideoInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outputPath = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedVideoInfo].
extension GeneratedVideoInfoPatterns on GeneratedVideoInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedVideoInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedVideoInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedVideoInfo value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedVideoInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedVideoInfo value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedVideoInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outputPath,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedVideoInfo() when $default != null:
return $default(_that.outputPath,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outputPath,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _GeneratedVideoInfo():
return $default(_that.outputPath,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outputPath,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedVideoInfo() when $default != null:
return $default(_that.outputPath,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedVideoInfo implements GeneratedVideoInfo {
  const _GeneratedVideoInfo({required this.outputPath, required this.fileName});
  

@override final  String outputPath;
@override final  String fileName;

/// Create a copy of GeneratedVideoInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedVideoInfoCopyWith<_GeneratedVideoInfo> get copyWith => __$GeneratedVideoInfoCopyWithImpl<_GeneratedVideoInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedVideoInfo&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,outputPath,fileName);

@override
String toString() {
  return 'GeneratedVideoInfo(outputPath: $outputPath, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$GeneratedVideoInfoCopyWith<$Res> implements $GeneratedVideoInfoCopyWith<$Res> {
  factory _$GeneratedVideoInfoCopyWith(_GeneratedVideoInfo value, $Res Function(_GeneratedVideoInfo) _then) = __$GeneratedVideoInfoCopyWithImpl;
@override @useResult
$Res call({
 String outputPath, String fileName
});




}
/// @nodoc
class __$GeneratedVideoInfoCopyWithImpl<$Res>
    implements _$GeneratedVideoInfoCopyWith<$Res> {
  __$GeneratedVideoInfoCopyWithImpl(this._self, this._then);

  final _GeneratedVideoInfo _self;
  final $Res Function(_GeneratedVideoInfo) _then;

/// Create a copy of GeneratedVideoInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outputPath = null,Object? fileName = null,}) {
  return _then(_GeneratedVideoInfo(
outputPath: null == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
