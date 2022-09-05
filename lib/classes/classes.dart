import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_table_flutter/classes/filter_response.dart';
import 'package:smart_table_flutter/extensions/focused_menu/modals.dart';

typedef GetData<T> = Future<FilterResponse<T>> Function(TableFilterData tableFilterData);
typedef ColumnHeaderBuilder = Widget Function();
typedef RowCellBuilder<T> = Widget Function(T value);

const _DEFAULT_PAGE_SIZE = 20;

abstract class DataSource<T> {
  FutureOr<FilterResponse<T>> getData(TableFilterData data);

  const DataSource();
}

Widget _defaultColumnHeaderBuilder() => Text("Nameless Column");

/*
Widget _defaultColumnHeaderBuilder<T>(T? value, ColumnType columnType) {
  switch(columnType){
    case ColumnType.STRING:
    case ColumnType.NUMERIC: return Text(value.toString());
    case ColumnType.BOOLEAN: return Icon((value as bool) ? Icons.check : Icons.close, color: value ? Colors.green : Colors.redAccent);
    case ColumnType.DATE: return Text(DateFormat(_DEFAULT_DATE_FORMAT).format(value as DateTime));
  }
}*/

class AsyncDataSource<T> extends DataSource<T>{
  final GetData<T> fetchData;

  @override
  Future<FilterResponse<T>> getData(TableFilterData data) async => await fetchData(data);

  const AsyncDataSource({required this.fetchData});
}

class SmartTableOptions<T>{
  final List<SmartTableColumn> columns;
  final SmartTableDecoration? smartTableDecoration;
  final String Function(T item)? itemToString;
  final List<FocusedMenuItem> Function(T item)? customMenuItemsBuilder;

  const SmartTableOptions({required this.columns, this.smartTableDecoration, this.itemToString, this.customMenuItemsBuilder});
}

class SmartTableDecoration{

  final Color? color;
  final DecorationImage? image;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BorderSide? outerBorder;
  final BorderSide? innerBorder;
  final SortIconDecoration? sortIconDecoration;
  final FilterDecoration? filterDecoration;
  final HeaderOptions? headerOptions;
  final Color? secondaryRowColor;

  const SmartTableDecoration({this.color, this.image, this.borderRadius, this.boxShadow, this.gradient, this.outerBorder, this.innerBorder, this.sortIconDecoration, this.filterDecoration, this.headerOptions, this.secondaryRowColor});

}

class HeaderOptions{
  final String? addNewButtonLabel;
  final Color? addNewButtonIconColor;

  HeaderOptions({this.addNewButtonLabel, this.addNewButtonIconColor});
}

class FilterDecoration{
  final InputDecoration? filterTextFieldDecoration;

  const FilterDecoration({this.filterTextFieldDecoration});
}

class SortIconDecoration{
  final Color? inactiveColor;
  final Color? activeColor;

  const SortIconDecoration({this.inactiveColor, this.activeColor});
}

class SmartTableColumn{
  final String name;
  final String title;
  final String? filterHintText;
  final bool filterEnabled;
  final bool sortEnabled;
  final ColumnType columnType;
  final ColumnSortType columnSortType;
  final Alignment alignment;
  final double? columnWidth;
  final int? weight;

  SmartTableColumn({
    required this.name,
    required this.title,
    this.filterHintText,
    this.filterEnabled = true,
    this.sortEnabled = true,
    this.columnType = ColumnType.STRING,
    this.columnSortType = ColumnSortType.NONE,
    this.columnWidth,
    this.alignment = Alignment.centerLeft,
    this.weight
  });

  SmartTableColumn copyWith({ColumnSortType? columnSortType}) => SmartTableColumn(
      name: this.name,
      title: this.title,
      columnWidth: this.columnWidth,
      columnType: this.columnType,
      filterEnabled: this.filterEnabled,
      filterHintText: this.filterHintText,
      sortEnabled: this.sortEnabled,
      columnSortType: columnSortType ?? this.columnSortType
    );

}

enum ColumnType {STRING, NUMERIC, DATE, BOOLEAN}
enum ColumnSortType {NONE, ASC, DESC}

class SmartTableRow<T>{
  final RowCellBuilder<T>? rowCellBuilder;

  SmartTableRow({this.rowCellBuilder});
}

class TableFilterData {
  final int page;
  final int pageSize;
  final Map<String, dynamic>? filterData;
  final SmartTableColumn? sortedColumn;

  TableFilterData({required this.page, required this.pageSize, this.filterData, this.sortedColumn});

  factory TableFilterData.empty() => TableFilterData(page: 0, pageSize: _DEFAULT_PAGE_SIZE);
  factory TableFilterData.withPageSize(int pageSize) => TableFilterData(page: 0, pageSize: pageSize);

  TableFilterData copyWith({int? page, int? pageSize,Map<String, dynamic>? filterData, SmartTableColumn? sortedColumn}){
    return TableFilterData(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        filterData: filterData ?? this.filterData,
        sortedColumn: sortedColumn ?? this.sortedColumn
    );
  }
}

class TableData<T> {
  final FilterResponse<T> filterResponse;

  TableData(this.filterResponse);

  factory TableData.empty() => TableData(FilterResponse.empty());
}

class TablePageData{
  final int page;

  const TablePageData({this.page = 0});

  factory TablePageData.first() => TablePageData(page: 0);
  factory TablePageData.fromPage(int newPage) => TablePageData(page: newPage);
}

class SmartTableException implements Exception{
  final String message;

  const SmartTableException({required this.message});

  @override
  String toString() => message;
}