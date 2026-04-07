import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/app_breakpoints.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/core/permissions/permission_widget.dart';
import 'package:my_second_app/core/widgets/app_button.dart';
import 'package:my_second_app/core/widgets/app_card.dart';
import 'package:my_second_app/core/widgets/app_confirm_dialog.dart';
import 'package:my_second_app/core/widgets/app_drawer_form.dart';
import 'package:my_second_app/core/widgets/app_empty.dart';
import 'package:my_second_app/core/widgets/app_error_state.dart';
import 'package:my_second_app/core/widgets/app_feedback.dart';
import 'package:my_second_app/core/widgets/app_loading_skeleton.dart';
import 'package:my_second_app/core/widgets/app_metric_card.dart';
import 'package:my_second_app/core/widgets/app_page_header.dart';
import 'package:my_second_app/core/widgets/app_pagination.dart';
import 'package:my_second_app/core/widgets/app_search_field.dart';
import 'package:my_second_app/core/widgets/app_select.dart';
import 'package:my_second_app/core/widgets/app_status_pill.dart';
import 'package:my_second_app/core/widgets/app_table.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/employee/data/models/employee_form_data.dart';
import 'package:my_second_app/features/employee/data/models/employee_model.dart';
import 'package:my_second_app/features/employee/presentation/providers/employee_list_provider.dart';
import 'package:my_second_app/features/employee/presentation/states/employee_list_state.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';

class EmployeeListPage extends ConsumerStatefulWidget {
  const EmployeeListPage({super.key});

  @override
  ConsumerState<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends ConsumerState<EmployeeListPage> {
  late final EmployeeRepository _employeeRepository;

  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _employeeRepository = EmployeeRepository(appAuthController.dio);
    Future.microtask(
      () => ref.read(employeeListControllerProvider).bootstrap(),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final saved = await _showEmployeeForm();
    if (saved == true) {
      await ref.read(employeeListControllerProvider).refresh();
    }
  }

  Future<void> _openEdit(EmployeeModel employee) async {
    final saved = await _showEmployeeForm(employeeId: employee.id);
    if (saved == true) {
      await ref.read(employeeListControllerProvider).refresh();
    }
  }

  Future<void> _deleteEmployee(EmployeeModel employee) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '确认删除',
      message: '确认要删除“${employee.name}”吗？',
      confirmText: '删除',
    );
    if (!confirmed) return;

