class PageResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  const PageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
