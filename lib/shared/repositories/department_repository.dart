import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/department/data/models/department_form_data.dart';
import 'package:my_second_app/features/department/data/models/department_model.dart';
import 'package:my_second_app/features/department/data/models/department_query.dart';
import 'package:my_second_app/shared/models/option_item.dart';
import 'package:my_second_app/shared/models/page_result.dart';

class DepartmentRepository {
  final Dio _dio;

  DepartmentRepository(this._dio);

  Future<PageResult<DepartmentModel>> fetchDepartments(DepartmentQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/departments',
      queryParameters: query.toQueryParameters(),
    );
    final data = _unwrapObject(response.data);
    final items = (data['items'] as List<dynamic>)
        .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return PageResult<DepartmentModel>(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? query.page,
      pageSize: data['page_size'] as int? ?? query.pageSize,
    );
  }

  Future<Map<String, dynamic>> fetchDepartmentDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/departments/$id');
    return _unwrapObject(response.data);
  }

  Future<void> createDepartment(DepartmentFormData data) async {
    await _dio.post<Map<String, dynamic>>('/departments', data: data.toJson());
  }

  Future<void> updateDepartment(int id, Map<String, dynamic> data) async {
    await _dio.put<Map<String, dynamic>>('/departments/$id', data: data);
  }

  Future<void> deleteDepartment(int id) async {
    await _dio.delete<Map<String, dynamic>>('/departments/$id');
  }

  Future<List<OptionItem>> fetchOptions() async {
    final response = await _dio.get<Map<String, dynamic>>('/departments/options');
    final data = _unwrapList(response.data);
    return data
        .map(
          (item) => OptionItem(
            label: item['dept_name'] as String,
            value: (item['id'] as int).toString(),
          ),
        )
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
