class FilterResponse<T>{
  final List<T> content;
  final int page;
  final double totalCount;

  const FilterResponse({required this.content,required this.page,required this.totalCount});

  factory FilterResponse.empty() => const FilterResponse(page: 0,content: [], totalCount: 0);
}