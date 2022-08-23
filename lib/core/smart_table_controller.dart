import 'dart:async';

import 'package:get/get.dart';
import 'package:smart_table_flutter/classes/classes.dart';
import 'package:smart_table_flutter/classes/filter_response.dart';

typedef OnTableError(SmartTableException e);

class SmartTableController<T> extends GetxController{
  final DataSource<T> dataSource;
  final OnTableError? onTableError;
  final int? pageSize;

  SmartTableController({required this.dataSource, this.onTableError, this.pageSize});

  final Rx<TableData<T>?> tableData = Rx<TableData<T>?>(null);
  final Rx<TablePageData> currentTablePage = TablePageData.first().obs;
  final Rx<SmartTableColumn?> sortedColumn = Rx<SmartTableColumn?>(null);
  final Rx<TableFilterData> _tableFilterData = Rx<TableFilterData>(TableFilterData.empty());

  late StreamSubscription<TablePageData> $currentTablePageSub;

  int? get totalPages => tableData.value == null ? null : (tableData.value!.filterResponse.totalCount / _tableFilterData.value.pageSize).ceil();

  bool tableInitialized = false;

  Future<void> init() async {
    if (!tableInitialized) {
      if(pageSize != null) _tableFilterData.value = TableFilterData.withPageSize(pageSize!);
      $currentTablePageSub = currentTablePage.stream.listen(listenPageChanges);
      await _loadInitialData();
      tableInitialized = true;
    }
  }

  Future<void> _loadInitialData() async => await _loadDataToTable(page: 0);

  Future<void> _loadDataToTable({required int page, FilterResponse<T>? dataToLoad}) async {
    late FilterResponse<T> data;
    try {
      if (dataToLoad != null) {
        data = dataToLoad;
      } else {
        final newFilterData = _tableFilterData.value.copyWith(page: page);
        _tableFilterData.value = newFilterData;
        data = await dataSource.getData(_tableFilterData.value);
      }
      tableData.value = TableData(data);
    } catch(e){
      throw SmartTableException(message: e.toString());
    }
  }

  Future<void> listenPageChanges(TablePageData tablePage) async {
      if (tablePage.page > (totalPages ?? 0)) throw Exception("Hiba az adatok frissítése közben. Ismeretlen oldal!");
      await _loadDataToTable(page: tablePage.page);
  }

  void setPage(TablePageData tablePageData) {
    if (tablePageData.page > (totalPages ?? 0)) throw Exception("Ismeretlen oldal, frissítse a táblázatot");
    currentTablePage.value = tablePageData;
  }

  Future<void> applySort(SmartTableColumn newSortedColumn) async {
      tableData.value = null;
      late ColumnSortType sortType;
      if(sortedColumn.value == null || sortedColumn.value?.columnSortType == ColumnSortType.NONE) sortType = ColumnSortType.DESC;
      else if(sortedColumn.value?.columnSortType == ColumnSortType.DESC) sortType = ColumnSortType.ASC;
      else if(sortedColumn.value?.columnSortType == ColumnSortType.ASC) sortType = ColumnSortType.NONE;

      final modifiedSortedColumn = newSortedColumn.copyWith(columnSortType: sortType);

      final newTableFilterData = _tableFilterData.value.copyWith(sortedColumn: modifiedSortedColumn);

      sortedColumn.value = modifiedSortedColumn;
      _tableFilterData.value = newTableFilterData;

      final filteredData = await dataSource.getData(_tableFilterData.value);
      await _loadDataToTable(page: 0,dataToLoad: filteredData);

      setPage(TablePageData.fromPage(_tableFilterData.value.page));
  }

  Future<void> applyFilter(Map<String, dynamic> filter) async{
    tableData.value = null;

    final filterData = _tableFilterData.value.filterData ?? {};
    filterData.addAll(filter);

    final newTableFilterData = _tableFilterData.value.copyWith(filterData: filterData);
    _tableFilterData.value = newTableFilterData;

    final filteredData = await dataSource.getData(_tableFilterData.value);

    await _loadDataToTable(page: 0, dataToLoad: filteredData);
    setPage(TablePageData.fromPage(_tableFilterData.value.page));
  }

  Future<void> applyFilterData(TableFilterData filterData) async {
      tableData.value = null;
      final filteredData = await dataSource.getData(filterData);
      await _loadDataToTable(page: 0, dataToLoad: filteredData);
      setPage(TablePageData.fromPage(filterData.page));
  }

  Future<void> refreshTable() async {
    tableData.value = null;
    await _loadDataToTable(page: currentTablePage.value.page);
  }

}