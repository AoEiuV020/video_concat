// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportOptions {

/// 是否展开导出选项面板
 bool get showOptions;/// 元数据旋转角度（null 表示不设置，0/90/180/270）
 int? get rotation;/// 去除音频轨
 bool get removeAudio;/// 去除字幕轨
 bool get removeSubtitles;/// mp4/mov 快速启动（moov 前置）
 bool get fastStart;/// 清除元数据
 bool get stripMetadata;/// 在拼接点添加章节标记
 bool get addChapters;/// 合并成功后自动打开信息页
 bool get autoOpenVideoInfo;/// 启用按目标时长分段输出
 bool get enableSegmentOutput;/// 分段时长输入文本
 String get segmentDurationText;/// 分段文件名模板
 String get segmentFilenameTemplate;/// 记住所有导出选择
 bool get rememberChoices;
/// Create a copy of ExportOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportOptionsCopyWith<ExportOptions> get copyWith => _$ExportOptionsCopyWithImpl<ExportOptions>(this as ExportOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportOptions&&(identical(other.showOptions, showOptions) || other.showOptions == showOptions)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.removeAudio, removeAudio) || other.removeAudio == removeAudio)&&(identical(other.removeSubtitles, removeSubtitles) || other.removeSubtitles == removeSubtitles)&&(identical(other.fastStart, fastStart) || other.fastStart == fastStart)&&(identical(other.stripMetadata, stripMetadata) || other.stripMetadata == stripMetadata)&&(identical(other.addChapters, addChapters) || other.addChapters == addChapters)&&(identical(other.autoOpenVideoInfo, autoOpenVideoInfo) || other.autoOpenVideoInfo == autoOpenVideoInfo)&&(identical(other.enableSegmentOutput, enableSegmentOutput) || other.enableSegmentOutput == enableSegmentOutput)&&(identical(other.segmentDurationText, segmentDurationText) || other.segmentDurationText == segmentDurationText)&&(identical(other.segmentFilenameTemplate, segmentFilenameTemplate) || other.segmentFilenameTemplate == segmentFilenameTemplate)&&(identical(other.rememberChoices, rememberChoices) || other.rememberChoices == rememberChoices));
}


@override
int get hashCode => Object.hash(runtimeType,showOptions,rotation,removeAudio,removeSubtitles,fastStart,stripMetadata,addChapters,autoOpenVideoInfo,enableSegmentOutput,segmentDurationText,segmentFilenameTemplate,rememberChoices);

@override
String toString() {
  return 'ExportOptions(showOptions: $showOptions, rotation: $rotation, removeAudio: $removeAudio, removeSubtitles: $removeSubtitles, fastStart: $fastStart, stripMetadata: $stripMetadata, addChapters: $addChapters, autoOpenVideoInfo: $autoOpenVideoInfo, enableSegmentOutput: $enableSegmentOutput, segmentDurationText: $segmentDurationText, segmentFilenameTemplate: $segmentFilenameTemplate, rememberChoices: $rememberChoices)';
}


}

