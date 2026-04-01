class PositionModel {
  final int id;
  final String positionCode;
  final String positionName;
  final String? levelName;
  final int status;
  final String? remark;

  const PositionModel({
    required this.id,
    required this.positionCode,
    required this.positionName,
    required this.levelName,
    required this.status,
    required this.remark,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'] as int,
      positionCode: json['position_code'] as String,
      positionName: json['position_name'] as String,
      levelName: json['level_name'] as String?,
      status: json['status'] as int? ?? 1,
      remark: json['remark'] as String?,
    );
  }
}
