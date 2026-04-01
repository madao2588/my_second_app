class UserQuery {
  final int page;
  final int pageSize;
  final String? keyword;
  final int? status;

  const UserQuery({
    this.page = 1,
    this.pageSize = 10,
    this.keyword,
    this.status,
  });

  UserQuery copyWith({
    int? page,
    int? pageSize,
    String? keyword,
    int? status,
    bool clearKeyword = false,
    bool clearStatus = false,
  }) {
    return UserQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
      if (status != null) 'status': status,
    };
  }
}