/// @nodoc
abstract mixin class $ExportOptionsCopyWith<$Res>  {
  factory $ExportOptionsCopyWith(ExportOptions value, $Res Function(ExportOptions) _then) = _$ExportOptionsCopyWithImpl;
@useResult
$Res call({
 bool showOptions, int? rotation, bool removeAudio, bool removeSubtitles, bool fastStart, bool stripMetadata, bool addChapters, bool autoOpenVideoInfo, bool enableSegmentOutput, String segmentDurationText, String segmentFilenameTemplate, bool rememberChoices
});




}
/// @nodoc
class _$ExportOptionsCopyWithImpl<$Res>
    implements $ExportOptionsCopyWith<$Res> {
  _$ExportOptionsCopyWithImpl(this._self, this._then);

  final ExportOptions _self;
  final $Res Function(ExportOptions) _then;

/// Create a copy of ExportOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showOptions = null,Object? rotation = freezed,Object? removeAudio = null,Object? removeSubtitles = null,Object? fastStart = null,Object? stripMetadata = null,Object? addChapters = null,Object? autoOpenVideoInfo = null,Object? enableSegmentOutput = null,Object? segmentDurationText = null,Object? segmentFilenameTemplate = null,Object? rememberChoices = null,}) {
  return _then(_self.copyWith(
showOptions: null == showOptions ? _self.showOptions : showOptions // ignore: cast_nullable_to_non_nullable
as bool,rotation: freezed == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as int?,removeAudio: null == removeAudio ? _self.removeAudio : removeAudio // ignore: cast_nullable_to_non_nullable
as bool,removeSubtitles: null == removeSubtitles ? _self.removeSubtitles : removeSubtitles // ignore: cast_nullable_to_non_nullable
as bool,fastStart: null == fastStart ? _self.fastStart : fastStart // ignore: cast_nullable_to_non_nullable
as bool,stripMetadata: null == stripMetadata ? _self.stripMetadata : stripMetadata // ignore: cast_nullable_to_non_nullable
as bool,addChapters: null == addChapters ? _self.addChapters : addChapters // ignore: cast_nullable_to_non_nullable
as bool,autoOpenVideoInfo: null == autoOpenVideoInfo ? _self.autoOpenVideoInfo : autoOpenVideoInfo // ignore: cast_nullable_to_non_nullable
as bool,enableSegmentOutput: null == enableSegmentOutput ? _self.enableSegmentOutput : enableSegmentOutput // ignore: cast_nullable_to_non_nullable
as bool,segmentDurationText: null == segmentDurationText ? _self.segmentDurationText : segmentDurationText // ignore: cast_nullable_to_non_nullable
as String,segmentFilenameTemplate: null == segmentFilenameTemplate ? _self.segmentFilenameTemplate : segmentFilenameTemplate // ignore: cast_nullable_to_non_nullable
as String,rememberChoices: null == rememberChoices ? _self.rememberChoices : rememberChoices // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportOptions].
extension ExportOptionsPatterns on ExportOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportOptions value)  $default,){
final _that = this;
switch (_that) {
case _ExportOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ExportOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showOptions,  int? rotation,  bool removeAudio,  bool removeSubtitles,  bool fastStart,  bool stripMetadata,  bool addChapters,  bool autoOpenVideoInfo,  bool enableSegmentOutput,  String segmentDurationText,  String segmentFilenameTemplate,  bool rememberChoices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportOptions() when $default != null:
return $default(_that.showOptions,_that.rotation,_that.removeAudio,_that.removeSubtitles,_that.fastStart,_that.stripMetadata,_that.addChapters,_that.autoOpenVideoInfo,_that.enableSegmentOutput,_that.segmentDurationText,_that.segmentFilenameTemplate,_that.rememberChoices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showOptions,  int? rotation,  bool removeAudio,  bool removeSubtitles,  bool fastStart,  bool stripMetadata,  bool addChapters,  bool autoOpenVideoInfo,  bool enableSegmentOutput,  String segmentDurationText,  String segmentFilenameTemplate,  bool rememberChoices)  $default,) {final _that = this;
switch (_that) {
case _ExportOptions():
return $default(_that.showOptions,_that.rotation,_that.removeAudio,_that.removeSubtitles,_that.fastStart,_that.stripMetadata,_that.addChapters,_that.autoOpenVideoInfo,_that.enableSegmentOutput,_that.segmentDurationText,_that.segmentFilenameTemplate,_that.rememberChoices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showOptions,  int? rotation,  bool removeAudio,  bool removeSubtitles,  bool fastStart,  bool stripMetadata,  bool addChapters,  bool autoOpenVideoInfo,  bool enableSegmentOutput,  String segmentDurationText,  String segmentFilenameTemplate,  bool rememberChoices)?  $default,) {final _that = this;
switch (_that) {
case _ExportOptions() when $default != null:
return $default(_that.showOptions,_that.rotation,_that.removeAudio,_that.removeSubtitles,_that.fastStart,_that.stripMetadata,_that.addChapters,_that.autoOpenVideoInfo,_that.enableSegmentOutput,_that.segmentDurationText,_that.segmentFilenameTemplate,_that.rememberChoices);case _:
  return null;

}
}

}

/// @nodoc


class _ExportOptions extends ExportOptions {
  const _ExportOptions({this.showOptions = false, this.rotation = null, this.removeAudio = false, this.removeSubtitles = false, this.fastStart = false, this.stripMetadata = false, this.addChapters = false, this.autoOpenVideoInfo = false, this.enableSegmentOutput = false, this.segmentDurationText = '', this.segmentFilenameTemplate = '%filename%_%03d', this.rememberChoices = false}): super._();
  

/// 是否展开导出选项面板
@override@JsonKey() final  bool showOptions;
/// 元数据旋转角度（null 表示不设置，0/90/180/270）
@override@JsonKey() final  int? rotation;
/// 去除音频轨
@override@JsonKey() final  bool removeAudio;
/// 去除字幕轨
@override@JsonKey() final  bool removeSubtitles;
/// mp4/mov 快速启动（moov 前置）
@override@JsonKey() final  bool fastStart;
/// 清除元数据
@override@JsonKey() final  bool stripMetadata;
/// 在拼接点添加章节标记
@override@JsonKey() final  bool addChapters;
/// 合并成功后自动打开信息页
@override@JsonKey() final  bool autoOpenVideoInfo;
/// 启用按目标时长分段输出
@override@JsonKey() final  bool enableSegmentOutput;
/// 分段时长输入文本
@override@JsonKey() final  String segmentDurationText;
/// 分段文件名模板
@override@JsonKey() final  String segmentFilenameTemplate;
/// 记住所有导出选择
@override@JsonKey() final  bool rememberChoices;

/// Create a copy of ExportOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportOptionsCopyWith<_ExportOptions> get copyWith => __$ExportOptionsCopyWithImpl<_ExportOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportOptions&&(identical(other.showOptions, showOptions) || other.showOptions == showOptions)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.removeAudio, removeAudio) || other.removeAudio == removeAudio)&&(identical(other.removeSubtitles, removeSubtitles) || other.removeSubtitles == removeSubtitles)&&(identical(other.fastStart, fastStart) || other.fastStart == fastStart)&&(identical(other.stripMetadata, stripMetadata) || other.stripMetadata == stripMetadata)&&(identical(other.addChapters, addChapters) || other.addChapters == addChapters)&&(identical(other.autoOpenVideoInfo, autoOpenVideoInfo) || other.autoOpenVideoInfo == autoOpenVideoInfo)&&(identical(other.enableSegmentOutput, enableSegmentOutput) || other.enableSegmentOutput == enableSegmentOutput)&&(identical(other.segmentDurationText, segmentDurationText) || other.segmentDurationText == segmentDurationText)&&(identical(other.segmentFilenameTemplate, segmentFilenameTemplate) || other.segmentFilenameTemplate == segmentFilenameTemplate)&&(identical(other.rememberChoices, rememberChoices) || other.rememberChoices == rememberChoices));
}


@override
int get hashCode => Object.hash(runtimeType,showOptions,rotation,removeAudio,removeSubtitles,fastStart,stripMetadata,addChapters,autoOpenVideoInfo,enableSegmentOutput,segmentDurationText,segmentFilenameTemplate,rememberChoices);

@override
String toString() {
  return 'ExportOptions(showOptions: $showOptions, rotation: $rotation, removeAudio: $removeAudio, removeSubtitles: $removeSubtitles, fastStart: $fastStart, stripMetadata: $stripMetadata, addChapters: $addChapters, autoOpenVideoInfo: $autoOpenVideoInfo, enableSegmentOutput: $enableSegmentOutput, segmentDurationText: $segmentDurationText, segmentFilenameTemplate: $segmentFilenameTemplate, rememberChoices: $rememberChoices)';
}


}

/// @nodoc
abstract mixin class _$ExportOptionsCopyWith<$Res> implements $ExportOptionsCopyWith<$Res> {
  factory _$ExportOptionsCopyWith(_ExportOptions value, $Res Function(_ExportOptions) _then) = __$ExportOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool showOptions, int? rotation, bool removeAudio, bool removeSubtitles, bool fastStart, bool stripMetadata, bool addChapters, bool autoOpenVideoInfo, bool enableSegmentOutput, String segmentDurationText, String segmentFilenameTemplate, bool rememberChoices
});




}
/// @nodoc
class __$ExportOptionsCopyWithImpl<$Res>
    implements _$ExportOptionsCopyWith<$Res> {
  __$ExportOptionsCopyWithImpl(this._self, this._then);

  final _ExportOptions _self;
  final $Res Function(_ExportOptions) _then;

/// Create a copy of ExportOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showOptions = null,Object? rotation = freezed,Object? removeAudio = null,Object? removeSubtitles = null,Object? fastStart = null,Object? stripMetadata = null,Object? addChapters = null,Object? autoOpenVideoInfo = null,Object? enableSegmentOutput = null,Object? segmentDurationText = null,Object? segmentFilenameTemplate = null,Object? rememberChoices = null,}) {
  return _then(_ExportOptions(
showOptions: null == showOptions ? _self.showOptions : showOptions // ignore: cast_nullable_to_non_nullable
as bool,rotation: freezed == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as int?,removeAudio: null == removeAudio ? _self.removeAudio : removeAudio // ignore: cast_nullable_to_non_nullable
as bool,removeSubtitles: null == removeSubtitles ? _self.removeSubtitles : removeSubtitles // ignore: cast_nullable_to_non_nullable
as bool,fastStart: null == fastStart ? _self.fastStart : fastStart // ignore: cast_nullable_to_non_nullable
as bool,stripMetadata: null == stripMetadata ? _self.stripMetadata : stripMetadata // ignore: cast_nullable_to_non_nullable
as bool,addChapters: null == addChapters ? _self.addChapters : addChapters // ignore: cast_nullable_to_non_nullable
as bool,autoOpenVideoInfo: null == autoOpenVideoInfo ? _self.autoOpenVideoInfo : autoOpenVideoInfo // ignore: cast_nullable_to_non_nullable
as bool,enableSegmentOutput: null == enableSegmentOutput ? _self.enableSegmentOutput : enableSegmentOutput // ignore: cast_nullable_to_non_nullable
as bool,segmentDurationText: null == segmentDurationText ? _self.segmentDurationText : segmentDurationText // ignore: cast_nullable_to_non_nullable
as String,segmentFilenameTemplate: null == segmentFilenameTemplate ? _self.segmentFilenameTemplate : segmentFilenameTemplate // ignore: cast_nullable_to_non_nullable
as String,rememberChoices: null == rememberChoices ? _self.rememberChoices : rememberChoices // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
