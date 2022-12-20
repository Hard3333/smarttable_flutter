import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_table_flutter/classes/filter_response.dart';
import 'package:smart_table_flutter/common/smart_table_dialog.dart';
import 'package:smart_table_flutter/smart_table.dart';

typedef GetData<T> = Future<FilterResponse<T>> Function(TableFilterData tableFilterData);
typedef ColumnHeaderBuilder = Widget Function();
typedef RowCellBuilder<T> = Widget Function(T value);

const _DEFAULT_PAGE_SIZE = 20;

abstract class DataSource<T> {
  FutureOr<FilterResponse<T>> getData(TableFilterData data);

  const DataSource();
}

class AsyncDataSource<T> extends DataSource<T> {
  final GetData<T> fetchData;

  @override
  Future<FilterResponse<T>> getData(TableFilterData data) async => await fetchData(data);

  const AsyncDataSource({required this.fetchData});
}

class SmartTableOptions<T> {
  final List<SmartTableColumn> columns;
  final SmartTableDecoration? decoration;
  final String Function(T item)? itemToString;
  final List<SmartTableDialogItem> Function(T item)? customMenuItemsBuilder;
  final OnAddNewElement<T>? onAddNewElement;
  final OnRemoveElement<T>? onRemoveElement;
  final OnElementModify<T>? onElementModify;
  final HeaderOptions? headerOptions;

  const SmartTableOptions(
      {required this.columns, this.decoration, this.itemToString, this.customMenuItemsBuilder, this.onAddNewElement, this.onRemoveElement, this.onElementModify, this.headerOptions});
}

class SmartTableDecoration {
  final Color? color;
  final Color? textColor;
  final DecorationImage? image;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color? borderColor;
  final SortIconDecoration? sortIconDecoration;
  final FilterDecoration? filterDecoration;
  final RowDecoration? rowDecoration;
  final SmartTableTextFieldDecoration? textFieldDecoration;
  final SmartTableDropdownDecoration? dropdownDecoration;

  const SmartTableDecoration(
      {this.textColor,
      this.textFieldDecoration,
      this.color,
      this.image,
      this.borderRadius,
      this.boxShadow,
      this.gradient,
      this.borderColor,
      this.sortIconDecoration,
      this.filterDecoration,
      this.rowDecoration,
      this.dropdownDecoration});
}

class SmartTableDropdownDecoration {
  final TextStyle? hintStyle;
  final Color? bgColor;
  final Color? focusColor;
  final Color? dropdownColor;
  final Color? dropdownBorderColor;

  const SmartTableDropdownDecoration({this.hintStyle, this.bgColor, this.focusColor, this.dropdownColor, this.dropdownBorderColor});
}

class SmartTableTextFieldDecoration {
  final Color? borderColor;
  final Color? disabledBorderColor;
  final Color? focusedBorderColor;
  final int? maxLines;
  final Color? bgColor;
  final Icon? suffixIcon;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final EdgeInsets? contentPadding;

  const SmartTableTextFieldDecoration(
      {this.maxLines, this.bgColor, this.suffixIcon, this.borderColor, this.hintStyle, this.style, this.contentPadding, this.disabledBorderColor, this.focusedBorderColor});


/*  SmartTableTextFieldDecoration copyWith(
      {Color? borderColor,
       Color? disabledBorderColor,
       Color? focusedBorderColor,
       String? hintText,
       int? maxLines,
       Color? bgColor,
       Icon? suffixIcon,
       TextStyle? hintStyle,
       TextStyle? style,
       EdgeInsets? contentPadding
      }) {
    return SmartTableTextFieldDecoration(
        borderColor: borderColor ?? this.borderColor,
        disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
        focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
        hintText: hintText ?? this.hintText,
        maxLines: maxLines ?? this.maxLines,
        bgColor: bgColor ?? this.bgColor,
        suffixIcon: suffixIcon ?? this.suffixIcon,
        hintStyle: hintStyle ?? this.hintStyle,
        style: style ?? this.style,
        contentPadding: contentPadding ?? this.contentPadding
    );
  }*/
}

class RowDecoration {
  final Color? rowColor;
  final Color? secondaryRowColor;

  const RowDecoration({this.rowColor, this.secondaryRowColor});
}

class HeaderOptions {
  final bool showDisabledAddNewButton;
  final String? addNewButtonLabel;
  final Color? addNewButtonIconColor;

  //final CustomHeaderBuilder? customHeaderBuilder;

  HeaderOptions({
    this.addNewButtonLabel,
    this.addNewButtonIconColor,
    this.showDisabledAddNewButton = true,
    /*this.customHeaderBuilder*/
  });
}

class FilterDecoration {
  final InputDecoration? filterTextFieldDecoration;

  const FilterDecoration({this.filterTextFieldDecoration});
}

class SortIconDecoration {
  final Color? inactiveColor;
  final Color? activeColor;

  const SortIconDecoration({this.inactiveColor, this.activeColor});
}

class SmartTableColumn<T> {
  final String name;
  final String title;
  final SmartTableColumnFilterOptions<T> filterOptions;
  final ColumnType columnType;
  final ColumnSortType columnSortType;
  final Alignment alignment;
  final TableColumnWidth? columnWidth;

  SmartTableColumn({
    required this.name,
    required this.title,
    this.filterOptions = const SmartTableColumnFilterOptions(),
    this.columnType = ColumnType.STRING,
    this.columnSortType = ColumnSortType.NONE,
    this.columnWidth,
    this.alignment = Alignment.centerLeft,
  });

  SmartTableColumn copyWith({ColumnSortType? columnSortType}) =>
      SmartTableColumn(name: name, title: title, columnWidth: columnWidth, columnType: columnType, filterOptions: filterOptions, columnSortType: columnSortType ?? this.columnSortType);
}

class SmartTableColumnFilterOptions<T> {
  final Future<List<T>> Function(String str)? onFind;
  final String Function(T item)? itemToString;
  final bool filterEnabled;
  final bool sortEnabled;
  final String? filterHintText;
  final bool loadFirstItemAutomaticallyInDropdown;

  const SmartTableColumnFilterOptions({this.onFind, this.filterEnabled = false, this.sortEnabled = false, this.filterHintText, this.itemToString, this.loadFirstItemAutomaticallyInDropdown = false});
}

enum ColumnType { STRING, NUMERIC, DATE_RANGE, DATE, BOOLEAN, DROPDOWN }

enum ColumnSortType { NONE, ASC, DESC }

class SmartTableRow<T> {
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

  TableFilterData copyWith({int? page, int? pageSize, Map<String, dynamic>? filterData, SmartTableColumn? sortedColumn}) {
    return TableFilterData(page: page ?? this.page, pageSize: pageSize ?? this.pageSize, filterData: filterData ?? this.filterData, sortedColumn: sortedColumn ?? this.sortedColumn);
  }
}

class TableData<T> {
  final FilterResponse<T> filterResponse;

  TableData(this.filterResponse);

  factory TableData.empty() => TableData(FilterResponse.empty());
}

class TablePageData {
  final int page;

  const TablePageData({this.page = 0});

  factory TablePageData.first() => const TablePageData(page: 0);

  factory TablePageData.fromPage(int newPage) => TablePageData(page: newPage);
}

class SmartTableException implements Exception {
  final String message;

  const SmartTableException({required this.message});

  @override
  String toString() => message;
}
