import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/features/role/data/models/role_query.dart';
import 'package:my_second_app/features/user/data/models/user_query.dart';
import 'package:my_second_app/features/user/presentation/states/user_list_state.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';
import 'package:my_second_app/shared/repositories/role_repository.dart';
import 'package:my_second_app/shared/repositories/user_repository.dart';

class UserListController extends ChangeNotifier {
  UserListController()
      : _usersApi = UserRepository(appAuthController.dio),
        _rolesApi = RoleRepository(appAuthController.dio),
        _employeesApi = EmployeeRepository(appAuthController.dio),
        state = const UserListState();

  final UserRepository _usersApi;
  final RoleRepository _rolesApi;
  final EmployeeRepository _employeesApi;

  UserListState state;

  Future<void> bootstrap() async {
    await Future.wait([_loadOptions(), load()]);
  }

  Future<void> refresh() async {
    await Future.wait([_loadOptions(), load()]);
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    notifyListeners();

    try {
      final result = await _usersApi.fetchUsers(state.query);
      state = state.copyWith(
        items: result.items,
        total: result.total,
        loading: false,
      );
      notifyListeners();
    } on ApiException catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.message,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        loading: false,
        errorMessage: '用户数据加载失败，请稍后重试。',
      );
      notifyListeners();
    }
  }

  Future<void> search(String keyword) async {
    state = state.copyWith(
      query: state.query.copyWith(
        page: 1,
        keyword: keyword.trim(),
        status: state.status,
      ),
    );
    notifyListeners();
    await load();
  }

  Future<void> reset() async {
    state = state.copyWith(
      query: const UserQuery(),
      clearStatus: true,
    );
    notifyListeners();
    await load();
  }

  Future<void> changePage(int page) async {
    final maxPage = (state.total / state.query.pageSize).ceil();
    if (page < 1 || (maxPage > 0 && page > maxPage)) return;

    state = state.copyWith(
      query: state.query.copyWith(page: page),
    );
    notifyListeners();
    await load();
  }

  void setStatusFilter(int? status) {
    state = state.copyWith(
      status: status,
      clearStatus: status == null,
    );
    notifyListeners();
  }

  Future<void> _loadOptions() async {
    try {
      final roles =
          await _rolesApi.fetchRoles(const RoleQuery(page: 1, pageSize: 100));
      final employees = await _employeesApi.fetchEmployees(
        const EmployeeQuery(page: 1, pageSize: 100),
      );

      state = state.copyWith(
        roles: roles.items,
        employees: employees.items
            .map((employee) => {'id': employee.id, 'name': employee.name})
            .toList(),
      );
      notifyListeners();
    } catch (_) {}
  }
}

final userListControllerProvider = ChangeNotifierProvider<UserListController>(
  (ref) => UserListController(),
);
