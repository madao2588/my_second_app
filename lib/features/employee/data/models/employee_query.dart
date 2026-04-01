class EmployeeQuery {
  final int page;
  final int pageSize;
  final String? keyword;
  final int? deptId;
  final String? status;
  final String sortBy;
  final String sortOrder;

  const EmployeeQuery({
    this.page = 1,
    this.pageSize = 10,
    this.keyword,
    this.deptId,
    this.status,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });

  EmployeeQuery copyWith({
    int? page,
    int? pageSize,
    String? keyword,
    int? deptId,
    String? status,
    String? sortBy,
    String? sortOrder,
    bool clearKeyword = false,
    bool clearDeptId = false,
    bool clearStatus = false,
  }) {
    return EmployeeQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      deptId: clearDeptId ? null : (deptId ?? this.deptId),
      status: clearStatus ? null : (status ?? this.status),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
      if (deptId != null) 'dept_id': deptId,
      if (status != null && status!.isNotEmpty) 'status': status,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }
}
