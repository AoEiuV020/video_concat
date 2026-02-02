// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoItem {

 String get id; String get filePath; String get fileName;
/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoItemCopyWith<VideoItem> get copyWith => _$VideoItemCopyWithImpl<VideoItem>(this as VideoItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,id,filePath,fileName);

@override
String toString() {
  return 'VideoItem(id: $id, filePath: $filePath, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $VideoItemCopyWith<$Res>  {
  factory $VideoItemCopyWith(VideoItem value, $Res Function(VideoItem) _then) = _$VideoItemCopyWithImpl;
@useResult
$Res call({
 String id, String filePath, String fileName
});




}
/// @nodoc
class _$VideoItemCopyWithImpl<$Res>
    implements $VideoItemCopyWith<$Res> {
  _$VideoItemCopyWithImpl(this._self, this._then);

  final VideoItem _self;
  final $Res Function(VideoItem) _then;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filePath = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoItem].
extension VideoItemPatterns on VideoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoItem value)  $default,){
final _that = this;
switch (_that) {
case _VideoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoItem value)?  $default,){
final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String filePath,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
return $default(_that.id,_that.filePath,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String filePath,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _VideoItem():
return $default(_that.id,_that.filePath,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String filePath,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _VideoItem() when $default != null:
return $default(_that.id,_that.filePath,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc


class _VideoItem implements VideoItem {
  const _VideoItem({required this.id, required this.filePath, required this.fileName});
  

@override final  String id;
@override final  String filePath;
@override final  String fileName;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoItemCopyWith<_VideoItem> get copyWith => __$VideoItemCopyWithImpl<_VideoItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,id,filePath,fileName);

@override
String toString() {
  return 'VideoItem(id: $id, filePath: $filePath, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$VideoItemCopyWith<$Res> implements $VideoItemCopyWith<$Res> {
  factory _$VideoItemCopyWith(_VideoItem value, $Res Function(_VideoItem) _then) = __$VideoItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String filePath, String fileName
});




}
/// @nodoc
class __$VideoItemCopyWithImpl<$Res>
    implements _$VideoItemCopyWith<$Res> {
  __$VideoItemCopyWithImpl(this._self, this._then);

  final _VideoItem _self;
  final $Res Function(_VideoItem) _then;

/// Create a copy of VideoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filePath = null,Object? fileName = null,}) {
  return _then(_VideoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
