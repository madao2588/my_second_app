import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/employee/data/models/employee_query.dart';
import 'package:my_second_app/features/role/data/models/role_query.dart';
import 'package:my_second_app/features/user/data/models/user_form_data.dart';
import 'package:my_second_app/features/user/data/models/user_query.dart';
import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/models/user_model.dart';
import 'package:my_second_app/shared/repositories/employee_repository.dart';
import 'package:my_second_app/shared/repositories/role_repository.dart';
import 'package:my_second_app/shared/repositories/user_repository.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _keywordController = TextEditingController();
  late final UserRepository _usersApi;
  late final RoleRepository _rolesApi;
  late final EmployeeRepository _employeesApi;

  UserQuery _query = const UserQuery();
  List<UserModel> _items = const [];
  List<RoleModel> _roles = const [];
  List<Map<String, dynamic>> _employees = const [];
  bool _loading = true;
  String? _error;
  int _total = 0;
  int? _status;

  @override
  void initState() {
    super.initState();
    final dio = appAuthController.dio;
    _usersApi = UserRepository(dio);
    _rolesApi = RoleRepository(dio);
    _employeesApi = EmployeeRepository(dio);
    _init();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.wait([_loadOptions(), _load()]);
  }

  Future<void> _loadOptions() async {
    try {
      final roles =
          await _rolesApi.fetchRoles(const RoleQuery(page: 1, pageSize: 100));
      final employees = await _employeesApi
          .fetchEmployees(const EmployeeQuery(page: 1, pageSize: 100));
      if (!mounted) return;
      setState(() {
        _roles = roles.items;
        _employees = employees.items
            .map((employee) => {'id': employee.id, 'name': employee.name})
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _usersApi.fetchUsers(_query);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _total = result.total;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '用户数据加载失败';
      });
    }
  }

  Future<void> _search() async {
    _query = _query.copyWith(
      page: 1,
      keyword: _keywordController.text.trim(),
      status: _status,
    );
    await _load();
  }

  Future<void> _reset() async {
    _keywordController.clear();
    setState(() {
      _status = null;
      _query = const UserQuery();
    });
    await _load();
  }

  Future<void> _changePage(int page) async {
    final maxPage = (_total / _query.pageSize).ceil();
    if (page < 1 || (maxPage > 0 && page > maxPage)) return;
    _query = _query.copyWith(page: page);
    await _load();
  }

  Future<void> _openForm([UserModel? user]) async {
    final isEdit = user != null;
    Map<String, dynamic>? detail;
    if (isEdit) {
      detail = await _usersApi.fetchUserDetail(user.id);
    }
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final usernameController =
        TextEditingController(text: detail?['username'] as String? ?? '');
    final passwordController = TextEditingController();
    final realNameController =
        TextEditingController(text: detail?['real_name'] as String? ?? '');
    final phoneController =
        TextEditingController(text: detail?['phone'] as String? ?? '');
    final emailController =
        TextEditingController(text: detail?['email'] as String? ?? '');
    int? employeeId = detail?['employee_id'] as int?;
    int status = detail?['status'] as int? ?? 1;
    bool saving = false;
    String? formError;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final media = MediaQuery.of(context).size;
          final dialogWidth = media.width < 520 ? media.width * 0.92 : 420.0;
          final dialogHeight = media.height < 720 ? media.height * 0.88 : 680.0;

          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            final payload = UserFormData(
              username: usernameController.text.trim(),
              password: isEdit
                  ? (passwordController.text.trim().isEmpty
                      ? null
                      : passwordController.text.trim())
                  : passwordController.text.trim(),
              realName: realNameController.text.trim(),
              phone: phoneController.text.trim().isEmpty
                  ? null
                  : phoneController.text.trim(),
              email: emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              employeeId: employeeId,
              status: status,
            );

            setModalState(() {
              saving = true;
              formError = null;
            });
            try {
              if (isEdit) {
                final data = payload.toJson()
                  ..remove('username')
                  ..remove('password');
                await _usersApi.updateUser(user.id, data);
              } else {
                await _usersApi.createUser(payload);
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

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: media.width < 480 ? 12 : 24,
              vertical: media.height < 640 ? 12 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? '编辑用户' : '新建用户',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEdit ? '维护账号信息、绑定员工与启用状态。' : '创建新的系统账号，并绑定到员工档案。',
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _field(
                                TextFormField(
                                  controller: usernameController,
                                  enabled: !isEdit,
                                  decoration:
                                      const InputDecoration(labelText: '登录账号'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入登录账号';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _field(
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: isEdit ? '重置密码（留空则不修改）' : '登录密码',
                                  ),
                                  validator: (value) {
                                    if (!isEdit &&
                                        (value == null ||
                                            value.trim().length < 6)) {
                                      return '密码至少 6 位';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _field(
                                TextFormField(
                                  controller: realNameController,
                                  decoration:
                                      const InputDecoration(labelText: '姓名'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入姓名';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _field(
                                DropdownButtonFormField<int?>(
                                  initialValue: employeeId,
                                  decoration:
                                      const InputDecoration(labelText: '绑定员工'),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('暂不绑定'),
                                    ),
                                    ..._employees.map(
                                      (employee) => DropdownMenuItem<int?>(
                                        value: employee['id'] as int,
                                        child: Text(employee['name'] as String),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setModalState(() => employeeId = value),
                                ),
                              ),
                              _field(
                                TextFormField(
                                  controller: phoneController,
                                  decoration:
                                      const InputDecoration(labelText: '手机号'),
                                ),
                              ),
                              _field(
                                TextFormField(
                                  controller: emailController,
                                  decoration:
                                      const InputDecoration(labelText: '邮箱'),
                                ),
                              ),
                              DropdownButtonFormField<int>(
                                initialValue: status,
                                decoration:
                                    const InputDecoration(labelText: '状态'),
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('启用')),
                                  DropdownMenuItem(value: 0, child: Text('禁用')),
                                ],
                                onChanged: (value) =>
                                    setModalState(() => status = value ?? 1),
                              ),
                              if (formError != null) ...[
                                const SizedBox(height: 14),
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
                    const SizedBox(height: 20),
                    Row(
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
                                : Text(isEdit ? '保存' : '创建'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    usernameController.dispose();
    passwordController.dispose();
    realNameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    if (ok == true) {
      await _load();
      if (user != null && appAuthController.state.user?.id == user.id) {
        await appAuthController.refreshCurrentUser();
      }
    }
  }

  Future<void> _assignRoles(UserModel user) async {
    final detail = await _usersApi.fetchUserDetail(user.id);
    if (!mounted) return;

    final selected = ((detail['role_ids'] as List<dynamic>? ?? const []))
        .cast<int>()
        .toSet();
    bool saving = false;
    String? error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final media = MediaQuery.of(context).size;
          final dialogWidth = media.width < 560 ? media.width * 0.92 : 440.0;
          final dialogHeight = media.height < 720 ? media.height * 0.88 : 620.0;

          Future<void> submit() async {
            setModalState(() {
              saving = true;
              error = null;
            });
            try {
              await _usersApi.assignRoles(user.id, selected.toList()..sort());
              if (!context.mounted) return;
              Navigator.pop(context, true);
            } on ApiException catch (exception) {
              setModalState(() {
                saving = false;
                error = exception.message;
              });
            }
          }

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: media.width < 480 ? 12 : 24,
              vertical: media.height < 640 ? 12 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
                maxHeight: dialogHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '分配角色 · ${user.realName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '勾选该账号可用的角色，保存后即时生效。',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _roles.isEmpty
                          ? const Center(
                              child: Text(
                                '当前还没有可分配的角色',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: _roles
                                    .map(
                                      (role) => CheckboxListTile(
                                        value: selected.contains(role.id),
                                        title: Text(role.roleName),
                                        subtitle: Text(role.roleCode),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (value) {
                                          setModalState(() {
                                            if (value == true) {
                                              selected.add(role.id);
                                            } else {
                                              selected.remove(role.id);
                                            }
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
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
                                : const Text('保存'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (ok == true) {
      await _load();
      if (appAuthController.state.user?.id == user.id) {
        await appAuthController.refreshCurrentUser();
      }
    }
  }

  Future<void> _delete(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除账号“${user.username}”吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _usersApi.deleteUser(user.id);
      if (!mounted) return;
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission(PermissionCodes.userAdd);
    final canEdit = appAuthController.hasPermission(PermissionCodes.userEdit);
    final canDelete =
        appAuthController.hasPermission(PermissionCodes.userDelete);
    final canAssign =
        appAuthController.hasPermission(PermissionCodes.userAssignRole);
    final pageCount = _total == 0 ? 1 : (_total / _query.pageSize).ceil();

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
              Text(
                '共 $_total 个账号',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? const _UserEmptyState()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 24,
                                headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('账号')),
                                  DataColumn(label: Text('姓名')),
                                  DataColumn(label: Text('绑定员工')),
                                  DataColumn(label: Text('角色')),
                                  DataColumn(label: Text('状态')),
                                  DataColumn(label: Text('最后登录')),
                                  DataColumn(label: Text('操作')),
                                ],
                                rows: _items
                                    .map(
                                      (user) => DataRow(
                                        cells: [
                                          DataCell(Text(user.username)),
                                          DataCell(Text(user.realName)),
                                          DataCell(
                                              Text(user.employeeName ?? '-')),
                                          DataCell(
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                user.roleNames.isEmpty
                                                    ? '-'
                                                    : user.roleNames
                                                        .join(' / '),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(_StatusPill(
                                              enabled: user.status == 1)),
                                          DataCell(Text(
                                              _formatTime(user.lastLoginAt))),
                                          DataCell(
                                            Wrap(
                                              spacing: 4,
                                              children: [
                                                if (canEdit)
                                                  IconButton(
                                                    tooltip: '编辑',
                                                    onPressed: () =>
                                                        _openForm(user),
                                                    icon: const Icon(
                                                        Icons.edit_outlined),
                                                  ),
                                                if (canAssign)
                                                  IconButton(
                                                    tooltip: '分配角色',
                                                    onPressed: () =>
                                                        _assignRoles(user),
                                                    icon: const Icon(
                                                      Icons
                                                          .manage_accounts_outlined,
                                                    ),
                                                  ),
                                                if (canDelete)
                                                  IconButton(
                                                    tooltip: '删除',
                                                    onPressed: () =>
                                                        _delete(user),
                                                    icon: const Icon(
                                                        Icons.delete_outline),
                                                  ),
                                              ],
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
                    '第 ${_query.page} / $pageCount 页',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: _query.page > 1
                            ? () => _changePage(_query.page - 1)
                            : null,
                        child: const Text('上一页'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _query.page < pageCount
                            ? () => _changePage(_query.page + 1)
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
                      '用户管理',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '维护系统账号、绑定员工关系与角色分配。当前共有 $_total 个账号。',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              if (canAdd)
                ElevatedButton.icon(
                  onPressed: _openForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建用户'),
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
                child: _UserStatCard(
                  title: '账号总数',
                  value: '$_total',
                  color: AppColors.brandBlue,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _UserStatCard(
                  title: '启用',
                  value: '${_items.where((item) => item.status == 1).length}',
                  color: AppColors.success,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _UserStatCard(
                  title: '禁用',
                  value: '${_items.where((item) => item.status == 0).length}',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _UserStatCard(
                  title: '已绑定员工',
                  value:
                      '${_items.where((item) => item.employeeId != null).length}',
                  color: AppColors.textPrimary,
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
                            const InputDecoration(labelText: '账号 / 姓名 / 手机号'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: '状态'),
                        items: const [
                          DropdownMenuItem<int?>(
                              value: null, child: Text('全部状态')),
                          DropdownMenuItem<int?>(value: 1, child: Text('启用')),
                          DropdownMenuItem<int?>(value: 0, child: Text('禁用')),
                        ],
                        onChanged: (value) => setState(() => _status = value),
                      ),
                    ),
                    ElevatedButton(onPressed: _search, child: const Text('查询')),
                    OutlinedButton(onPressed: _reset, child: const Text('重置')),
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

String _formatTime(String? value) {
  if (value == null || value.isEmpty) return '-';
  return value.replaceFirst('T', ' ').split('.').first;
}

class _UserStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _UserStatCard({
    required this.title,
    required this.value,
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
            child: Icon(Icons.manage_accounts_rounded, color: color),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool enabled;

  const _StatusPill({required this.enabled});

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        enabled ? '启用' : '禁用',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UserEmptyState extends StatelessWidget {
  const _UserEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_accounts_outlined,
              size: 40, color: AppColors.textHint),
          SizedBox(height: 14),
          Text(
            '没有找到符合条件的用户记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '你可以调整筛选条件，或新建一个账号。',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
