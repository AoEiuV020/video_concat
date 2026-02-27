/// 单个流的差异信息。
class StreamDiff {
  /// 流索引
  final int index;

  /// 流类型："video" / "audio"
  final String codecType;

  /// 差异字段：字段名 → (标准值, 实际值)
  final Map<String, (String, String)> fields;

  const StreamDiff({
    required this.index,
    required this.codecType,
    required this.fields,
  });

  /// 是否有差异。
  bool get hasDifferences => fields.isNotEmpty;
}
