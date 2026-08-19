import 'package:flutter/material.dart';
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
import 'package:my_second_app/features/department/data/models/department_form_data.dart';
import 'package:my_second_app/features/department/data/models/department_model.dart';
import 'package:my_second_app/features/department/data/models/department_query.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/shared/models/option_item.dart';
import 'package:my_second_app/shared/repositories/department_repository.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';

class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({super.key});

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  late final DepartmentRepository _departmentRepository;
  late final EmployeeRepository _employeeRepository;
  final TextEditingController _keywordController = TextEditingController();

  DepartmentQuery _query = const DepartmentQuery();
  List<DepartmentModel> _departments = const [];
  List<OptionItem> _departmentOptions = const [];
  List<OptionItem> _leaderOptions = const [];

  bool _loading = true;
  String? _errorMessage;
  int _total = 0;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final dio = appAuthController.dio;
    _departmentRepository = DepartmentRepository(dio);
    _employeeRepository = EmployeeRepository(dio);
    _bootstrap();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadAuxiliaryOptions(), _fetchDepartments()]);
  }

  Future<void> _loadAuxiliaryOptions() async {
    try {
      final departmentOptions = await _departmentRepository.fetchOptions();
      final employees = await _employeeRepository.fetchEmployees(
        const EmployeeQuery(page: 1, pageSize: 100),
      );
      if (!mounted) return;
      setState(() {
        _departmentOptions = departmentOptions;
        _leaderOptions = employees.items
            .map((item) =>
                OptionItem(label: item.name, value: item.id.toString()))
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await _departmentRepository.fetchDepartments(_query);
      if (!mounted) return;
      setState(() {
        _departments = result.items;
        _total = result.total;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = '部门数据加载失败，请稍后重试。';
      });
    }
  }

  Future<void> _onSearch() async {
    _query = _query.copyWith(
      page: 1,
      keyword: _keywordController.text.trim(),
      status: _selectedStatus,
    );
    await _fetchDepartments();
  }

  Future<void> _resetFilters() async {
    _keywordController.clear();
    setState(() {
      _selectedStatus = null;
      _query = const DepartmentQuery();
    });
    await _fetchDepartments();
  }

  Future<void> _changePage(int page) async {
    if (page < 1) return;
    final maxPage = (_total / _query.pageSize).ceil();
    if (maxPage > 0 && page > maxPage) return;
    _query = _query.copyWith(page: page);
    await _fetchDepartments();
  }

  Future<void> _openCreate() async {
    final saved = await _showDepartmentForm();
    if (saved == true) {
      await _loadAuxiliaryOptions();
      await _fetchDepartments();
    }
  }

  Future<void> _openEdit(DepartmentModel department) async {
    final saved = await _showDepartmentForm(departmentId: department.id);
    if (saved == true) {
      await _loadAuxiliaryOptions();
      await _fetchDepartments();
    }
  }

  Future<void> _deleteDepartment(DepartmentModel department) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '确认删除',
      message: '确定要删除部门“${department.deptName}”吗？',
      confirmText: '删除',
    );
    if (!confirmed) return;
    try {
      await _departmentRepository.deleteDepartment(department.id);
      if (!mounted) return;
      showAppSuccess(context, '部门删除成功');
      await _loadAuxiliaryOptions();
      await _fetchDepartments();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppError(context, error.message);
    }
  }

  Future<bool?> _showDepartmentForm({int? departmentId}) async {
    final isEdit = departmentId != null;
    Map<String, dynamic>? detail;
    if (isEdit) {
      try {
        detail =
            await _departmentRepository.fetchDepartmentDetail(departmentId);
      } on ApiException catch (error) {
        if (!mounted) return false;
        showAppError(context, error.message);
        return false;
      }
    }
    if (!mounted) return false;

    final formKey = GlobalKey<FormState>();
    final codeController =
        TextEditingController(text: detail?['dept_code'] as String? ?? '');
    final nameController =
        TextEditingController(text: detail?['dept_name'] as String? ?? '');
    final sortOrderController =
        TextEditingController(text: '${detail?['sort_order'] ?? 0}');
    final remarkController =
        TextEditingController(text: detail?['remark'] as String? ?? '');

    int? parentId = detail?['parent_id'] as int?;
    int? leaderEmployeeId = detail?['leader_employee_id'] as int?;
    int status = detail?['status'] as int? ?? 1;
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'department_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              final payload = DepartmentFormData(
                deptCode: codeController.text.trim(),
                deptName: nameController.text.trim(),
                parentId: parentId,
                leaderEmployeeId: leaderEmployeeId,
                sortOrder: int.tryParse(sortOrderController.text.trim()) ?? 0,
                status: status,
                remark: remarkController.text.trim().isEmpty
                    ? null
                    : remarkController.text.trim(),
              );
              setModalState(() {
                saving = true;
                formError = null;
              });
              try {
                if (isEdit) {
                  final data = payload.toJson()..remove('dept_code');
                  await _departmentRepository.updateDepartment(
                      departmentId, data);
                } else {
                  await _departmentRepository.createDepartment(payload);
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
                  formError = isEdit ? '部门更新失败，请稍后重试。' : '部门创建失败，请稍后重试。';
                });
              }
            }

            return AppDrawerForm(
              title: isEdit ? '编辑部门' : '新建部门',
              subtitle: isEdit ? '调整部门名称、层级关系和负责人设置。' : '建立新的部门节点，并完善负责人和排序信息。',
              onClose: () => Navigator.pop(context, false),
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
                      : Text(isEdit ? '保存修改' : '创建部门'),
                ),
              ],
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('基础信息'),
                    _buildField(
                      TextFormField(
                        controller: codeController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: '部门编码'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入部门编码'
                                : null,
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '部门名称'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入部门名称'
                                : null,
                      ),
                    ),
                    _buildField(
                      AppSelectField<int>(
                        value: parentId,
                        labelText: '上级部门',
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('作为顶级部门'),
                          ),
                          ..._departmentOptions
                              .where(
                                (item) =>
                                    !isEdit ||
                                    int.parse(item.value) != departmentId,
                              )
                              .map(
                                (item) => DropdownMenuItem(
                                  value: int.parse(item.value),
                                  child: Text(item.label),
                                ),
                              ),
                        ],
                        onChanged: (value) =>
                            setModalState(() => parentId = value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSectionTitle('组织配置'),
                    _buildField(
                      AppSelectField<int>(
                        value: leaderEmployeeId,
                        labelText: '部门负责人',
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('暂不设置'),
                          ),
                          ..._leaderOptions.map(
                            (item) => DropdownMenuItem(
                              value: int.parse(item.value),
                              child: Text(item.label),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setModalState(() => leaderEmployeeId = value),
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: sortOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '排序值'),
                      ),
                    ),
                    _buildField(
                      AppSelectField<int>(
                        value: status,
                        labelText: '状态',
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('启用')),
                          DropdownMenuItem(value: 0, child: Text('停用')),
                        ],
                        onChanged: (value) =>
                            setModalState(() => status = value ?? 1),
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

    codeController.dispose();
    nameController.dispose();
    sortOrderController.dispose();
    remarkController.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission(PermissionCodes.deptAdd);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.compactDesktop;
        final cardsPerRow = compact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((cardsPerRow - 1) * 16)) / cardsPerRow;
        final activeCount =
            _departments.where((department) => department.status == 1).length;
        final leaderCount = _departments
            .where((department) => department.leaderEmployeeId != null)
            .length;
        final rootCount = _departments
            .where((department) => department.parentId == null)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: '部门管理',
                subtitle: '维护企业部门树、层级关系和负责人配置，让组织结构始终保持清晰。',
                actions: [
                  PermissionWidget(
                    allowed: canAdd,
                    showDisabledState: true,
                    deniedTooltip: '???????',
                    child: ElevatedButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.add_business_rounded),
                      label: const Text('??????'),
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
                      icon: Icons.account_tree_rounded,
                      color: AppColors.brandBlue,
                      label: '部门总数',
                      value: '$_total',
                      description: '当前筛选结果中的部门总量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      label: '当前页启用',
                      value: '$activeCount',
                      description: '便于快速核对当前页面启用状态。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.person_pin_circle_outlined,
                      color: AppColors.warning,
                      label: '已配负责人',
                      value: '$leaderCount',
                      description: '当前结果中已明确负责人配置的部门数。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.apartment_rounded,
                      color: AppColors.danger,
                      label: '顶级部门',
                      value: '$rootCount',
                      description: '组织结构中位于顶层的部门节点数量。',
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
                      '支持按名称、编码和状态快速定位部门记录。',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: compact ? constraints.maxWidth : 280,
                          child: AppSearchField(
                            controller: _keywordController,
                            hintText: '搜索部门名称或编码',
                            onSubmitted: _onSearch,
                          ),
                        ),
                        SizedBox(
                          width: compact ? constraints.maxWidth : 220,
                          child: AppSelectField<int>(
                            value: _selectedStatus,
                            labelText: '状态',
                            items: const [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('全部状态'),
                              ),
                              DropdownMenuItem(value: 1, child: Text('启用')),
                              DropdownMenuItem(value: 0, child: Text('停用')),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedStatus = value),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton(
                              onPressed: _onSearch,
                              child: const Text('查询'),
                            ),
                            OutlinedButton(
                              onPressed: _resetFilters,
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
                title: '部门列表',
                subtitle:
                    _loading ? '正在加载部门数据。' : '共 $_total 个部门，支持维护负责人、层级和状态。',
                footer:
                    _loading || _errorMessage != null || _departments.isEmpty
                        ? null
                        : AppPaginationBar(
                            page: _query.page,
                            pageSize: _query.pageSize,
                            total: _total,
                            onPageChanged: _changePage,
                          ),
                child: _buildBody(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final canEdit = appAuthController.hasPermission(PermissionCodes.deptEdit);
    final canDelete =
        appAuthController.hasPermission(PermissionCodes.deptDelete);

    if (_loading) {
      return const AppTableLoadingSkeleton(rows: 6, columns: 6);
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: _errorMessage!,
        onRetry: _fetchDepartments,
      );
    }

    if (_departments.isEmpty) {
      return AppEmptyState(
        title: '??????',
        message: '????????????????????????????',
        action: OutlinedButton(
          onPressed: _resetFilters,
          child: const Text('????'),
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
          DataColumn(label: Text('编码')),
          DataColumn(label: Text('部门名称')),
          DataColumn(label: Text('上级部门')),
          DataColumn(label: Text('负责人')),
          DataColumn(label: Text('层级')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('排序')),
          DataColumn(label: Text('操作')),
        ],
        rows: _departments
            .map(
              (department) => DataRow(
                cells: [
                  DataCell(Text(department.deptCode)),
                  DataCell(Text(department.deptName)),
                  DataCell(Text(department.parentName ?? '-')),
                  DataCell(Text(department.leaderName ?? '-')),
                  DataCell(Text('L${department.level}')),
                  DataCell(_buildStatus(department.status)),
                  DataCell(Text('${department.sortOrder}')),
                  DataCell(
                    SizedBox(
                      width: 92,
                      child: Row(
                        children: [
                          PermissionWidget(
                            allowed: canEdit,
                            showDisabledState: true,
                            deniedTooltip: '???????',
                            child: AppIconActionButton(
                              icon: Icons.edit_outlined,
                              tooltip: '??????',
                              onPressed: () => _openEdit(department),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canDelete,
                            showDisabledState: true,
                            deniedTooltip: '???????',
                            child: AppIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: '??????',
                              color: AppColors.danger,
                              onPressed: () => _deleteDepartment(department),
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

  Widget _buildStatus(int status) {
    if (status == 1) {
      return const AppStatusPill(label: '启用', color: AppColors.success);
    }
    return const AppStatusPill(label: '停用', color: AppColors.warning);
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
