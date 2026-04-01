import 'package:dio/dio.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/position/data/models/position_form_data.dart';
import 'package:my_second_app/features/position/data/models/position_model.dart';
import 'package:my_second_app/features/position/data/models/position_query.dart';
import 'package:my_second_app/shared/models/option_item.dart';
import 'package:my_second_app/shared/models/page_result.dart';

class PositionRepository {
  final Dio _dio;

  PositionRepository(this._dio);

  Future<PageResult<PositionModel>> fetchPositions(PositionQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/positions',
      queryParameters: query.toQueryParameters(),
    );
    final data = _unwrapObject(response.data);
    final items = (data['items'] as List<dynamic>)
        .map((item) => PositionModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return PageResult<PositionModel>(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? query.page,
      pageSize: data['page_size'] as int? ?? query.pageSize,
    );
  }

  Future<Map<String, dynamic>> fetchPositionDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/positions/$id');
    return _unwrapObject(response.data);
  }

  Future<void> createPosition(PositionFormData data) async {
    await _dio.post<Map<String, dynamic>>('/positions', data: data.toJson());
  }

  Future<void> updatePosition(int id, Map<String, dynamic> data) async {
    await _dio.put<Map<String, dynamic>>('/positions/$id', data: data);
  }

  Future<void> deletePosition(int id) async {
    await _dio.delete<Map<String, dynamic>>('/positions/$id');
  }

  Future<List<OptionItem>> fetchOptions() async {
    final response = await _dio.get<Map<String, dynamic>>('/positions/options');
    final data = _unwrapList(response.data);
    return data
        .map(
          (item) => OptionItem(
            label: item['position_name'] as String,
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
