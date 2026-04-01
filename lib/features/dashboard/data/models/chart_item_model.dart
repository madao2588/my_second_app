class ChartItemModel {
  final String name;
  final int value;

  const ChartItemModel({
    required this.name,
    required this.value,
  });

  factory ChartItemModel.fromJson(Map<String, dynamic> json) {
    return ChartItemModel(
      name: json['name'] as String? ?? '',
      value: json['value'] as int? ?? 0,
    );
  }
}
