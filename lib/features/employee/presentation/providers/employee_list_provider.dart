import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/features/employee/presentation/states/employee_list_state.dart';
import 'package:my_second_app/shared/models/option_item.dart';
import 'package:my_second_app/shared/repositories/department_repository.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';
import 'package:my_second_app/shared/repositories/position_repository.dart';

class EmployeeListController extends ChangeNotifier {
  EmployeeListController()
      : _employeeRepository = EmployeeRepository(appAuthController.dio),
        _departmentRepository = DepartmentRepository(appAuthController.dio),
        _positionRepository = PositionRepository(appAuthController.dio),
        state = const EmployeeListState();

  final EmployeeRepository _employeeRepository;
  final DepartmentRepository _departmentRepository;
  final PositionRepository _positionRepository;

  EmployeeListState state;

  Future<void> bootstrap() async {
    await Future.wait([_loadOptions(), load()]);
  }

  Future<void> refresh() async {
    await Future.wait([_loadOptions(), load()]);
  }

  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final result = await _employeeRepository.fetchEmployees(state.query);
      state = state.copyWith(
        employees: result.items,
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
        errorMessage: '员工数据加载失败，请稍后重试。',
      );
      notifyListeners();
    }
  }

  Future<void> search(String keyword) async {
    state = state.copyWith(
      query: state.query.copyWith(
        page: 1,
        keyword: keyword.trim(),
        deptId: state.selectedDeptId,
        status: state.selectedStatus,
      ),
    );
    notifyListeners();
    await load();
  }

  Future<void> reset() async {
    state = state.copyWith(
      query: const EmployeeQuery(),
      clearSelectedDeptId: true,
      clearSelectedStatus: true,
    );
    notifyListeners();
    await load();
  }

  Future<void> changePage(int page) async {
    if (page < 1) return;
    final maxPage = (state.total / state.query.pageSize).ceil();
    if (maxPage > 0 && page > maxPage) return;

    state = state.copyWith(
      query: state.query.copyWith(page: page),
    );
    notifyListeners();
    await load();
  }

  void setDepartmentFilter(int? deptId) {
    state = state.copyWith(
        selectedDeptId: deptId, clearSelectedDeptId: deptId == null);
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(
        selectedStatus: status, clearSelectedStatus: status == null);
    notifyListeners();
  }

  Future<void> _loadOptions() async {
    try {
      final departments = await _departmentRepository.fetchOptions();
      final positions = await _positionRepository.fetchOptions();
      final leaders = await _employeeRepository.fetchEmployees(
        const EmployeeQuery(page: 1, pageSize: 100),
      );

      final leaderOptions = leaders.items
          .map(
            (item) => OptionItem(
              label: item.name,
              value: item.id.toString(),
            ),
          )
          .toList();

      state = state.copyWith(
        departmentOptions: departments,
        positionOptions: positions,
        leaderOptions: leaderOptions,
      );
      notifyListeners();
    } catch (_) {}
  }
}

final employeeListControllerProvider =
    ChangeNotifierProvider<EmployeeListController>(
  (ref) => EmployeeListController(),
);
