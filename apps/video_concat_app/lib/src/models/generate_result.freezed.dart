// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenerateResult {

 GenerateState get state; String get output; String? get errorMessage;
/// Create a copy of GenerateResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateResultCopyWith<GenerateResult> get copyWith => _$GenerateResultCopyWithImpl<GenerateResult>(this as GenerateResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateResult&&(identical(other.state, state) || other.state == state)&&(identical(other.output, output) || other.output == output)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,state,output,errorMessage);

@override
String toString() {
  return 'GenerateResult(state: $state, output: $output, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $GenerateResultCopyWith<$Res>  {
  factory $GenerateResultCopyWith(GenerateResult value, $Res Function(GenerateResult) _then) = _$GenerateResultCopyWithImpl;
@useResult
$Res call({
 GenerateState state, String output, String? errorMessage
});




}
/// @nodoc
class _$GenerateResultCopyWithImpl<$Res>
    implements $GenerateResultCopyWith<$Res> {
  _$GenerateResultCopyWithImpl(this._self, this._then);

  final GenerateResult _self;
  final $Res Function(GenerateResult) _then;

/// Create a copy of GenerateResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? output = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as GenerateState,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerateResult].
extension GenerateResultPatterns on GenerateResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerateResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerateResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerateResult value)  $default,){
final _that = this;
switch (_that) {
case _GenerateResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerateResult value)?  $default,){
final _that = this;
switch (_that) {
case _GenerateResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GenerateState state,  String output,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateResult() when $default != null:
return $default(_that.state,_that.output,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GenerateState state,  String output,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _GenerateResult():
return $default(_that.state,_that.output,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GenerateState state,  String output,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _GenerateResult() when $default != null:
return $default(_that.state,_that.output,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _GenerateResult implements GenerateResult {
  const _GenerateResult({required this.state, required this.output, this.errorMessage});
  

@override final  GenerateState state;
@override final  String output;
@override final  String? errorMessage;

/// Create a copy of GenerateResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateResultCopyWith<_GenerateResult> get copyWith => __$GenerateResultCopyWithImpl<_GenerateResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateResult&&(identical(other.state, state) || other.state == state)&&(identical(other.output, output) || other.output == output)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,state,output,errorMessage);

@override
String toString() {
  return 'GenerateResult(state: $state, output: $output, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$GenerateResultCopyWith<$Res> implements $GenerateResultCopyWith<$Res> {
  factory _$GenerateResultCopyWith(_GenerateResult value, $Res Function(_GenerateResult) _then) = __$GenerateResultCopyWithImpl;
@override @useResult
$Res call({
 GenerateState state, String output, String? errorMessage
});




}
/// @nodoc
class __$GenerateResultCopyWithImpl<$Res>
    implements _$GenerateResultCopyWith<$Res> {
  __$GenerateResultCopyWithImpl(this._self, this._then);

  final _GenerateResult _self;
  final $Res Function(_GenerateResult) _then;

/// Create a copy of GenerateResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? output = null,Object? errorMessage = freezed,}) {
  return _then(_GenerateResult(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as GenerateState,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
