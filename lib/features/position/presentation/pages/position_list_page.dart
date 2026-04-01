import 'package:flutter/material.dart';
import 'package:my_second_app/app/theme/app_colors.dart';
import 'package:my_second_app/core/network/api_result.dart';
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
        _errorMessage = '岗位数据加载失败';
      });
    }
  }

  Future<void> _onSearch() async {
    _query = _query.copyWith(page: 1, keyword: _keywordController.text.trim(), status: _selectedStatus);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除岗位“${position.positionName}”吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
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
      await _positionRepository.deletePosition(position.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('岗位删除成功')));
      await _fetchPositions();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
        return false;
      }
    }

    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: detail?['position_code'] as String? ?? '');
    final nameController = TextEditingController(text: detail?['position_name'] as String? ?? '');
    final levelController = TextEditingController(text: detail?['level_name'] as String? ?? '');
    final remarkController = TextEditingController(text: detail?['remark'] as String? ?? '');
    int status = detail?['status'] as int? ?? 1;
    bool saving = false;
    String? formError;
    if (!mounted) return false;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'position_form',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;
              final payload = PositionFormData(
                positionCode: codeController.text.trim(),
                positionName: nameController.text.trim(),
                levelName: levelController.text.trim().isEmpty ? null : levelController.text.trim(),
                status: status,
                remark: remarkController.text.trim().isEmpty ? null : remarkController.text.trim(),
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
                  formError = isEdit ? '岗位更新失败' : '岗位创建失败';
                });
              }
            }

            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 500
                      ? MediaQuery.of(context).size.width * 0.92
                      : 440,
                  child: SafeArea(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(isEdit ? '编辑岗位' : '新建岗位', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                          subtitle: Text(isEdit ? '维护岗位名称、职级与状态。' : '录入岗位基础信息。'),
                          trailing: IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close_rounded)),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  _field(TextFormField(controller: codeController, enabled: !isEdit, decoration: const InputDecoration(labelText: '岗位编码'), validator: (value) => value == null || value.trim().isEmpty ? '请输入岗位编码' : null)),
                                  _field(TextFormField(controller: nameController, decoration: const InputDecoration(labelText: '岗位名称'), validator: (value) => value == null || value.trim().isEmpty ? '请输入岗位名称' : null)),
                                  _field(TextFormField(controller: levelController, decoration: const InputDecoration(labelText: '职级'))),
                                  _field(DropdownButtonFormField<int>(initialValue: status, decoration: const InputDecoration(labelText: '状态'), items: const [DropdownMenuItem(value: 1, child: Text('启用')), DropdownMenuItem(value: 0, child: Text('停用'))], onChanged: (value) => setModalState(() => status = value ?? 1))),
                                  TextFormField(controller: remarkController, maxLines: 3, decoration: const InputDecoration(labelText: '备注')),
                                  if (formError != null) ...[
                                    const SizedBox(height: 16),
                                    Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)), child: Text(formError!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600))),
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
                              Expanded(child: OutlinedButton(onPressed: saving ? null : () => Navigator.pop(context, false), child: const Text('取消'))),
                              const SizedBox(width: 12),
                              Expanded(child: ElevatedButton(onPressed: saving ? null : submit, child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEdit ? '保存修改' : '创建岗位'))),
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
      transitionBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child),
    );

    codeController.dispose();
    nameController.dispose();
    levelController.dispose();
    remarkController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = appAuthController.hasPermission('position:add');
    final canEdit = appAuthController.hasPermission('position:edit');
    final canDelete = appAuthController.hasPermission('position:delete');
    final currentPage = _query.page;
    final totalPages = _total == 0 ? 1 : (_total / _query.pageSize).ceil();

    Widget card(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)), child: child);
    Widget tablePanel() => card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('岗位列表', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      if (_errorMessage != null) ...[
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger))),
      ],
      const SizedBox(height: 16),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _positions.isEmpty ? const _PositionEmptyState() : SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: DataTable(columnSpacing: 24, headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)), columns: const [
        DataColumn(label: Text('编码')), DataColumn(label: Text('名称')), DataColumn(label: Text('职级')), DataColumn(label: Text('状态')), DataColumn(label: Text('备注')), DataColumn(label: Text('操作')),
      ], rows: _positions.map((position) => DataRow(cells: [
        DataCell(Text(position.positionCode)),
        DataCell(Text(position.positionName)),
        DataCell(Text(position.levelName ?? '-')),
        DataCell(_PositionStatusTag(status: position.status)),
        DataCell(Text(position.remark ?? '-')),
        DataCell(Row(children: [
          if (canEdit) IconButton(tooltip: '编辑', onPressed: () => _openEdit(position), icon: const Icon(Icons.edit_outlined)),
          if (canDelete) IconButton(tooltip: '删除', onPressed: () => _deletePosition(position), icon: const Icon(Icons.delete_outline)),
        ])),
      ])).toList())))),
      const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('共 $_total 条记录', style: const TextStyle(color: AppColors.textSecondary)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          OutlinedButton(onPressed: currentPage > 1 ? () => _changePage(currentPage - 1) : null, child: const Text('上一页')),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$currentPage / $totalPages')),
          OutlinedButton(onPressed: currentPage < totalPages ? () => _changePage(currentPage + 1) : null, child: const Text('下一页')),
        ]),
      ]),
    ]));

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxHeight < 820 || constraints.maxWidth < 1100;
      final statCompact = constraints.maxWidth < 1120;
      final statWidth = constraints.maxWidth < 720 ? constraints.maxWidth : statCompact ? (constraints.maxWidth - 16) / 2 : (constraints.maxWidth - 32) / 3;
      final stats = Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: statWidth, child: _PositionStatCard(title: '总岗位数', value: '$_total', color: AppColors.brandBlue)),
        SizedBox(width: statWidth, child: _PositionStatCard(title: '启用', value: '${_positions.where((e) => e.status == 1).length}', color: AppColors.success)),
        SizedBox(width: statWidth, child: _PositionStatCard(title: '停用', value: '${_positions.where((e) => e.status == 0).length}', color: AppColors.warning)),
      ]);
      final content = [
        Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('岗位管理', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('维护岗位编码、岗位名称和职级信息。当前共 $_total 条岗位记录。', style: const TextStyle(color: AppColors.textSecondary, height: 1.7)),
          ])),
          if (canAdd) ElevatedButton.icon(onPressed: _openCreate, icon: const Icon(Icons.add_rounded), label: const Text('新建岗位')),
        ]),
        const SizedBox(height: 20),
        stats,
        const SizedBox(height: 18),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('条件筛选', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 240, child: TextField(controller: _keywordController, decoration: const InputDecoration(labelText: '岗位名称 / 编码 / 职级'))),
            SizedBox(width: 160, child: DropdownButtonFormField<int?>(initialValue: _selectedStatus, decoration: const InputDecoration(labelText: '状态'), items: const [DropdownMenuItem<int?>(value: null, child: Text('全部状态')), DropdownMenuItem<int?>(value: 1, child: Text('启用')), DropdownMenuItem<int?>(value: 0, child: Text('停用'))], onChanged: (value) => setState(() => _selectedStatus = value))),
            ElevatedButton(onPressed: _onSearch, child: const Text('查询')),
            OutlinedButton(onPressed: _resetFilters, child: const Text('重置')),
          ]),
        ])),
        const SizedBox(height: 18),
      ];

      if (compact) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...content, SizedBox(height: 520, child: tablePanel())]),
        );
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...content, Expanded(child: tablePanel())]);
    });
  }
}

Widget _field(Widget child) => Padding(padding: const EdgeInsets.only(bottom: 14), child: child);

class _PositionStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _PositionStatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)), alignment: Alignment.center, child: Icon(Icons.badge_rounded, color: color)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _PositionStatusTag extends StatelessWidget {
  final int status;
  const _PositionStatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final enabled = status == 1;
    final color = enabled ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(enabled ? '启用' : '停用', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _PositionEmptyState extends StatelessWidget {
  const _PositionEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.badge_rounded, size: 42, color: AppColors.textHint),
        SizedBox(height: 14),
        Text('没有找到符合条件的岗位记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 8),
        Text('你可以调整筛选条件，或者新建一个岗位。', style: TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}