    try {
      await _employeeRepository.deleteEmployee(employee.id);
      if (!mounted) return;
      showAppSuccess(context, '员工删除成功');
      await ref.read(employeeListControllerProvider).refresh();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppError(context, error.message);
    }
  }

  Future<bool?> _showEmployeeForm({int? employeeId}) async {
    final isEdit = employeeId != null;
    final listState = ref.read(employeeListControllerProvider).state;
    Map<String, dynamic>? detail;

    if (isEdit) {
      try {
        detail = await _employeeRepository.fetchEmployeeDetail(employeeId);
      } on ApiException catch (error) {
        if (!mounted) return false;
        showAppError(context, error.message);
        return false;
      }
    }

    if (!mounted) return false;

    final formKey = GlobalKey<FormState>();
    final empNoController =
        TextEditingController(text: detail?['emp_no'] as String? ?? '');
    final nameController =
        TextEditingController(text: detail?['name'] as String? ?? '');
    final phoneController =
        TextEditingController(text: detail?['phone'] as String? ?? '');
    final emailController =
        TextEditingController(text: detail?['email'] as String? ?? '');
    final hireDateController = TextEditingController(
      text: detail?['hire_date'] as String? ??
          DateTime.now().toIso8601String().split('T').first,
    );
    final birthDateController =
        TextEditingController(text: detail?['birth_date'] as String? ?? '');
    final leftAtController =
        TextEditingController(text: detail?['left_at'] as String? ?? '');
    final addressController =
        TextEditingController(text: detail?['address'] as String? ?? '');
    final remarkController =
        TextEditingController(text: detail?['remark'] as String? ?? '');

    String gender = detail?['gender'] as String? ?? 'male';
    String status = detail?['status'] as String? ?? 'active';
    int? deptId = detail?['dept_id'] as int?;
    int? positionId = detail?['position_id'] as int?;
    int? leaderId = detail?['leader_id'] as int?;
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'employee_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              if (deptId == null || positionId == null) {
                setModalState(() => formError = '请选择部门和岗位。');
                return;
              }

              setModalState(() {
                saving = true;
                formError = null;
              });

              final formData = EmployeeFormData(
                empNo: empNoController.text.trim(),
                name: nameController.text.trim(),
                gender: gender,
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                deptId: deptId!,
                positionId: positionId!,
                leaderId: leaderId,
                status: status,
                hireDate: hireDateController.text.trim(),
                leftAt: leftAtController.text.trim().isEmpty
                    ? null
                    : leftAtController.text.trim(),
                birthDate: birthDateController.text.trim().isEmpty
                    ? null
                    : birthDateController.text.trim(),
                address: addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
                remark: remarkController.text.trim().isEmpty
                    ? null
                    : remarkController.text.trim(),
              );

              try {
                if (isEdit) {
                  final data = formData.toJson()..remove('emp_no');
                  await _employeeRepository.updateEmployee(employeeId, data);
                } else {
                  await _employeeRepository.createEmployee(formData);
                }

                if (!context.mounted) return;
                Navigator.pop(context, true);
              } on ApiException catch (error) {
                setModalState(() {
                  saving = false;
                  formError = error.message;
                });
              } catch (_) {
                setModalState(() {
                  saving = false;
                  formError = isEdit ? '员工更新失败，请稍后重试。' : '员工创建失败，请稍后重试。';
                });
              }
            }

            return AppDrawerForm(
              title: isEdit ? '编辑员工' : '新建员工',
              subtitle:
                  isEdit ? '维护员工的基础信息、组织关系和账号状态。' : '录入员工信息并建立部门、岗位和直属上级关系。',
              onClose: () => Navigator.pop(context, false),
              maxWidth: 560,
              footerActions: [
                OutlinedButton(
                  onPressed:
                      saving ? null : () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : submit,
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? '保存修改' : '创建员工'),
                ),
              ],
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('基本信息'),
                    _buildField(
                      TextFormField(
                        controller: empNoController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: '工号'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入工号'
                                : null,
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '姓名'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入姓名'
                                : null,
                      ),
                    ),
                    _buildField(
                      AppSelectField<String>(
                        value: gender,
                        labelText: '性别',
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('男')),
                          DropdownMenuItem(value: 'female', child: Text('女')),
                        ],
                        onChanged: (value) =>
                            setModalState(() => gender = value ?? 'male'),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: '手机号'),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: '邮箱'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('组织关系'),
                    _buildField(
                      AppSelectField<int>(
                        value: deptId,
                        labelText: '部门',
                        items: listState.departmentOptions
                            .map(
                              (item) => DropdownMenuItem(
                                value: int.parse(item.value),
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setModalState(() => deptId = value),
                      ),
                    ),
                    _buildField(
                      AppSelectField<int>(
                        value: positionId,
                        labelText: '岗位',
                        items: listState.positionOptions
                            .map(
                              (item) => DropdownMenuItem(
                                value: int.parse(item.value),
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setModalState(() => positionId = value),
                      ),
                    ),
                    _buildField(
                      AppSelectField<int>(
                        value: leaderId,
                        labelText: '直属上级',
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('不设置'),
                          ),
                          ...listState.leaderOptions.map(
                            (item) => DropdownMenuItem(
                              value: int.parse(item.value),
                              child: Text(item.label),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setModalState(() => leaderId = value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('状态与补充信息'),
                    _buildField(
                      AppSelectField<String>(
                        value: status,
                        labelText: '状态',
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('在职')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('停用')),
                          DropdownMenuItem(value: 'left', child: Text('离职')),
                        ],
                        onChanged: (value) =>
                            setModalState(() => status = value ?? 'active'),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: hireDateController,
                        decoration: const InputDecoration(labelText: '入职日期'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入入职日期'
                                : null,
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: birthDateController,
                        decoration: const InputDecoration(labelText: '出生日期'),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: leftAtController,
                        decoration: const InputDecoration(labelText: '离职日期'),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: '联系地址'),
                      ),
                    ),
                    TextFormField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '备注'),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          formError!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    empNoController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    hireDateController.dispose();
    birthDateController.dispose();
    leftAtController.dispose();
    addressController.dispose();
    remarkController.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission(PermissionCodes.empAdd);
    final listController = ref.watch(employeeListControllerProvider);
    final listState = listController.state;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.compactDesktop;
        final cardsPerRow = compact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((cardsPerRow - 1) * 16)) / cardsPerRow;
        final activeCount = listState.employees
            .where((employee) => employee.status == 'active')
            .length;
        final departmentCount = listState.employees
            .map((employee) => employee.deptName)
            .toSet()
            .length;
        final positionCount = listState.employees
            .map((employee) => employee.positionName)
            .toSet()
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: '员工管理',
                subtitle: '统一维护员工基础信息、组织关系和状态，保持组织数据持续可追溯。',
                actions: [
                  PermissionWidget(
                    allowed: canAdd,
                    showDisabledState: true,
                    deniedTooltip: '当前账号没有此操作权限',
                    child: ElevatedButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('新建员工'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.groups_rounded,
                      color: AppColors.brandBlue,
                      label: '检索结果总数',
                      value: '${listState.total}',
                      description: '当前筛选条件下的员工总量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.badge_rounded,
                      color: AppColors.success,
                      label: '当前页在职',
                      value: '$activeCount',
                      description: '便于快速判断当前页人员状态。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.account_tree_rounded,
                      color: AppColors.warning,
                      label: '涉及部门',
                      value: '$departmentCount',
                      description: '当前结果中出现的部门数量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.danger,
                      label: '涉及岗位',
                      value: '$positionCount',
                      description: '当前结果中出现的岗位数量。',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '筛选条件',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '支持按姓名、部门和状态快速过滤员工列表。',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: compact ? constraints.maxWidth : 260,
                          child: AppSearchField(
                            controller: _keywordController,
                            hintText: '搜索姓名、工号',
                            onSubmitted: () =>
                                listController.search(_keywordController.text),
                          ),
                        ),
                        SizedBox(
                          width: compact ? constraints.maxWidth : 220,
                          child: AppSelectField<int>(
                            value: listState.selectedDeptId,
                            labelText: '部门',
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('全部部门'),
                              ),
                              ...listState.departmentOptions.map(
                                (item) => DropdownMenuItem(
                                  value: int.parse(item.value),
                                  child: Text(item.label),
                                ),
                              ),
                            ],
                            onChanged: listController.setDepartmentFilter,
                          ),
                        ),
                        SizedBox(
                          width: compact ? constraints.maxWidth : 220,
                          child: AppSelectField<String>(
                            value: listState.selectedStatus,
                            labelText: '状态',
                            items: const [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('全部状态'),
                              ),
                              DropdownMenuItem(
                                  value: 'active', child: Text('在职')),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('停用'),
                              ),
                              DropdownMenuItem(
                                  value: 'left', child: Text('离职')),
                            ],
                            onChanged: listController.setStatusFilter,
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton(
                              onPressed: () => listController
                                  .search(_keywordController.text),
                              child: const Text('查询'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                _keywordController.clear();
                                await listController.reset();
                              },
                              child: const Text('重置'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTableSection(
                title: '员工列表',
                subtitle: listState.loading
                    ? '正在加载员工数据。'
                    : '共 ${listState.total} 名员工，支持编辑和删除操作。',
                footer: listState.loading ||
                        listState.errorMessage != null ||
                        listState.employees.isEmpty
                    ? null
                    : AppPaginationBar(
                        page: listState.query.page,
                        pageSize: listState.query.pageSize,
                        total: listState.total,
                        onPageChanged: listController.changePage,
                      ),
                child: _buildBody(listState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(EmployeeListState listState) {
    final canEdit = appAuthController.hasPermission(PermissionCodes.empEdit);
    final canDelete =
        appAuthController.hasPermission(PermissionCodes.empDelete);

    if (listState.loading) {
      return const AppTableLoadingSkeleton(rows: 6, columns: 8);
    }

    if (listState.errorMessage != null) {
      return AppErrorState(
        message: listState.errorMessage!,
        onRetry: ref.read(employeeListControllerProvider).load,
      );
    }

    if (listState.employees.isEmpty) {
      return AppEmptyState(
        title: '暂无数据',
        message: '当前没有符合条件的员工记录，试试调整筛选条件。',
        action: OutlinedButton(
          onPressed: () async {
            _keywordController.clear();
            await ref.read(employeeListControllerProvider).reset();
          },
          child: const Text('清空筛选'),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.bgGray.withValues(alpha: 0.7),
        ),
        columns: const [
          DataColumn(label: Text('工号')),
          DataColumn(label: Text('姓名')),
          DataColumn(label: Text('部门')),
          DataColumn(label: Text('岗位')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('入职日期')),
          DataColumn(label: Text('直属上级')),
          DataColumn(label: Text('操作')),
        ],
        rows: listState.employees
            .map(
              (employee) => DataRow(
                cells: [
                  DataCell(Text(employee.empNo)),
                  DataCell(Text(employee.name)),
                  DataCell(Text(employee.deptName)),
                  DataCell(Text(employee.positionName)),
                  DataCell(_buildStatus(employee.status)),
                  DataCell(Text(employee.hireDate)),
                  DataCell(Text(employee.leaderName ?? '-')),
                  DataCell(
                    SizedBox(
                      width: 92,
                      child: Row(
                        children: [
                          PermissionWidget(
                            allowed: canEdit,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.edit_outlined,
                              tooltip: '编辑员工',
                              onPressed: () => _openEdit(employee),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canDelete,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: '删除员工',
                              color: AppColors.danger,
                              onPressed: () => _deleteEmployee(employee),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatus(String status) {
    switch (status) {
      case 'active':
        return const AppStatusPill(label: '在职', color: AppColors.success);
      case 'inactive':
        return const AppStatusPill(label: '停用', color: AppColors.warning);
      case 'left':
        return const AppStatusPill(label: '离职', color: AppColors.danger);
      default:
        return const AppStatusPill(label: '未知', color: AppColors.textHint);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildField(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}
