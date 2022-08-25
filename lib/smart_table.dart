import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_table_flutter/classes/classes.dart';
import 'package:smart_table_flutter/common/remove_dialog.dart';
import 'package:smart_table_flutter/common/smart_table_sort_text_field.dart';
import 'package:smart_table_flutter/core/smart_table_controller.dart';
import 'package:smart_table_flutter/core/utils.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
export 'package:smart_table_flutter/classes/classes.dart';
import 'package:auto_size_text/auto_size_text.dart';

typedef OnControllerCreated = Function(SmartTableController smartTableController);
typedef OnAddNewElement<T> = FutureOr<T?> Function();
typedef OnRemoveElement<T> = Function(T element);
typedef OnRowTap<T> = Function(T element);

const _DEFAULT_DATE_FORMAT = "yyyy-MM-dd";
const _DEFAULT_PADDING = const EdgeInsets.all(8.0);

class SmartTable<T> extends StatefulWidget {
  final DataSource<T> dataSource;
  final SmartTableOptions<T> options;

  final OnControllerCreated? onControllerCreated;
  final OnTableError? onTableError;
  final OnAddNewElement<T>? onAddNewElement;
  final OnRemoveElement<T>? onRemoveElement;
  final OnRowTap<T>? onRowTap;
  final int? pageSize;

  final Map<String, RowCellBuilder<T?>> rows;

  const SmartTable({Key? key, required this.dataSource, required this.options, this.onControllerCreated, this.onTableError, this.pageSize, required this.rows, this.onAddNewElement, this.onRemoveElement, this.onRowTap}) : super(key: key);

  @override
  State<SmartTable<T>> createState() => _SmartTableState<T>();
}

class _SmartTableState<T> extends State<SmartTable<T>> {
  late SmartTableController<T> _tableController;

  late BorderSide outerBorderSide;
  late BorderSide innerBorderSide;

  @override
  void initState() {
    super.initState();
    _tableController = SmartTableController<T>(dataSource: widget.dataSource, onTableError: widget.onTableError, pageSize: widget.pageSize);
    _tableController.init();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    outerBorderSide = widget.options.smartTableDecoration?.outerBorder ?? BorderSide(color:Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black);
    innerBorderSide = widget.options.smartTableDecoration?.innerBorder ?? BorderSide(color:Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black);
  }

  Widget _buildCell(dynamic value, SmartTableColumn column, Border cellBorder, {RowCellBuilder<T?>? rowCellBuilder}) {
    Widget _getWidget() {
      switch (column.columnType) {
        case ColumnType.STRING:
        case ColumnType.NUMERIC:
          return AutoSizeText(value.toString(), maxLines: 1, overflowReplacement: Tooltip(
            message: value.toString(),
            child: Text(value.toString(), overflow: TextOverflow.ellipsis, maxLines: 1),
          ));
        case ColumnType.BOOLEAN:
          return Icon((value as bool) ? Icons.check : Icons.close, color: value ? Colors.green : Colors.redAccent);
        case ColumnType.DATE:
          return Text(DateFormat(_DEFAULT_DATE_FORMAT).format(value as DateTime));
      }
    }

    Icon _getSortIcon() {
      final sortedColumn = _tableController.sortedColumn.value;
      final inactiveColor =  widget.options.smartTableDecoration?.sortIconDecoration?.inactiveColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
      final activeColor =  widget.options.smartTableDecoration?.sortIconDecoration?.activeColor ?? Theme.of(context).primaryColor;

      if (sortedColumn?.name != column.name) return Icon(FontAwesomeIcons.arrowDownShortWide, size: 15, color: inactiveColor);
      switch (sortedColumn!.columnSortType) {
        case ColumnSortType.NONE:
          return Icon(FontAwesomeIcons.arrowDownShortWide, size: 15, color: inactiveColor);
        case ColumnSortType.ASC:
          return Icon(FontAwesomeIcons.arrowUpShortWide, size: 15, color: activeColor);
        case ColumnSortType.DESC:
          return Icon(FontAwesomeIcons.arrowDownShortWide, size: 15, color: activeColor);
      }
    }

    return Expanded(
      flex: column.weight,
      child: Container(
          height: 40,
          padding: _DEFAULT_PADDING,
          decoration: BoxDecoration(border: cellBorder),
          child: rowCellBuilder != null
              ? rowCellBuilder(value)
              : Row(
                  children: [
                    Expanded(child: _getWidget()),
                    if (column.sortEnabled) Material(child: InkWell(onTap: () => _tableController.applySort(column), child: _getSortIcon())),
                  ],
                )),
    );
  }

