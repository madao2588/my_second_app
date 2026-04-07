import 'package:my_second_app/features/employee/data/models/employee_model.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/shared/models/option_item.dart';

class EmployeeListState {
  final EmployeeQuery query;
  final List<EmployeeModel> employees;
  final List<OptionItem> departmentOptions;
  final List<OptionItem> positionOptions;
  final List<OptionItem> leaderOptions;
  final bool loading;
  final String? errorMessage;
  final int total;
  final int? selectedDeptId;
  final String? selectedStatus;

  const EmployeeListState({
    this.query = const EmployeeQuery(),
    this.employees = const [],
    this.departmentOptions = const [],
    this.positionOptions = const [],
    this.leaderOptions = const [],
    this.loading = true,
    this.errorMessage,
    this.total = 0,
    this.selectedDeptId,
    this.selectedStatus,
  });

  EmployeeListState copyWith({
    EmployeeQuery? query,
    List<EmployeeModel>? employees,
    List<OptionItem>? departmentOptions,
    List<OptionItem>? positionOptions,
    List<OptionItem>? leaderOptions,
    bool? loading,
    String? errorMessage,
    int? total,
    int? selectedDeptId,
    String? selectedStatus,
    bool clearError = false,
    bool clearSelectedDeptId = false,
    bool clearSelectedStatus = false,
  }) {
    return EmployeeListState(
      query: query ?? this.query,
      employees: employees ?? this.employees,
      departmentOptions: departmentOptions ?? this.departmentOptions,
      positionOptions: positionOptions ?? this.positionOptions,
      leaderOptions: leaderOptions ?? this.leaderOptions,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      total: total ?? this.total,
      selectedDeptId:
          clearSelectedDeptId ? null : (selectedDeptId ?? this.selectedDeptId),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}
