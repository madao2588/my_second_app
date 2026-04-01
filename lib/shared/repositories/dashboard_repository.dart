import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/dashboard/data/models/chart_item_model.dart';
import 'package:my_second_app/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:my_second_app/features/dashboard/data/models/latest_hire_model.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardSummaryModel> fetchSummary() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/summary');
    return DashboardSummaryModel.fromJson(_unwrapObject(response.data));
  }

  Future<List<ChartItemModel>> fetchDepartmentDistribution() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/department-distribution');
    return _unwrapList(response.data)
        .map((item) => ChartItemModel.fromJson(item))
        .toList();
  }

  Future<List<ChartItemModel>> fetchPositionDistribution() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/position-distribution');
    return _unwrapList(response.data)
        .map((item) => ChartItemModel.fromJson(item))
        .toList();
  }

  Future<List<LatestHireModel>> fetchLatestHires() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/dashboard/latest-hires',
      queryParameters: const {'limit': 5},
    );
    return _unwrapList(response.data)
        .map((item) => LatestHireModel.fromJson(item))
        .toList();
  }

  Map<String, dynamic> _unwrapObject(Map<String, dynamic>? response) {
    if (response == null) {
      throw const ApiException(code: -1, message: '响应为空');
    }
    final code = response['code'] as int? ?? -1;
    final message = response['message'] as String? ?? '请求失败';
    if (code != 0) {
      throw ApiException(code: code, message: message);
    }
    return response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic>? response) {
    if (response == null) {
      throw const ApiException(code: -1, message: '响应为空');
    }
    final code = response['code'] as int? ?? -1;
    final message = response['message'] as String? ?? '请求失败';
    if (code != 0) {
      throw ApiException(code: code, message: message);
    }
    return (response['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