  Border _getHeaderCellBorder(int index) {
    final columnsLength = widget.options.columns.length;
   // final rowsLength = _tableController.tableData.value?.filterResponse.content.length ?? 0;

    final borderAll = Border(top: outerBorderSide, bottom: innerBorderSide, right: innerBorderSide, left: outerBorderSide);
    final borderAllButRightOuter = Border(top: outerBorderSide, bottom: innerBorderSide, right: outerBorderSide, left: outerBorderSide);
    final borderWithoutLeftSide = Border(top: outerBorderSide, bottom: innerBorderSide, right: innerBorderSide);

    if (columnsLength == 1) return borderAll;
    if (columnsLength == 2) {
      return index == 0 ? borderAll : borderAllButRightOuter;
    } else {
      if(index == 0) return borderAll;
      if(index + 1 == columnsLength) return borderAllButRightOuter;
      return borderWithoutLeftSide;
    }
  }

  Border _getRowCellBorder(int index, bool isContent) {
    final columnsLength = widget.options.columns.length;

    final borderWithoutTop = Border(bottom: innerBorderSide, right: innerBorderSide, left: outerBorderSide);
    final borderWithoutLeftSideAndTop = Border(bottom: innerBorderSide, right: isContent ? innerBorderSide : outerBorderSide);
    final borderWithoutLeftAndRightSideAndTop = Border(bottom: innerBorderSide);

    if (isContent) {
      return index + 1 == columnsLength ? borderWithoutLeftAndRightSideAndTop : borderWithoutLeftSideAndTop;
    }

    if (columnsLength == 1) return borderWithoutTop;
    if (columnsLength == 2) {
      return index == 0 ? borderWithoutTop : borderWithoutLeftSideAndTop;
    } else {
      return index != 0 && index + 1 != columnsLength ? borderWithoutLeftSideAndTop : borderWithoutTop;
    }
  }

  void _handleFilterTextFieldChange(SmartTableColumn column, String filterValue) {
    final Map<String, dynamic> filterMap = {column.name: filterValue};
    _tableController.applyFilter(filterMap);
  }

  Widget _generateSearchWidgetForColumn(SmartTableColumn column) {
    if(!column.filterEnabled) return Container(height: 40);
    final inputDecoration = InputDecoration(
        fillColor: widget.options.smartTableDecoration?.filterDecoration?.filterTextFieldDecoration?.fillColor ?? Theme.of(context).canvasColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        hintText: column.filterHintText ?? column.title,
        hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
        enabledBorder: widget.options.smartTableDecoration?.filterDecoration?.filterTextFieldDecoration?.enabledBorder ?? OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Colors.black)),
        focusedBorder: widget.options.smartTableDecoration?.filterDecoration?.filterTextFieldDecoration?.focusedBorder ?? OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme.of(context).primaryColor)));

    switch (column.columnType) {
      case ColumnType.STRING:
        return SmartTableSortTextField(onChanged: (newValue) => _handleFilterTextFieldChange(column, newValue), decoration: inputDecoration, enabled: column.filterEnabled);
      case ColumnType.NUMERIC:
        return SmartTableSortTextField(textInputType: TextInputType.number, onChanged: (newValue) => _handleFilterTextFieldChange(column, newValue), decoration: inputDecoration, enabled: column.filterEnabled);
      case ColumnType.DATE:
      case ColumnType.BOOLEAN:
        return const Text("FilterWidget");
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.options.smartTableDecoration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartTableHeader<T>(tableController: _tableController, smartTableDecoration: decoration, onAddNewElement: widget.onAddNewElement),
        Obx(
          () => Row(
            children: widget.options.columns.indexedMap((c, i) => _buildCell(c.title, c, _getHeaderCellBorder(i))).toList(),
          ),
        ),
        Row(
          children: widget.options.columns.indexedMap((c, i) => _buildCell(null, c, _getHeaderCellBorder(i), rowCellBuilder: (_) => _generateSearchWidgetForColumn(c))).toList(),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: decoration?.color,
                boxShadow: decoration?.boxShadow,
                gradient: decoration?.gradient,
                image: decoration?.image,
                border: Border(left: outerBorderSide, right: outerBorderSide, bottom: innerBorderSide)),
            child: Obx(
              () => _tableController.tableData.value == null
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                  : _tableController.tableData.value?.filterResponse.totalCount == 0 ? const Align(
                  alignment: Alignment.center,
                  child: Text("Nincs találat!")) : ListView(
                      children: [
                        ..._tableController.tableData.value!.filterResponse.content.indexedMap((e, rowIndex) => Material(
                          child: InkWell(
                            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(e),
                            onLongPress: widget.onRemoveElement == null ? null : () async{
                              final result = await showAnimatedDialog(context: context, builder: (context) => RemoveDialog(removeElement:  widget.options.itemToString == null ? e.toString() : widget.options.itemToString!(e)), animationType: DialogTransitionType.scale);
                              if(result == true) widget.onRemoveElement!(e);
                              },
                            child: Row(
                                  children: [
                                    ...widget.options.columns.indexedMap((c, i) {
                                      return _buildCell(e, c, _getRowCellBorder(i, true), rowCellBuilder: widget.rows[c.name]);
                                    }),
                                  ],
                                ),
                          ),
                        ))
                      ],
                    ),
            ),
          ),
        ),
        SmartTableFooter(tableController: _tableController, smartTableDecoration: decoration)
      ],
    );
  }
}

