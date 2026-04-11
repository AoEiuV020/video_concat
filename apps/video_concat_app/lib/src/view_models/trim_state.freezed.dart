// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trim_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrimState {

/// 视频 ID
 String get videoId;/// 视频文件路径
 String get filePath;/// 视频文件名
 String get fileName;/// 视频总时长（微秒）
 int get durationUs;/// 当前滑块位置（微秒，已吸附到关键帧）
 int get currentPositionUs;/// 待配对的 inpoint（微秒），null 表示无待配对
 int? get pendingInpointUs;/// 滑块释放后正在吸附关键帧
 bool get isSnapping;/// 已选片段列表
 List<TrimSegment> get segments;/// 预览图字节数据
 Uint8List? get previewImage;/// 是否正在加载预览
 bool get isLoadingPreview;/// 是否正在加载（初始化中）
 bool get isLoading;/// 错误消息
 String? get errorMessage;
/// Create a copy of TrimState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrimStateCopyWith<TrimState> get copyWith => _$TrimStateCopyWithImpl<TrimState>(this as TrimState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrimState&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.durationUs, durationUs) || other.durationUs == durationUs)&&(identical(other.currentPositionUs, currentPositionUs) || other.currentPositionUs == currentPositionUs)&&(identical(other.pendingInpointUs, pendingInpointUs) || other.pendingInpointUs == pendingInpointUs)&&(identical(other.isSnapping, isSnapping) || other.isSnapping == isSnapping)&&const DeepCollectionEquality().equals(other.segments, segments)&&const DeepCollectionEquality().equals(other.previewImage, previewImage)&&(identical(other.isLoadingPreview, isLoadingPreview) || other.isLoadingPreview == isLoadingPreview)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,filePath,fileName,durationUs,currentPositionUs,pendingInpointUs,isSnapping,const DeepCollectionEquality().hash(segments),const DeepCollectionEquality().hash(previewImage),isLoadingPreview,isLoading,errorMessage);

