class PositionFormData {
  final String positionCode;
  final String positionName;
  final String? levelName;
  final int status;
  final String? remark;

  const PositionFormData({
    required this.positionCode,
    required this.positionName,
    required this.levelName,
    required this.status,
    required this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'position_code': positionCode,
      'position_name': positionName,
      'level_name': levelName,
      'status': status,
      'remark': remark,
    };
  }
}
