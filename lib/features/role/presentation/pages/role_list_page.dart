import 'package:flutter/material.dart';
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
import 'package:my_second_app/features/role/data/models/role_form_data.dart';
import 'package:my_second_app/features/role/data/models/role_query.dart';
import 'package:my_second_app/shared/models/permission_model.dart';
import 'package:my_second_app/shared/models/role_model.dart';
import 'package:my_second_app/shared/repositories/role_repository.dart';

class RoleListPage extends StatefulWidget {
  const RoleListPage({super.key});

  @override
  State<RoleListPage> createState() => _RoleListPageState();
}

class _RoleListPageState extends State<RoleListPage> {
  final TextEditingController _keywordController = TextEditingController();
  late final RoleRepository _rolesApi;

  RoleQuery _query = const RoleQuery();
  List<RoleModel> _items = const [];
  List<PermissionModel> _tree = const [];
  bool _loading = true;
  String? _error;
  int _total = 0;
  int? _status;

  @override
  void initState() {
    super.initState();
    _rolesApi = RoleRepository(appAuthController.dio);
    _init();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.wait([_loadPermissions(), _load()]);
  }

  Future<void> _loadPermissions() async {
    try {
      final result = await _rolesApi.fetchPermissionTree();
      if (!mounted) return;
      setState(() => _tree = result);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _rolesApi.fetchRoles(_query);
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
        _error = '角色数据加载失败，请稍后重试。';
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
      _query = const RoleQuery();
    });
    await _load();
  }

  Future<void> _changePage(int page) async {
    final maxPage = (_total / _query.pageSize).ceil();
    if (page < 1 || (maxPage > 0 && page > maxPage)) return;
    _query = _query.copyWith(page: page);
    await _load();
  }

  Future<void> _showRoleForm([RoleModel? role]) async {
    final isEdit = role != null;
    Map<String, dynamic>? detail;
    if (isEdit) {
      detail = await _rolesApi.fetchRoleDetail(role.id);
    }
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final roleCodeController =
        TextEditingController(text: detail?['role_code'] as String? ?? '');
    final roleNameController =
        TextEditingController(text: detail?['role_name'] as String? ?? '');
    final remarkController =
        TextEditingController(text: detail?['remark'] as String? ?? '');
    int status = detail?['status'] as int? ?? 1;
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'role_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              final payload = RoleFormData(
                roleCode: roleCodeController.text.trim(),
                roleName: roleNameController.text.trim(),
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
                  final data = payload.toJson()..remove('role_code');
                  await _rolesApi.updateRole(role.id, data);
                } else {
                  await _rolesApi.createRole(payload);
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
                  formError = isEdit ? '角色更新失败，请稍后重试。' : '角色创建失败，请稍后重试。';
                });
              }
            }

            return AppDrawerForm(
              title: isEdit ? '编辑角色' : '新建角色',
              subtitle: isEdit ? '维护角色名称、状态和说明信息。' : '创建新的角色，后续可以继续分配权限。',
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
                      : Text(isEdit ? '保存修改' : '创建角色'),
                ),
              ],
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('角色信息'),
                    _field(
                      TextFormField(
                        controller: roleCodeController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: '角色编码'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入角色编码'
                                : null,
                      ),
                    ),
                    _field(
                      TextFormField(
                        controller: roleNameController,
                        decoration: const InputDecoration(labelText: '角色名称'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入角色名称'
                                : null,
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
                    TextFormField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '备注'),
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

    roleCodeController.dispose();
    roleNameController.dispose();
    remarkController.dispose();

    if (result == true) {
      await _load();
      await appAuthController.refreshCurrentUser();
    }
  }

  Future<void> _showAssignPermissions(RoleModel role) async {
    final detail = await _rolesApi.fetchRoleDetail(role.id);
    if (!mounted) return;

    final selected = ((detail['permission_ids'] as List<dynamic>? ?? const []))
        .cast<int>()
        .toSet();
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'assign_permissions',
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
                await _rolesApi.assignPermissions(
                    role.id, selected.toList()..sort());
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
              title: '分配权限',
              subtitle: '为 ${role.roleName} 勾选可访问的菜单、按钮和接口权限。',
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
                      : const Text('保存权限'),
                ),
              ],
              child: _tree.isEmpty
                  ? const AppEmptyState(
                      title: '暂无可分配权限',
                      message: '当前系统还没有权限节点，请先补充权限配置。',
                    )
                  : Column(
                      children: [
                        ..._tree.map(
                          (node) => _PermissionNode(
                            node: node,
                            selected: selected,
                            onChanged: () => setModalState(() {}),
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
      await appAuthController.refreshCurrentUser();
    }
  }

  Future<void> _deleteRole(RoleModel role) async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: '确认删除',
      message: '确认要删除角色“${role.roleName}”吗？',
      confirmText: '删除',
    );
    if (!ok) return;

    try {
      await _rolesApi.deleteRole(role.id);
      if (!mounted) return;
      await _load();
      await appAuthController.refreshCurrentUser();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission(PermissionCodes.roleAdd);
    final canEdit = appAuthController.hasPermission(PermissionCodes.roleEdit);
    final canDelete =
        appAuthController.hasPermission(PermissionCodes.roleDelete);
    final canAssign =
        appAuthController.hasPermission(PermissionCodes.roleAssignPermission);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.compactDesktop;
        final cardsPerRow = compact ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - ((cardsPerRow - 1) * 16)) / cardsPerRow;
        final enabledCount = _items.where((item) => item.status == 1).length;
        final boundUsers =
            _items.fold<int>(0, (sum, item) => sum + item.userCount);
        final totalPermissions = _flattenPermissionCount(_tree);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: '角色权限',
                subtitle: '维护角色、绑定用户数量和权限树分配，让系统授权边界保持清晰。',
                actions: [
                  if (canAdd)
                    ElevatedButton.icon(
                      onPressed: _showRoleForm,
                      icon: const Icon(Icons.add_moderator_rounded),
                      label: const Text('新建角色'),
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
                      icon: Icons.shield_outlined,
                      color: AppColors.brandBlue,
                      label: '角色总数',
                      value: '$_total',
                      description: '当前筛选结果中的角色总量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      label: '启用角色',
                      value: '$enabledCount',
                      description: '当前结果中处于启用状态的角色数量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.group_outlined,
                      color: AppColors.warning,
                      label: '绑定用户',
                      value: '$boundUsers',
                      description: '全部角色已绑定的用户数量汇总。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(220.0, 320.0),
                    child: AppMetricCard(
                      icon: Icons.rule_folder_outlined,
                      color: AppColors.danger,
                      label: '权限节点',
                      value: '$totalPermissions',
                      description: '当前权限树中可分配的权限节点总数。',
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
                      '支持按角色编码、角色名称和状态快速过滤角色记录。',
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
                            hintText: '搜索角色编码或名称',
                            onSubmitted: _search,
                          ),
                        ),
                        SizedBox(
                          width: compact ? constraints.maxWidth : 220,
                          child: AppSelectField<int>(
                            value: _status,
                            labelText: '状态',
                            items: const [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('全部状态'),
                              ),
                              DropdownMenuItem(value: 1, child: Text('启用')),
                              DropdownMenuItem(value: 0, child: Text('禁用')),
                            ],
                            onChanged: (value) =>
                                setState(() => _status = value),
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
                title: '角色列表',
                subtitle:
                    _loading ? '正在加载角色数据。' : '共 $_total 个角色，支持编辑、分配权限和删除操作。',
                footer: _loading || _error != null || _items.isEmpty
                    ? null
                    : AppPaginationBar(
                        page: _query.page,
                        pageSize: _query.pageSize,
                        total: _total,
                        onPageChanged: _changePage,
                      ),
                child: _buildTable(
                  canEdit: canEdit,
                  canDelete: canDelete,
                  canAssign: canAssign,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable({
    required bool canEdit,
    required bool canDelete,
    required bool canAssign,
  }) {
    if (_loading) {
      return const AppTableLoadingSkeleton(rows: 6, columns: 7);
    }

    if (_error != null) {
      return AppErrorState(
        message: _error!,
        onRetry: _load,
      );
    }

    if (_items.isEmpty) {
      return AppEmptyState(
        title: '暂无数据',
        message: '当前没有符合条件的角色记录，试试调整筛选条件。',
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
          DataColumn(label: Text('编码')),
          DataColumn(label: Text('角色名称')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('绑定用户')),
          DataColumn(label: Text('权限数')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('操作')),
        ],
        rows: _items
            .map(
              (role) => DataRow(
                cells: [
                  DataCell(Text(role.roleCode)),
                  DataCell(Text(role.roleName)),
                  DataCell(
                    AppStatusPill(
                      label: role.status == 1 ? '启用' : '禁用',
                      color: role.status == 1
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  DataCell(Text('${role.userCount}')),
                  DataCell(Text('${role.permissionCount}')),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        role.remark ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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
                              tooltip: '编辑角色',
                              onPressed: () => _showRoleForm(role),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canAssign,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.rule_folder_outlined,
                              tooltip: '分配权限',
                              onPressed: () => _showAssignPermissions(role),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canDelete,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: '删除角色',
                              color: AppColors.danger,
                              onPressed: () => _deleteRole(role),
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

  int _flattenPermissionCount(List<PermissionModel> nodes) {
    var total = 0;
    for (final node in nodes) {
      total += 1;
      total += _flattenPermissionCount(node.children);
    }
    return total;
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
}

class _PermissionNode extends StatelessWidget {
  final PermissionModel node;
  final Set<int> selected;
  final VoidCallback onChanged;

  const _PermissionNode({
    required this.node,
    required this.selected,
    required this.onChanged,
  });

  void _walk(PermissionModel current, bool checked) {
    if (checked) {
      selected.add(current.id);
    } else {
      selected.remove(current.id);
    }
    for (final child in current.children) {
      _walk(child, checked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgGray.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: selected.contains(node.id),
            title: Text(node.permName),
            subtitle: Text('${node.permCode} · ${node.permType}'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              _walk(node, value ?? false);
              onChanged();
            },
          ),
          if (node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                children: node.children
                    .map(
                      (child) => _PermissionNode(
                        node: child,
                        selected: selected,
                        onChanged: onChanged,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