@override
String toString() {
  return 'TrimState(videoId: $videoId, filePath: $filePath, fileName: $fileName, durationUs: $durationUs, currentPositionUs: $currentPositionUs, pendingInpointUs: $pendingInpointUs, isSnapping: $isSnapping, segments: $segments, previewImage: $previewImage, isLoadingPreview: $isLoadingPreview, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TrimStateCopyWith<$Res>  {
  factory $TrimStateCopyWith(TrimState value, $Res Function(TrimState) _then) = _$TrimStateCopyWithImpl;
@useResult
$Res call({
 String videoId, String filePath, String fileName, int durationUs, int currentPositionUs, int? pendingInpointUs, bool isSnapping, List<TrimSegment> segments, Uint8List? previewImage, bool isLoadingPreview, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$TrimStateCopyWithImpl<$Res>
    implements $TrimStateCopyWith<$Res> {
  _$TrimStateCopyWithImpl(this._self, this._then);

  final TrimState _self;
  final $Res Function(TrimState) _then;

/// Create a copy of TrimState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? filePath = null,Object? fileName = null,Object? durationUs = null,Object? currentPositionUs = null,Object? pendingInpointUs = freezed,Object? isSnapping = null,Object? segments = null,Object? previewImage = freezed,Object? isLoadingPreview = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,durationUs: null == durationUs ? _self.durationUs : durationUs // ignore: cast_nullable_to_non_nullable
as int,currentPositionUs: null == currentPositionUs ? _self.currentPositionUs : currentPositionUs // ignore: cast_nullable_to_non_nullable
as int,pendingInpointUs: freezed == pendingInpointUs ? _self.pendingInpointUs : pendingInpointUs // ignore: cast_nullable_to_non_nullable
as int?,isSnapping: null == isSnapping ? _self.isSnapping : isSnapping // ignore: cast_nullable_to_non_nullable
as bool,segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<TrimSegment>,previewImage: freezed == previewImage ? _self.previewImage : previewImage // ignore: cast_nullable_to_non_nullable
as Uint8List?,isLoadingPreview: null == isLoadingPreview ? _self.isLoadingPreview : isLoadingPreview // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrimState].
extension TrimStatePatterns on TrimState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrimState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrimState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrimState value)  $default,){
final _that = this;
switch (_that) {
case _TrimState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrimState value)?  $default,){
final _that = this;
switch (_that) {
case _TrimState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String filePath,  String fileName,  int durationUs,  int currentPositionUs,  int? pendingInpointUs,  bool isSnapping,  List<TrimSegment> segments,  Uint8List? previewImage,  bool isLoadingPreview,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrimState() when $default != null:
return $default(_that.videoId,_that.filePath,_that.fileName,_that.durationUs,_that.currentPositionUs,_that.pendingInpointUs,_that.isSnapping,_that.segments,_that.previewImage,_that.isLoadingPreview,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String filePath,  String fileName,  int durationUs,  int currentPositionUs,  int? pendingInpointUs,  bool isSnapping,  List<TrimSegment> segments,  Uint8List? previewImage,  bool isLoadingPreview,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TrimState():
return $default(_that.videoId,_that.filePath,_that.fileName,_that.durationUs,_that.currentPositionUs,_that.pendingInpointUs,_that.isSnapping,_that.segments,_that.previewImage,_that.isLoadingPreview,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String filePath,  String fileName,  int durationUs,  int currentPositionUs,  int? pendingInpointUs,  bool isSnapping,  List<TrimSegment> segments,  Uint8List? previewImage,  bool isLoadingPreview,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TrimState() when $default != null:
return $default(_that.videoId,_that.filePath,_that.fileName,_that.durationUs,_that.currentPositionUs,_that.pendingInpointUs,_that.isSnapping,_that.segments,_that.previewImage,_that.isLoadingPreview,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TrimState implements TrimState {
  const _TrimState({required this.videoId, required this.filePath, required this.fileName, required this.durationUs, this.currentPositionUs = 0, this.pendingInpointUs, this.isSnapping = false, final  List<TrimSegment> segments = const [], this.previewImage, this.isLoadingPreview = false, this.isLoading = true, this.errorMessage}): _segments = segments;
  

/// 视频 ID
@override final  String videoId;
/// 视频文件路径
@override final  String filePath;
/// 视频文件名
@override final  String fileName;
/// 视频总时长（微秒）
@override final  int durationUs;
/// 当前滑块位置（微秒，已吸附到关键帧）
@override@JsonKey() final  int currentPositionUs;
/// 待配对的 inpoint（微秒），null 表示无待配对
@override final  int? pendingInpointUs;
/// 滑块释放后正在吸附关键帧
@override@JsonKey() final  bool isSnapping;
/// 已选片段列表
 final  List<TrimSegment> _segments;
/// 已选片段列表
@override@JsonKey() List<TrimSegment> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

/// 预览图字节数据
@override final  Uint8List? previewImage;
/// 是否正在加载预览
@override@JsonKey() final  bool isLoadingPreview;
/// 是否正在加载（初始化中）
@override@JsonKey() final  bool isLoading;
/// 错误消息
@override final  String? errorMessage;

/// Create a copy of TrimState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrimStateCopyWith<_TrimState> get copyWith => __$TrimStateCopyWithImpl<_TrimState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrimState&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.durationUs, durationUs) || other.durationUs == durationUs)&&(identical(other.currentPositionUs, currentPositionUs) || other.currentPositionUs == currentPositionUs)&&(identical(other.pendingInpointUs, pendingInpointUs) || other.pendingInpointUs == pendingInpointUs)&&(identical(other.isSnapping, isSnapping) || other.isSnapping == isSnapping)&&const DeepCollectionEquality().equals(other._segments, _segments)&&const DeepCollectionEquality().equals(other.previewImage, previewImage)&&(identical(other.isLoadingPreview, isLoadingPreview) || other.isLoadingPreview == isLoadingPreview)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,filePath,fileName,durationUs,currentPositionUs,pendingInpointUs,isSnapping,const DeepCollectionEquality().hash(_segments),const DeepCollectionEquality().hash(previewImage),isLoadingPreview,isLoading,errorMessage);

@override
String toString() {
  return 'TrimState(videoId: $videoId, filePath: $filePath, fileName: $fileName, durationUs: $durationUs, currentPositionUs: $currentPositionUs, pendingInpointUs: $pendingInpointUs, isSnapping: $isSnapping, segments: $segments, previewImage: $previewImage, isLoadingPreview: $isLoadingPreview, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TrimStateCopyWith<$Res> implements $TrimStateCopyWith<$Res> {
  factory _$TrimStateCopyWith(_TrimState value, $Res Function(_TrimState) _then) = __$TrimStateCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String filePath, String fileName, int durationUs, int currentPositionUs, int? pendingInpointUs, bool isSnapping, List<TrimSegment> segments, Uint8List? previewImage, bool isLoadingPreview, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$TrimStateCopyWithImpl<$Res>
    implements _$TrimStateCopyWith<$Res> {
  __$TrimStateCopyWithImpl(this._self, this._then);

  final _TrimState _self;
  final $Res Function(_TrimState) _then;

/// Create a copy of TrimState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? filePath = null,Object? fileName = null,Object? durationUs = null,Object? currentPositionUs = null,Object? pendingInpointUs = freezed,Object? isSnapping = null,Object? segments = null,Object? previewImage = freezed,Object? isLoadingPreview = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_TrimState(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,durationUs: null == durationUs ? _self.durationUs : durationUs // ignore: cast_nullable_to_non_nullable
as int,currentPositionUs: null == currentPositionUs ? _self.currentPositionUs : currentPositionUs // ignore: cast_nullable_to_non_nullable
as int,pendingInpointUs: freezed == pendingInpointUs ? _self.pendingInpointUs : pendingInpointUs // ignore: cast_nullable_to_non_nullable
as int?,isSnapping: null == isSnapping ? _self.isSnapping : isSnapping // ignore: cast_nullable_to_non_nullable
as bool,segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<TrimSegment>,previewImage: freezed == previewImage ? _self.previewImage : previewImage // ignore: cast_nullable_to_non_nullable
as Uint8List?,isLoadingPreview: null == isLoadingPreview ? _self.isLoadingPreview : isLoadingPreview // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
