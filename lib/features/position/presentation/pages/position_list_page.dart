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
import 'package:my_second_app/features/position/data/models/position_form_data.dart';
import 'package:my_second_app/features/position/data/models/position_model.dart';
import 'package:my_second_app/features/position/data/models/position_query.dart';
import 'package:my_second_app/shared/repositories/position_repository.dart';

class PositionListPage extends StatefulWidget {
  const PositionListPage({super.key});

  @override
  State<PositionListPage> createState() => _PositionListPageState();
}

class _PositionListPageState extends State<PositionListPage> {
  late final PositionRepository _positionRepository;
  final TextEditingController _keywordController = TextEditingController();

  PositionQuery _query = const PositionQuery();
  List<PositionModel> _positions = const [];
  bool _loading = true;
  String? _errorMessage;
  int _total = 0;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _positionRepository = PositionRepository(appAuthController.dio);
    _fetchPositions();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _fetchPositions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final result = await _positionRepository.fetchPositions(_query);
      if (!mounted) return;
      setState(() {
        _positions = result.items;
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
        _errorMessage = '岗位数据加载失败，请稍后重试。';
      });
    }
  }

  Future<void> _onSearch() async {
    _query = _query.copyWith(
      page: 1,
      keyword: _keywordController.text.trim(),
      status: _selectedStatus,
    );
    await _fetchPositions();
  }

  Future<void> _resetFilters() async {
    _keywordController.clear();
    setState(() {
      _selectedStatus = null;
      _query = const PositionQuery();
    });
    await _fetchPositions();
  }

  Future<void> _changePage(int page) async {
    if (page < 1) return;
    final maxPage = (_total / _query.pageSize).ceil();
    if (maxPage > 0 && page > maxPage) return;
    _query = _query.copyWith(page: page);
    await _fetchPositions();
  }

  Future<void> _openCreate() async {
    final saved = await _showPositionForm();
    if (saved == true) await _fetchPositions();
  }

  Future<void> _openEdit(PositionModel position) async {
    final saved = await _showPositionForm(positionId: position.id);
    if (saved == true) await _fetchPositions();
  }

  Future<void> _deletePosition(PositionModel position) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '确认删除',
      message: '确认要删除岗位“${position.positionName}”吗？',
      confirmText: '删除',
    );
    if (!confirmed) return;
    try {
      await _positionRepository.deletePosition(position.id);
      if (!mounted) return;
      showAppSuccess(context, '岗位删除成功');
      await _fetchPositions();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppError(context, error.message);
    }
  }

  Future<bool?> _showPositionForm({int? positionId}) async {
    final isEdit = positionId != null;
    Map<String, dynamic>? detail;
    if (isEdit) {
      try {
        detail = await _positionRepository.fetchPositionDetail(positionId);
      } on ApiException catch (error) {
        if (!mounted) return false;
        showAppError(context, error.message);
        return false;
      }
    }
    if (!mounted) return false;

    final formKey = GlobalKey<FormState>();
    final codeController =
        TextEditingController(text: detail?['position_code'] as String? ?? '');
    final nameController =
        TextEditingController(text: detail?['position_name'] as String? ?? '');
    final levelController =
        TextEditingController(text: detail?['level_name'] as String? ?? '');
    final remarkController =
        TextEditingController(text: detail?['remark'] as String? ?? '');

    int status = detail?['status'] as int? ?? 1;
    bool saving = false;
    String? formError;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'position_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              final payload = PositionFormData(
                positionCode: codeController.text.trim(),
                positionName: nameController.text.trim(),
                levelName: levelController.text.trim().isEmpty
                    ? null
                    : levelController.text.trim(),
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
                  final data = payload.toJson()..remove('position_code');
                  await _positionRepository.updatePosition(positionId, data);
                } else {
                  await _positionRepository.createPosition(payload);
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
                  formError = isEdit ? '岗位更新失败，请稍后重试。' : '岗位创建失败，请稍后重试。';
                });
              }
            }

            return AppDrawerForm(
              title: isEdit ? '编辑岗位' : '新建岗位',
              subtitle: isEdit ? '维护岗位名称、职级和状态配置。' : '为组织新增岗位，并补充职级与备注信息。',
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
                      : Text(isEdit ? '保存修改' : '创建岗位'),
                ),
              ],
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('岗位信息'),
                    _buildField(
                      TextFormField(
                        controller: codeController,
                        enabled: !isEdit,
                        decoration: const InputDecoration(labelText: '岗位编码'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入岗位编码'
                                : null,
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '岗位名称'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? '请输入岗位名称'
                                : null,
                      ),
                    ),
                    _buildField(
                      TextFormField(
                        controller: levelController,
                        decoration: const InputDecoration(labelText: '职级'),
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
    levelController.dispose();
    remarkController.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission(PermissionCodes.positionAdd);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.compactDesktop;
        final cardsPerRow = compact ? 2 : 3;
        final itemWidth =
            (constraints.maxWidth - ((cardsPerRow - 1) * 16)) / cardsPerRow;
        final activeCount =
            _positions.where((position) => position.status == 1).length;
        final levelCount = _positions
            .where((position) => (position.levelName ?? '').trim().isNotEmpty)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: '岗位管理',
                subtitle: '维护岗位编码、职级和状态，让编制与组织岗位映射保持一致。',
                actions: [
                  PermissionWidget(
                    allowed: canAdd,
                    showDisabledState: true,
                    deniedTooltip: '当前账号没有此操作权限',
                    child: ElevatedButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.add_chart_rounded),
                      label: const Text('新建岗位'),
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
                    width: itemWidth.clamp(240.0, 360.0),
                    child: AppMetricCard(
                      icon: Icons.work_outline_rounded,
                      color: AppColors.brandBlue,
                      label: '岗位总数',
                      value: '$_total',
                      description: '当前筛选结果中的岗位总量。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(240.0, 360.0),
                    child: AppMetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      label: '当前页启用',
                      value: '$activeCount',
                      description: '便于快速确认岗位当前启用情况。',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth.clamp(240.0, 360.0),
                    child: AppMetricCard(
                      icon: Icons.military_tech_outlined,
                      color: AppColors.warning,
                      label: '已配置职级',
                      value: '$levelCount',
                      description: '当前结果中已填写职级的岗位数量。',
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
                      '支持按岗位名称、编码和状态快速过滤岗位数据。',
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
                            hintText: '搜索岗位名称或编码',
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
                title: '岗位列表',
                subtitle: _loading ? '正在加载岗位数据。' : '共 $_total 个岗位，支持编辑和删除操作。',
                footer: _loading || _errorMessage != null || _positions.isEmpty
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
    final canEdit =
        appAuthController.hasPermission(PermissionCodes.positionEdit);
    final canDelete =
        appAuthController.hasPermission(PermissionCodes.positionDelete);

    if (_loading) {
      return const AppTableLoadingSkeleton(rows: 6, columns: 6);
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: _errorMessage!,
        onRetry: _fetchPositions,
      );
    }

    if (_positions.isEmpty) {
      return AppEmptyState(
        title: '暂无数据',
        message: '当前没有符合条件的岗位记录，试试调整筛选条件。',
        action: OutlinedButton(
          onPressed: _resetFilters,
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
          DataColumn(label: Text('编码')),
          DataColumn(label: Text('岗位名称')),
          DataColumn(label: Text('职级')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('操作')),
        ],
        rows: _positions
            .map(
              (position) => DataRow(
                cells: [
                  DataCell(Text(position.positionCode)),
                  DataCell(Text(position.positionName)),
                  DataCell(Text(position.levelName ?? '-')),
                  DataCell(_buildStatus(position.status)),
                  DataCell(Text(position.remark ?? '-')),
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
                              tooltip: '编辑岗位',
                              onPressed: () => _openEdit(position),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PermissionWidget(
                            allowed: canDelete,
                            showDisabledState: true,
                            deniedTooltip: '当前账号没有此操作权限',
                            child: AppIconActionButton(
                              icon: Icons.delete_outline_rounded,
                              tooltip: '删除岗位',
                              color: AppColors.danger,
                              onPressed: () => _deletePosition(position),
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
