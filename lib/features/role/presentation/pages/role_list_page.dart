import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/core/network/api_result.dart';
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
  final _keywordController = TextEditingController();
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
        _error = '角色数据加载失败';
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

  Future<void> _openForm([RoleModel? role]) async {
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final media = MediaQuery.of(context).size;
          final dialogWidth = media.width < 520 ? media.width * 0.92 : 420.0;
          final dialogHeight = media.height < 720 ? media.height * 0.88 : 640.0;

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
                      isEdit ? '编辑角色' : '新建角色',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEdit ? '维护角色名称、状态与说明信息。' : '创建一个新的角色，后续可继续分配权限。',
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
                                  controller: roleCodeController,
                                  enabled: !isEdit,
                                  decoration:
                                      const InputDecoration(labelText: '角色编码'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入角色编码';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _field(
                                TextFormField(
                                  controller: roleNameController,
                                  decoration:
                                      const InputDecoration(labelText: '角色名称'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入角色名称';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _field(
                                DropdownButtonFormField<int>(
                                  initialValue: status,
                                  decoration:
                                      const InputDecoration(labelText: '状态'),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 1, child: Text('启用')),
                                    DropdownMenuItem(
                                        value: 0, child: Text('禁用')),
                                  ],
                                  onChanged: (value) =>
                                      setModalState(() => status = value ?? 1),
                                ),
                              ),
                              TextFormField(
                                controller: remarkController,
                                maxLines: 3,
                                decoration:
                                    const InputDecoration(labelText: '备注'),
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

    roleCodeController.dispose();
    roleNameController.dispose();
    remarkController.dispose();

    if (ok == true) {
      await _load();
      await appAuthController.refreshCurrentUser();
    }
  }

  Future<void> _assignPermissions(RoleModel role) async {
    final detail = await _rolesApi.fetchRoleDetail(role.id);
    if (!mounted) return;

    final selected = ((detail['permission_ids'] as List<dynamic>? ?? const []))
        .cast<int>()
        .toSet();
    bool saving = false;
    String? error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final media = MediaQuery.of(context).size;
          final dialogWidth = media.width < 580 ? media.width * 0.94 : 500.0;
          final dialogHeight = media.height < 760 ? media.height * 0.90 : 700.0;

          Future<void> submit() async {
            setModalState(() {
              saving = true;
              error = null;
            });
            try {
              await _rolesApi.assignPermissions(
                  role.id, selected.toList()..sort());
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '分配权限 · ${role.roleName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '勾选角色可访问的菜单、按钮与接口权限。',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _tree.isEmpty
                          ? const Center(
                              child: Text(
                                '当前没有可分配的权限节点',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ..._tree.map(
                                    (node) => _PermissionNode(
                                      node: node,
                                      selected: selected,
                                      onChanged: () => setModalState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!,
                          style: const TextStyle(color: AppColors.danger)),
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
      await appAuthController.refreshCurrentUser();
    }
  }

  Future<void> _delete(RoleModel role) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除角色“${role.roleName}”吗？'),
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
      await _rolesApi.deleteRole(role.id);
      if (!mounted) return;
      await _load();
      await appAuthController.refreshCurrentUser();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
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
                '共 $_total 个角色',
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
                        ? const _RoleEmptyState()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 24,
                                headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF8FAFC)),
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
                                          DataCell(_StatusPill(
                                              enabled: role.status == 1)),
                                          DataCell(Text('${role.userCount}')),
                                          DataCell(
                                              Text('${role.permissionCount}')),
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
                                              width: 124,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (canEdit)
                                                    _TableActionButton(
                                                      tooltip: 'Edit',
                                                      onPressed: () =>
                                                          _openForm(role),
                                                      icon: Icons.edit_outlined,
                                                    ),
                                                  if (canAssign)
                                                    _TableActionButton(
                                                      tooltip:
                                                          'Assign permissions',
                                                      onPressed: () =>
                                                          _assignPermissions(
                                                              role),
                                                      icon: Icons
                                                          .rule_folder_outlined,
                                                    ),
                                                  if (canDelete)
                                                    _TableActionButton(
                                                      tooltip: 'Delete',
                                                      onPressed: () =>
                                                          _delete(role),
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
                      '角色权限',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '维护角色、状态与权限树分配。当前共有 $_total 个角色。',
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.7),
                    ),
                  ],
                ),
              ),
              if (canAdd)
                ElevatedButton.icon(
                  onPressed: _openForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新建角色'),
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
                child: _RoleStatCard(
                  title: '角色总数',
                  value: '$_total',
                  color: AppColors.brandBlue,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _RoleStatCard(
                  title: '启用',
                  value: '${_items.where((item) => item.status == 1).length}',
                  color: AppColors.success,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _RoleStatCard(
                  title: '禁用',
                  value: '${_items.where((item) => item.status == 0).length}',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(
                width: statWidth,
                child: _RoleStatCard(
                  title: '权限节点',
                  value: '${_tree.length}',
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
                            const InputDecoration(labelText: '角色编码 / 角色名称'),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.only(left: 20),
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

class _RoleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _RoleStatCard({
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
            child: Icon(Icons.shield_outlined, color: color),
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

class _RoleEmptyState extends StatelessWidget {
  const _RoleEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 40, color: AppColors.textHint),
          SizedBox(height: 14),
          Text(
            '没有找到符合条件的角色记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '你可以调整筛选条件，或新建一个角色。',
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
