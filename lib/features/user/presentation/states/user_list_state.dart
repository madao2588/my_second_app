import 'package:my_second_app/features/user/data/models/user_query.dart';
import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/models/user_model.dart';

class UserListState {
  final UserQuery query;
  final List<UserModel> items;
  final List<RoleModel> roles;
  final List<Map<String, dynamic>> employees;
  final bool loading;
  final String? errorMessage;
  final int total;
  final int? status;

  const UserListState({
    this.query = const UserQuery(),
    this.items = const [],
    this.roles = const [],
    this.employees = const [],
    this.loading = true,
    this.errorMessage,
    this.total = 0,
    this.status,
  });

  UserListState copyWith({
    UserQuery? query,
    List<UserModel>? items,
    List<RoleModel>? roles,
    List<Map<String, dynamic>>? employees,
    bool? loading,
    String? errorMessage,
    int? total,
    int? status,
    bool clearError = false,
    bool clearStatus = false,
  }) {
    return UserListState(
      query: query ?? this.query,
      items: items ?? this.items,
      roles: roles ?? this.roles,
      employees: employees ?? this.employees,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      total: total ?? this.total,
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}
