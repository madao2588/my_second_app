import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/employee/data/models/employee_form_data.dart';
import 'package:my_second_app/features/employee/data/models/employee_model.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/shared/models/page_result.dart';

class EmployeeRepository {
  final Dio _dio;

  EmployeeRepository(this._dio);

  Future<PageResult<EmployeeModel>> fetchEmployees(EmployeeQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/employees',
      queryParameters: query.toQueryParameters(),
    );
    final data = _unwrap(response.data);
    final items = (data['items'] as List<dynamic>)
        .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PageResult<EmployeeModel>(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? query.page,
      pageSize: data['page_size'] as int? ?? query.pageSize,
    );
  }

  Future<Map<String, dynamic>> fetchEmployeeDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/employees/$id');
    return _unwrap(response.data);
  }

  Future<void> createEmployee(EmployeeFormData data) async {
    await _dio.post<Map<String, dynamic>>('/employees', data: data.toJson());
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    await _dio.put<Map<String, dynamic>>('/employees/$id', data: data);
  }

  Future<void> deleteEmployee(int id) async {
    await _dio.delete<Map<String, dynamic>>('/employees/$id');
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic>? response) {
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
}
