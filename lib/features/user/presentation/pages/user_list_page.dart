import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/app_breakpoints.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/core/permissions/permission_widget.dart';
import 'package:my_second_app/core/network/api_result.dart';
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
import 'package:my_second_app/features/user/data/models/user_form_data.dart';
import 'package:my_second_app/features/user/presentation/providers/user_list_provider.dart';
import 'package:my_second_app/features/user/presentation/states/user_list_state.dart';
import 'package:my_second_app/shared/models/user_model.dart';
import 'package:my_second_app/shared/repositories/user_repository.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final TextEditingController _keywordController = TextEditingController();
  late final UserRepository _usersApi;

  @override
  void initState() {
    super.initState();
    _usersApi = UserRepository(appAuthController.dio);
    Future.microtask(_init);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await ref.read(userListControllerProvider).bootstrap();
  }

  Future<void> _load() async {
    await ref.read(userListControllerProvider).load();
  }

  Future<void> _search() async {
    await ref.read(userListControllerProvider).search(_keywordController.text);
  }

  Future<void> _reset() async {
    _keywordController.clear();
    await ref.read(userListControllerProvider).reset();
  }

  Future<void> _changePage(int page) async {
    await ref.read(userListControllerProvider).changePage(page);
  }

  Future<void> _showUserForm([UserModel? user]) async {
    final listState = ref.read(userListControllerProvider).state;
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

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'user_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  final data = payload.toJson()..remove('username');
                  if (passwordController.text.trim().isEmpty) {
                    data.remove('password');
                  }
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
              } catch (_) {
                setModalState(() {
                  saving = false;
                  formError = isEdit ? '用户更新失败，请稍后重试。' : '用户创建失败，请稍后重试。';
                });
              }
            }

            return AppDrawerForm(
              title: isEdit ? '编辑用户' : '新建用户',
              subtitle: isEdit ? '维护账号信息、绑定员工关系和启用状态。' : '创建新的系统账号，并绑定到员工档案。',
              onClose: () => Navigator.pop(context, false),
              maxWidth: 520,
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
                      : Text(isEdit ? '保存修改' : '创建用户'),
                ),
              ],
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('账号信息'),
                    _field(
                      TextFormField(
                        controller: usernameController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: '登录账号'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入登录账号'
                                : null,
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
                              (value == null || value.trim().length < 6)) {
                            return '密码至少 6 位';
                          }
                          return null;
                        },
                      ),
                    ),
                    _field(
                      TextFormField(
                        controller: realNameController,
                        decoration: const InputDecoration(labelText: '姓名'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入姓名'
                                : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sectionTitle('绑定与状态'),
                    _field(
                      AppSelectField<int>(
                        value: employeeId,
                        labelText: '绑定员工',
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('暂不绑定'),
                          ),
                          ...listState.employees.map(
                            (employee) => DropdownMenuItem<int>(
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
                        decoration: const InputDecoration(labelText: '手机号'),
                      ),
                    ),
                    _field(
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: '邮箱'),
                      ),
                    ),
                    _field(
                      AppSelectField<int>(
                        value: status,
                        labelText: '状态',
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('启用')),
                          DropdownMenuItem(value: 0, child: Text('禁用')),
                        ],
                        onChanged: (value) =>
                            setModalState(() => status = value ?? 1),
                      ),
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: 18),
                      _errorBox(formError!),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    usernameController.dispose();
    passwordController.dispose();
    realNameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    if (result == true) {
      await _load();
      if (user != null && appAuthController.state.user?.id == user.id) {
        await appAuthController.refreshCurrentUser();
      }
    }
  }

  Future<void> _showAssignRoles(UserModel user) async {
    final listState = ref.read(userListControllerProvider).state;
    final detail = await _usersApi.fetchUserDetail(user.id);
    if (!mounted) return;

    final selected = ((detail['role_ids'] as List<dynamic>? ?? const []))
        .cast<int>()
        .toSet();
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'assign_roles',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              setModalState(() {
                saving = true;
                formError = null;
              });
              try {
                await _usersApi.assignRoles(user.id, selected.toList()..sort());
                if (!context.mounted) return;
                Navigator.pop(context, true);
              } on ApiException catch (exception) {
                setModalState(() {
                  saving = false;
                  formError = exception.message;
                });
              }
            }

            return AppDrawerForm(
              title: '分配角色',
              subtitle: '为 ${user.realName} 配置可用角色，保存后立即生效。',
              onClose: () => Navigator.pop(context, false),
              maxWidth: 500,
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
                      : const Text('保存角色'),
                ),
              ],
              child: listState.roles.isEmpty
                  ? const AppEmptyState(
                      title: '暂无可分配角色',
                      message: '请先在角色权限中创建角色，再回来为用户分配。',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...listState.roles.map(
                          (role) => CheckboxListTile(
                            value: selected.contains(role.id),
                            title: Text(role.roleName),
                            subtitle: Text(role.roleCode),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (checked) {
                              setModalState(() {
                                if (checked == true) {
                                  selected.add(role.id);
                                } else {
                                  selected.remove(role.id);
                                }
                              });
                            },
                          ),
                        ),
                        if (formError != null) ...[
                          const SizedBox(height: 18),
                          _errorBox(formError!),
                        ],
                      ],
                    ),
            );
          },
        );
      },
    );

    if (result == true) {
      await _load();
      if (appAuthController.state.user?.id == user.id) {
        await appAuthController.refreshCurrentUser();
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: '确认删除',
      message: '确认要删除用户“${user.username}”吗？',
      confirmText: '删除',
    );
    if (!ok) return;

    try {
      await _usersApi.deleteUser(user.id);
      if (!mounted) return;
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppError(context, error.message);
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
    final listController = ref.watch(userListControllerProvider);
    final listState = listController.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.compactDesktop;
        final cardsPerRow = compact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((cardsPerRow - 1) * 16)) / cardsPerRow;
        final enabledCount =
            listState.items.where((item) => item.status == 1).length;
        final disabledCount =
            listState.items.where((item) => item.status == 0).length;
        final boundCount =
            listState.items.where((item) => item.employeeId != null).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: '用户管理',
                subtitle: '维护系统账号、绑定员工关系与角色分配，保证账号体系持续可控。',
                actions: [
                  if (canAdd)
                    ElevatedButton.icon(
                      onPressed: _showUserForm,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('新建用户'),
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
                      icon: Icons.manage_accounts_rounded,
                      color: AppColors.brandBlue,
                      label: '账号总数',
                      value: '${listState.total}',
                      description: '当前筛选结果中的用户账号总量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      label: '启用账号',
                      value: '$enabledCount',
                      description: '当前结果中处于启用状态的账号数量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.block_outlined,
                      color: AppColors.warning,
                      label: '禁用账号',
                      value: '$disabledCount',
                      description: '当前结果中被禁用的账号数量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.badge_outlined,
                      color: AppColors.danger,
                      label: '已绑定员工',
                      value: '$boundCount',
                      description: '已经绑定员工档案的账号数量。',
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
                      '支持按账号、姓名和状态快速过滤用户记录。',
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
                            hintText: '搜索账号、姓名或手机号',
                            onSubmitted: () => _search(),
                          ),
                        ),
                        SizedBox(
                          width: compact ? constraints.maxWidth : 220,
                          child: AppSelectField<int>(
                            value: listState.status,
                            labelText: '状态',
                            items: const [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('全部状态'),
                              ),
                              DropdownMenuItem(value: 1, child: Text('启用')),
                              DropdownMenuItem(value: 0, child: Text('禁用')),
                            ],
                            onChanged: listController.setStatusFilter,
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton(
                              onPressed: _search,
                              child: const Text('查询'),
                            ),
                            OutlinedButton(
                              onPressed: _reset,
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
                title: '用户列表',
                subtitle:
                    listState.loading ? '正在加载用户数据。' : '共 ${listState.total} 个账号，支持编辑、分配角色和删除操作。',
                footer: listState.loading || listState.errorMessage != null || listState.items.isEmpty
                    ? null
                    : AppPaginationBar(
                        page: listState.query.page,
                        pageSize: listState.query.pageSize,
                        total: listState.total,
                        onPageChanged: _changePage,
                      ),
                child: _buildTable(
                    listState: listState,
                    canEdit: canEdit,
                    canDelete: canDelete,
                    canAssign: canAssign),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable({
    required UserListState listState,
    required bool canEdit,
    required bool canDelete,
    required bool canAssign,
  }) {
    if (listState.loading) {
      return const AppTableLoadingSkeleton(rows: 6, columns: 7);
    }

    if (listState.errorMessage != null) {
      return AppErrorState(
        message: listState.errorMessage!,
        onRetry: _load,
      );
    }

    if (listState.items.isEmpty) {
      return AppEmptyState(
        title: '暂无数据',
        message: '当前没有符合条件的用户记录，试试调整筛选条件。',
        action: OutlinedButton(
          onPressed: _reset,
          child: const Text('清空筛选'),
        ),
      );
    }
    const operationWidth = 132.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.bgGray.withValues(alpha: 0.7),
        ),
        columns: const [
          DataColumn(label: Text('账号')),
          DataColumn(label: Text('姓名')),
          DataColumn(label: Text('绑定员工')),
          DataColumn(label: Text('角色')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('最后登录')),
          DataColumn(label: Text('操作')),
        ],
        rows: listState.items
            .map(
              (user) => DataRow(
                cells: [
                  DataCell(Text(user.username)),
                  DataCell(Text(user.realName)),
                  DataCell(Text(user.employeeName ?? '-')),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        user.roleNames.isEmpty
                            ? '-'
                            : user.roleNames.join(' / '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    AppStatusPill(
                      label: user.status == 1 ? '启用' : '禁用',
                      color: user.status == 1
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  DataCell(Text(_formatTime(user.lastLoginAt))),
                  DataCell(
                    SizedBox(
                      width: operationWidth < 44 ? 44 : operationWidth,
                      child: Row(
                        children: [
                          PermissionWidget(
                            allowed: canEdit,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.edit_outlined,
                              tooltip: '编辑用户',
                              onPressed: () => _showUserForm(user),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canAssign,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.manage_accounts_outlined,
                              tooltip: '分配角色',
                              onPressed: () => _showAssignRoles(user),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canDelete,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: '删除用户',
                              color: AppColors.danger,
                              onPressed: () => _deleteUser(user),
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

  Widget _sectionTitle(String title) {
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

  Widget _field(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    return value.replaceFirst('T', ' ').split('.').first;
  }
}
