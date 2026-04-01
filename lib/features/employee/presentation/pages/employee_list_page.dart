import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/employee/data/models/employee_form_data.dart';
import 'package:my_second_app/features/employee/data/models/employee_model.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/shared/models/option_item.dart';
import 'package:my_second_app/shared/repositories/department_repository.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';
import 'package:my_second_app/shared/repositories/position_repository.dart';

class EmployeeListPage extends ConsumerStatefulWidget {
  const EmployeeListPage({super.key});

  @override
  ConsumerState<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends ConsumerState<EmployeeListPage> {
  late final EmployeeRepository _employeeRepository;
  late final DepartmentRepository _departmentRepository;
  late final PositionRepository _positionRepository;
  final TextEditingController _keywordController = TextEditingController();

  EmployeeQuery _query = const EmployeeQuery();
  List<EmployeeModel> _employees = const [];
  List<OptionItem> _departmentOptions = const [];
  List<OptionItem> _positionOptions = const [];
  bool _loading = true;
  String? _errorMessage;
  int _total = 0;
  int? _selectedDeptId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final dio = appAuthController.dio;
    _employeeRepository = EmployeeRepository(dio);
    _departmentRepository = DepartmentRepository(dio);
    _positionRepository = PositionRepository(dio);
    _bootstrap();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadOptions(), _fetchEmployees()]);
  }

  Future<void> _loadOptions() async {
    try {
      final departments = await _departmentRepository.fetchOptions();
      final positions = await _positionRepository.fetchOptions();
      if (!mounted) return;
      setState(() {
        _departmentOptions = departments;
        _positionOptions = positions;
      });
    } catch (_) {}
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await _employeeRepository.fetchEmployees(_query);
      if (!mounted) return;
      setState(() {
        _employees = result.items;
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
        _errorMessage = '员工数据加载失败';
      });
    }
  }

  Future<void> _onSearch() async {
    _query = _query.copyWith(
      page: 1,
      keyword: _keywordController.text.trim(),
      deptId: _selectedDeptId,
      status: _selectedStatus,
    );
    await _fetchEmployees();
  }

  Future<void> _resetFilters() async {
    _keywordController.clear();
    setState(() {
      _selectedDeptId = null;
      _selectedStatus = null;
      _query = const EmployeeQuery();
    });
    await _fetchEmployees();
  }

  Future<void> _changePage(int page) async {
    if (page < 1) return;
    final maxPage = (_total / _query.pageSize).ceil();
    if (maxPage > 0 && page > maxPage) return;
    _query = _query.copyWith(page: page);
    await _fetchEmployees();
  }

  Future<void> _openCreate() async {
    final saved = await _showEmployeeForm();
    if (saved == true) {
      await _fetchEmployees();
    }
  }

  Future<void> _openEdit(EmployeeModel employee) async {
    final saved = await _showEmployeeForm(employeeId: employee.id);
    if (saved == true) {
      await _fetchEmployees();
    }
  }

  Future<void> _deleteEmployee(EmployeeModel employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除员工“${employee.name}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _employeeRepository.deleteEmployee(employee.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('员工删除成功')),
      );
      await _fetchEmployees();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<bool?> _showEmployeeForm({int? employeeId}) async {
    final isEdit = employeeId != null;
    Map<String, dynamic>? detail;
    if (isEdit) {
      try {
        detail = await _employeeRepository.fetchEmployeeDetail(employeeId);
      } on ApiException catch (error) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
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
      text: (detail?['hire_date'] as String?) ??
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
    final leaderOptions = _employees
        .map((employee) =>
            OptionItem(label: employee.name, value: employee.id.toString()))
        .toList();

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'employee_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              if (deptId == null || positionId == null) {
                setModalState(() => formError = '请选择部门和岗位');
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
                  final payload = formData.toJson()..remove('emp_no');
                  await _employeeRepository.updateEmployee(employeeId, payload);
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
              }
            }

            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 560
                      ? MediaQuery.of(context).size.width * 0.92
                      : 500,
                  child: SafeArea(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            isEdit ? '编辑员工' : '新建员工',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            isEdit ? '更新员工资料与组织关系。' : '录入员工基础信息与组织信息。',
                          ),
                          trailing: IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  _field(
                                    TextFormField(
                                      controller: empNoController,
                                      enabled: !isEdit,
                                      decoration: const InputDecoration(
                                          labelText: '工号'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? '请输入工号'
                                              : null,
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                          labelText: '姓名'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? '请输入姓名'
                                              : null,
                                    ),
                                  ),
                                  _field(
                                    DropdownButtonFormField<String>(
                                      initialValue: gender,
                                      decoration: const InputDecoration(
                                          labelText: '性别'),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'male', child: Text('男')),
                                        DropdownMenuItem(
                                            value: 'female', child: Text('女')),
                                      ],
                                      onChanged: (value) => setModalState(
                                          () => gender = value ?? 'male'),
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: phoneController,
                                      decoration: const InputDecoration(
                                          labelText: '手机号'),
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                          labelText: '邮箱'),
                                    ),
                                  ),
                                  _field(
                                    DropdownButtonFormField<int>(
                                      initialValue: deptId,
                                      decoration: const InputDecoration(
                                          labelText: '部门'),
                                      items: _departmentOptions
                                          .map(
                                            (item) => DropdownMenuItem<int>(
                                              value: int.parse(item.value),
                                              child: Text(item.label),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) =>
                                          setModalState(() => deptId = value),
                                    ),
                                  ),
                                  _field(
                                    DropdownButtonFormField<int>(
                                      initialValue: positionId,
                                      decoration: const InputDecoration(
                                          labelText: '岗位'),
                                      items: _positionOptions
                                          .map(
                                            (item) => DropdownMenuItem<int>(
                                              value: int.parse(item.value),
                                              child: Text(item.label),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) => setModalState(
                                          () => positionId = value),
                                    ),
                                  ),
                                  _field(
                                    DropdownButtonFormField<int?>(
                                      initialValue: leaderId,
                                      decoration: const InputDecoration(
                                          labelText: '直属上级'),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                            value: null, child: Text('无')),
                                        ...leaderOptions.map(
                                          (item) => DropdownMenuItem<int?>(
                                            value: int.parse(item.value),
                                            child: Text(item.label),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) =>
                                          setModalState(() => leaderId = value),
                                    ),
                                  ),
                                  _field(
                                    DropdownButtonFormField<String>(
                                      initialValue: status,
                                      decoration: const InputDecoration(
                                          labelText: '状态'),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'active', child: Text('在职')),
                                        DropdownMenuItem(
                                            value: 'inactive',
                                            child: Text('停用')),
                                        DropdownMenuItem(
                                            value: 'left', child: Text('离职')),
                                      ],
                                      onChanged: (value) => setModalState(
                                          () => status = value ?? 'active'),
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: hireDateController,
                                      decoration: const InputDecoration(
                                        labelText: '入职日期',
                                        hintText: 'YYYY-MM-DD',
                                      ),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? '请输入入职日期'
                                              : null,
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: leftAtController,
                                      decoration: const InputDecoration(
                                        labelText: '离职日期',
                                        hintText: 'YYYY-MM-DD',
                                      ),
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: birthDateController,
                                      decoration: const InputDecoration(
                                        labelText: '出生日期',
                                        hintText: 'YYYY-MM-DD',
                                      ),
                                    ),
                                  ),
                                  _field(
                                    TextFormField(
                                      controller: addressController,
                                      decoration: const InputDecoration(
                                          labelText: '地址'),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: remarkController,
                                    maxLines: 3,
                                    decoration:
                                        const InputDecoration(labelText: '备注'),
                                  ),
                                  if (formError != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(14),
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: saving
                                      ? null
                                      : () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
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
    final canAdd = appAuthController.hasPermission('emp:add');
    final canEdit = appAuthController.hasPermission('emp:edit');
    final canDelete = appAuthController.hasPermission('emp:delete');
    final currentPage = _query.page;
    final totalPages = _total == 0 ? 1 : (_total / _query.pageSize).ceil();

    Widget card(Widget child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
          ),
          child: child,
        );

    Widget tablePanel() => card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '员工列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _employees.isEmpty
                        ? const _EmployeeEmptyState()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 28,
                                headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF8FAFC)),
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
                                rows: _employees
                                    .map(
                                      (employee) => DataRow(
                                        cells: [
                                          DataCell(Text(employee.empNo)),
                                          DataCell(Text(employee.name)),
                                          DataCell(Text(employee.deptName)),
                                          DataCell(Text(employee.positionName)),
                                          DataCell(_StatusTag(
                                              status: employee.status)),
                                          DataCell(Text(employee.hireDate
                                              .split('T')
                                              .first)),
                                          DataCell(
                                              Text(employee.leaderName ?? '-')),
                                          DataCell(
                                            SizedBox(
                                              width: 88,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (canEdit)
                                                    _TableActionButton(
                                                      tooltip: 'Edit',
                                                      onPressed: () =>
                                                          _openEdit(employee),
                                                      icon: Icons.edit_outlined,
                                                    ),
                                                  if (canDelete)
                                                    _TableActionButton(
                                                      tooltip: 'Delete',
                                                      onPressed: () =>
                                                          _deleteEmployee(
                                                              employee),
                                                      icon:
                                                          Icons.delete_outline,
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
                            ),
                          ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '共 $_total 条记录',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: currentPage > 1
                            ? () => _changePage(currentPage - 1)
                            : null,
                        child: const Text('上一页'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$currentPage / $totalPages'),
                      ),
                      OutlinedButton(
                        onPressed: currentPage < totalPages
                            ? () => _changePage(currentPage + 1)
                            : null,
                        child: const Text('下一页'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 860 || constraints.maxWidth < 1180;
        final statCompact = constraints.maxWidth < 1120;
        final statWidth = constraints.maxWidth < 720
            ? constraints.maxWidth
            : statCompact
                ? (constraints.maxWidth - 16) / 2
                : (constraints.maxWidth - 48) / 4;

        final content = [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '员工管理',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '统一维护员工档案、组织关系和状态信息。当前共 $_total 条记录。',
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.7),
                    ),
                  ],
                ),
              ),
              if (canAdd)
                ElevatedButton.icon(
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建员工'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: statWidth,
                child: _EmployeeStatCard(
                  title: '总记录',
                  value: '$_total',
                  note: '当前查询结果',
                  color: AppColors.brandBlue,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _EmployeeStatCard(
                  title: '在职',
                  value:
                      '${_employees.where((item) => item.status == 'active').length}',
                  note: '可正常使用',
                  color: AppColors.success,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _EmployeeStatCard(
                  title: '停用',
                  value:
                      '${_employees.where((item) => item.status == 'inactive').length}',
                  note: '账号或状态停用',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _EmployeeStatCard(
                  title: '离职',
                  value:
                      '${_employees.where((item) => item.status == 'left').length}',
                  note: '已离开企业',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '条件筛选',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _keywordController,
                        decoration:
                            const InputDecoration(labelText: '姓名 / 工号 / 手机号'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedDeptId,
                        decoration: const InputDecoration(labelText: '部门'),
                        items: [
                          const DropdownMenuItem<int?>(
                              value: null, child: Text('全部部门')),
                          ..._departmentOptions.map(
                            (item) => DropdownMenuItem<int?>(
                              value: int.parse(item.value),
                              child: Text(item.label),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedDeptId = value),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(labelText: '状态'),
                        items: const [
                          DropdownMenuItem<String?>(
                              value: null, child: Text('全部状态')),
                          DropdownMenuItem<String?>(
                              value: 'active', child: Text('在职')),
                          DropdownMenuItem<String?>(
                              value: 'inactive', child: Text('停用')),
                          DropdownMenuItem<String?>(
                              value: 'left', child: Text('离职')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: _onSearch, child: const Text('查询')),
                    OutlinedButton(
                        onPressed: _resetFilters, child: const Text('重置')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ];

        if (compact) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...content,
                SizedBox(height: 560, child: tablePanel()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...content,
            Expanded(child: tablePanel()),
          ],
        );
      },
    );
  }
}

Widget _field(Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: child,
    );

class _EmployeeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;
  final Color color;

  const _EmployeeStatCard({
    required this.title,
    required this.value,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.people_alt_rounded, color: color),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(note,
              style: const TextStyle(color: AppColors.textHint, height: 1.5)),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('在职', AppColors.success),
      'inactive' => ('停用', AppColors.warning),
      'left' => ('离职', AppColors.danger),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmployeeEmptyState extends StatelessWidget {
  const _EmployeeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: AppColors.textHint),
          SizedBox(height: 14),
          Text(
            '没有找到符合条件的员工记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '你可以调整筛选条件，或新建一条员工档案。',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TableActionButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  const _TableActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      splashRadius: 18,
    );
  }
}
