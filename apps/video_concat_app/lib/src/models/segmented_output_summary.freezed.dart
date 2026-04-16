// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segmented_output_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SegmentedOutputSummary {

 String get directoryPath; String get fileNamePattern;
/// Create a copy of SegmentedOutputSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SegmentedOutputSummaryCopyWith<SegmentedOutputSummary> get copyWith => _$SegmentedOutputSummaryCopyWithImpl<SegmentedOutputSummary>(this as SegmentedOutputSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SegmentedOutputSummary&&(identical(other.directoryPath, directoryPath) || other.directoryPath == directoryPath)&&(identical(other.fileNamePattern, fileNamePattern) || other.fileNamePattern == fileNamePattern));
}


@override
int get hashCode => Object.hash(runtimeType,directoryPath,fileNamePattern);

@override
String toString() {
  return 'SegmentedOutputSummary(directoryPath: $directoryPath, fileNamePattern: $fileNamePattern)';
}


}

/// @nodoc
abstract mixin class $SegmentedOutputSummaryCopyWith<$Res>  {
  factory $SegmentedOutputSummaryCopyWith(SegmentedOutputSummary value, $Res Function(SegmentedOutputSummary) _then) = _$SegmentedOutputSummaryCopyWithImpl;
@useResult
$Res call({
 String directoryPath, String fileNamePattern
});




}
/// @nodoc
class _$SegmentedOutputSummaryCopyWithImpl<$Res>
    implements $SegmentedOutputSummaryCopyWith<$Res> {
  _$SegmentedOutputSummaryCopyWithImpl(this._self, this._then);

  final SegmentedOutputSummary _self;
  final $Res Function(SegmentedOutputSummary) _then;

/// Create a copy of SegmentedOutputSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? directoryPath = null,Object? fileNamePattern = null,}) {
  return _then(_self.copyWith(
directoryPath: null == directoryPath ? _self.directoryPath : directoryPath // ignore: cast_nullable_to_non_nullable
as String,fileNamePattern: null == fileNamePattern ? _self.fileNamePattern : fileNamePattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SegmentedOutputSummary].
extension SegmentedOutputSummaryPatterns on SegmentedOutputSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SegmentedOutputSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SegmentedOutputSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SegmentedOutputSummary value)  $default,){
final _that = this;
switch (_that) {
case _SegmentedOutputSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SegmentedOutputSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SegmentedOutputSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String directoryPath,  String fileNamePattern)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SegmentedOutputSummary() when $default != null:
return $default(_that.directoryPath,_that.fileNamePattern);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String directoryPath,  String fileNamePattern)  $default,) {final _that = this;
switch (_that) {
case _SegmentedOutputSummary():
return $default(_that.directoryPath,_that.fileNamePattern);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String directoryPath,  String fileNamePattern)?  $default,) {final _that = this;
switch (_that) {
case _SegmentedOutputSummary() when $default != null:
return $default(_that.directoryPath,_that.fileNamePattern);case _:
  return null;

}
}

}

/// @nodoc


class _SegmentedOutputSummary implements SegmentedOutputSummary {
  const _SegmentedOutputSummary({required this.directoryPath, required this.fileNamePattern});
  

@override final  String directoryPath;
@override final  String fileNamePattern;

/// Create a copy of SegmentedOutputSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SegmentedOutputSummaryCopyWith<_SegmentedOutputSummary> get copyWith => __$SegmentedOutputSummaryCopyWithImpl<_SegmentedOutputSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SegmentedOutputSummary&&(identical(other.directoryPath, directoryPath) || other.directoryPath == directoryPath)&&(identical(other.fileNamePattern, fileNamePattern) || other.fileNamePattern == fileNamePattern));
}


@override
int get hashCode => Object.hash(runtimeType,directoryPath,fileNamePattern);

@override
String toString() {
  return 'SegmentedOutputSummary(directoryPath: $directoryPath, fileNamePattern: $fileNamePattern)';
}


}

/// @nodoc
abstract mixin class _$SegmentedOutputSummaryCopyWith<$Res> implements $SegmentedOutputSummaryCopyWith<$Res> {
  factory _$SegmentedOutputSummaryCopyWith(_SegmentedOutputSummary value, $Res Function(_SegmentedOutputSummary) _then) = __$SegmentedOutputSummaryCopyWithImpl;
@override @useResult
$Res call({
 String directoryPath, String fileNamePattern
});




}
/// @nodoc
class __$SegmentedOutputSummaryCopyWithImpl<$Res>
    implements _$SegmentedOutputSummaryCopyWith<$Res> {
  __$SegmentedOutputSummaryCopyWithImpl(this._self, this._then);

  final _SegmentedOutputSummary _self;
  final $Res Function(_SegmentedOutputSummary) _then;

/// Create a copy of SegmentedOutputSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? directoryPath = null,Object? fileNamePattern = null,}) {
  return _then(_SegmentedOutputSummary(
directoryPath: null == directoryPath ? _self.directoryPath : directoryPath // ignore: cast_nullable_to_non_nullable
as String,fileNamePattern: null == fileNamePattern ? _self.fileNamePattern : fileNamePattern // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