class SmartTableFooter extends StatelessWidget {
  final SmartTableController tableController;
  final SmartTableDecoration? smartTableDecoration;

  SmartTableFooter({Key? key, required this.tableController, this.smartTableDecoration}) : super(key: key);

  final ButtonStyle inactiveButtonStyle = ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey));
  final ButtonStyle activeButtonStyle = ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.green), textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)));

  List<int> _getPages(int? totalPage, int? currentPage) {
    if (totalPage == null || currentPage == null) return [];
    final listPages = List.generate(totalPage, (index) => index + 1);
    if (listPages.isNotEmpty && listPages.length >= 5) {
      if (currentPage == 1 || (currentPage != 1 && currentPage <= 3)) {
        return listPages.sublist(0, 5);
      } else if (currentPage + 2 > listPages.length) {
        return listPages.sublist(listPages.length - 5, listPages.length);
      } else {
        return listPages.sublist(currentPage - 3, currentPage + 2);
      }
    }
    return listPages;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPage = tableController.currentTablePage.value.page;
      final totalPages = tableController.totalPages ?? 0;
      final outerBorderSide = smartTableDecoration?.outerBorder ?? BorderSide(color:Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black);

      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(border: Border(left: outerBorderSide, right: outerBorderSide, bottom: outerBorderSide)),
        child: Row(
          children: [
            TextButton(
                onPressed: currentPage != 0 ? () => tableController.setPage(TablePageData.first()) : null,
                style: inactiveButtonStyle,
                child: Icon(Icons.first_page, color: currentPage != 0 ? Colors.black : Colors.grey, size: 25)),
            const SizedBox(width: 16.0),
            TextButton(
                onPressed: currentPage != 0 ? () => tableController.setPage(TablePageData.fromPage(currentPage - 1)) : null,
                style: inactiveButtonStyle,
                child: Icon(Icons.navigate_before, color: currentPage != 0 ? Colors.black : Colors.grey, size: 25)),
            const Spacer(),
            ..._getPages(tableController.totalPages ?? 0, currentPage)
                .map((e) => TextButton(
                    style: currentPage + 1 == e ? activeButtonStyle : inactiveButtonStyle, onPressed: () => tableController.setPage(TablePageData.fromPage(e - 1)), child: Text((e).toString())))
                .toList(),
            const Spacer(),
            TextButton(
                onPressed: currentPage + 1 != totalPages && totalPages != 0 ? () => tableController.setPage(TablePageData.fromPage(currentPage + 1)) : null,
                style: inactiveButtonStyle,
                child: Icon(Icons.navigate_next, color: currentPage + 1 != totalPages && totalPages != 0 ? Colors.black : Colors.grey, size: 25)),
            const SizedBox(width: 16.0),
            TextButton(
                onPressed: currentPage + 1 != totalPages && totalPages != 0 ? () => tableController.setPage(TablePageData.fromPage(totalPages)) : null,
                style: inactiveButtonStyle,
                child: Icon(Icons.last_page, color: currentPage + 1 != totalPages && totalPages != 0 ? Colors.black : Colors.grey, size: 25)),
          ],
        ),
      );
    });
  }
}

class SmartTableHeader<T> extends StatelessWidget {
  final SmartTableController tableController;
  final SmartTableDecoration? smartTableDecoration;
  final OnAddNewElement<T>? onAddNewElement;

  const SmartTableHeader({Key? key, required this.tableController, this.smartTableDecoration, this.onAddNewElement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.add, color: smartTableDecoration?.headerOptions?.addNewButtonIconColor),
              onPressed: onAddNewElement == null ? null : () async{
            final newElement = await onAddNewElement!();
            await tableController.refreshTable();
          }, label: Text(smartTableDecoration?.headerOptions?.addNewButtonLabel ?? "Új elem hozzáadása"))
        ],
      ),
    );
  }
}

