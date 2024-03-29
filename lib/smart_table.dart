import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smart_table_flutter/classes/classes.dart';
import 'package:smart_table_flutter/common/smart_table_date_picker.dart';
import 'package:smart_table_flutter/common/smart_table_date_range_picker.dart';
import 'package:smart_table_flutter/common/smart_table_dialog.dart';
import 'package:smart_table_flutter/common/smart_table_dropdown_field.dart';
import 'package:smart_table_flutter/common/smart_table_sort_checkbox.dart';
import 'package:smart_table_flutter/common/smart_table_sort_text_field.dart';
import 'package:smart_table_flutter/core/smart_table_controller.dart';
import 'package:smart_table_flutter/core/utils.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
export 'package:smart_table_flutter/classes/classes.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

typedef OnControllerCreated<T> = Function(SmartTableController<T> smartTableController);
typedef OnAddNewElement<T> = FutureOr<T?> Function();
typedef CustomHeaderBuilder = Widget Function();
typedef OnRemoveElement<T> = Future<bool> Function(T element);
typedef OnElementModify<T> = Future<bool> Function(T element);

// ignore: constant_identifier_names
const EdgeInsets _DEFAULT_PADDING = EdgeInsets.all(8.0);

class SmartTable<T> extends StatefulWidget {
  final DataSource<T> dataSource;
  final SmartTableOptions<T> options;
  final OnControllerCreated<T>? onControllerCreated;
  final OnTableError? onTableError;
  final int? pageSize;
  final Map<String, RowCellBuilder<T>> rows;

  const SmartTable({Key? key, required this.dataSource, required this.options, this.onControllerCreated, this.onTableError, this.pageSize, required this.rows}) : super(key: key);

  @override
  State<SmartTable<T>> createState() => SmartTableState<T>();
}

class SmartTableState<T> extends State<SmartTable<T>> {
  late SmartTableController<T> _tableController;

  final List<T> selectedElements = <T>[];

  @override
  void initState() {
    super.initState();
    _tableController = SmartTableController<T>(dataSource: widget.dataSource, onTableError: widget.onTableError, pageSize: widget.pageSize);
    _tableController.init();
    if (widget.onControllerCreated != null) widget.onControllerCreated!(_tableController);

    selectedElements.addAll(widget.options.selectedElements ?? <T>[]);
  }

  @override
  void didUpdateWidget(covariant SmartTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedElements.clear();
    selectedElements.addAll(widget.options.selectedElements ?? <T>[]);
  }

  Future<void> exportDataToCsv(String fileName, Function(dynamic data, int columnIndex) generator, int columnNumber, List<String> headerRow, {bool? exportOnlyCurrentPageData}) async{
    final dataRows = await _tableController.exportDataRowsToCsvFormat(generator, columnNumber, exportOnlyCurrentPageData: exportOnlyCurrentPageData);

    const conv = ListToCsvConverter();

    // A fejléc listája
    dataRows.insert(0, headerRow);

    final csv = conv.convert(dataRows);

    if(kIsWeb){
      final blob = html.Blob([csv]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  Widget _buildCell(T? value, SmartTableColumn column, int rowIndex ,{RowCellBuilder<T>? rowCellBuilder, bool isSearchRow = false}) {
    Widget getHeaderWidget() {
      return Text(column.title, style: Theme
          .of(context)
          .textTheme
          .titleMedium);
    }

    Widget getSelectionWidget(){
      final elementIsSelected = selectedElements.contains(value);
      return isSearchRow ? _generateSearchWidgetForColumn(column) : value == null ? getHeaderWidget() : Checkbox(
          activeColor: widget.options.decoration?.sortIconDecoration?.activeColor ?? Theme.of(context).primaryColor,
          value: elementIsSelected, onChanged: (isSelected) {
            print("isSelected:$isSelected");
        if(isSelected == true){
          if(elementIsSelected) {
            //DO NOTHING
          } else {
            selectedElements.add(value!);
          }
        }else if(isSelected == false) {
          selectedElements.removeWhere((e) => e == value);
        }
        if(widget.options.onSelectionChanged != null) widget.options.onSelectionChanged!(selectedElements);
      });
    }
    
    Icon getSortIcon() {
      final sortedColumn = _tableController.sortedColumn.value;
      final inactiveColor = widget.options.decoration?.sortIconDecoration?.inactiveColor ?? Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color ?? Colors.black;
      final activeColor = widget.options.decoration?.sortIconDecoration?.activeColor ?? Theme
          .of(context)
          .primaryColor;

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

    return Container(
        padding: _DEFAULT_PADDING,
        child: rowCellBuilder != null
            ? rowCellBuilder(value!)
            : isSearchRow
            ? _generateSearchWidgetForColumn(column)
            : column.columnType == ColumnType.SELECTION ? getSelectionWidget() : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            getHeaderWidget(),
            const Spacer(),
            if (column.filterOptions.sortEnabled) Material(color: Colors.transparent, child: InkWell(onTap: () => _tableController.applySort(column), child: getSortIcon())),
          ],
        ));
  }

  void _handleFilterChange(SmartTableColumn column, dynamic filterValue) {
    final Map<String, dynamic> filterMap = {column.name: filterValue};
    _tableController.applyFilter(filterMap);
  }

  Widget _generateSearchWidgetForColumn(SmartTableColumn column) {
    if (!column.filterOptions.filterEnabled && column.columnType != ColumnType.SELECTION) return Container(height: 0);
    final inputDecoration = InputDecoration(
        fillColor: widget.options.decoration?.filterDecoration?.filterTextFieldDecoration?.fillColor ?? Theme
            .of(context)
            .canvasColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        hintText: column.filterOptions.filterHintText ?? column.title,
        hintStyle: Theme
            .of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: Colors.grey),
        enabledBorder: widget.options.decoration?.filterDecoration?.filterTextFieldDecoration?.enabledBorder ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Colors.black)),
        focusedBorder: widget.options.decoration?.filterDecoration?.filterTextFieldDecoration?.focusedBorder ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme
                .of(context)
                .primaryColor)));

    switch (column.columnType) {
      case ColumnType.STRING:
        return SmartTableSortTextField(
            onChanged: (newValue) => _handleFilterChange(column, newValue),
            hintText: column.title,
            decoration: widget.options.decoration?.textFieldDecoration,
            enabled: column.filterOptions.filterEnabled);
      case ColumnType.NUMERIC:
        return SmartTableSortTextField(
            hintText: column.title,
            decoration: widget.options.decoration?.textFieldDecoration,
            textInputType: TextInputType.number,
            onChanged: (newValue) => _handleFilterChange(column, newValue),
            enabled: column.filterOptions.filterEnabled);
      case ColumnType.DATE:
        return SmartTableDatePicker(onValueChanged: (DateTime value) => _handleFilterChange(column, value));
      case ColumnType.DATE_RANGE:
        return SmartTableDateRangePicker(onValueChanged: (MapEntry<DateTime, DateTime> value) => _handleFilterChange(column, value));
      case ColumnType.BOOLEAN:
        return SmartTableSortCheckbox(onChanged: (bool value) => _handleFilterChange(column, value));
      case ColumnType.DROPDOWN:
        return SmartTableDropdownField<dynamic>(
            decoration: widget.options.decoration?.dropdownDecoration,
            title: column.title, itemToString: column.filterOptions.itemToString, findFn: column.filterOptions.onFind!, onChanged: (value) => _handleFilterChange(column, value));
      case ColumnType.SELECTION: return IconButton(onPressed: () {
        if(selectedElements.length == _tableController.tableData.value!.filterResponse.content.length){
          selectedElements.clear();
        }else {
          selectedElements.clear();
          selectedElements.addAll(_tableController.tableData.value!.filterResponse.content);
        }
        if(widget.options.onSelectionChanged != null) widget.options.onSelectionChanged!(selectedElements);
      }, icon: Icon(selectedElements.length == _tableController.tableData.value?.filterResponse.content.length ? Icons.deselect : Icons.select_all, color: widget.options.decoration?.sortIconDecoration?.activeColor ?? Theme.of(context).primaryColor));
    }
  }

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  final GlobalKey _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final decoration = widget.options.decoration;
    return Container(
      color: decoration?.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              child: SmartTableHeader<T>(
                tableController: _tableController,
                options: widget.options,
              )),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  Scrollbar(
                    controller: _horizontalScrollController,
                    child: ListView(scrollDirection: Axis.vertical, controller: _horizontalScrollController, children: [
                      SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: Obx(
                                () =>
                                Table(
                                    key: _tableKey,
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    border: TableBorder.all(borderRadius: BorderRadius.circular(16.0), color: widget.options.decoration?.borderColor ?? Theme
                                        .of(context)
                                        .dividerColor),
                                    columnWidths: widget.options.columns.indexedMap((c, i) => c.columnWidth ?? (i == 0 ? const IntrinsicColumnWidth() : const IntrinsicColumnWidth(flex: 1))).toList().asMap(),
                                    children: [
                                      TableRow(
                                          children: widget.options.columns.indexedMap((c, i) {
                                            return _buildCell(null, c, i);
                                          }).toList()),
                                      if (widget.options.columns.any((c) => c.filterOptions.filterEnabled))
                                        TableRow(
                                            children: widget.options.columns.indexedMap((c, i) {
                                              return _buildCell(null, c, i, isSearchRow: true);
                                            }).toList()),
                                      /*             if(_tableController.tableData.value?.filterResponse.totalCount == 0) TableRow(
                                        children: [

                                          ...widget.options.columns.take(widget.options.columns.length - 1).map((e) => Container()).toList(),
                                        ]
                                    ),*/
                                      ..._tableController.tableData.value?.filterResponse.content.indexedMap((e, rowIndex) {
                                        final rowColor = decoration?.rowDecoration?.rowColor ?? Colors.transparent;
                                        final secondaryRowColor = decoration?.rowDecoration?.secondaryRowColor;
                                        return TableRow(
                                            decoration: BoxDecoration(
                                                borderRadius: _tableController.tableData.value?.filterResponse.content.length == rowIndex + 1
                                                    ? const BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
                                                    : null,
                                                color: secondaryRowColor == null ? rowColor : (rowIndex % 2 != 0 ? secondaryRowColor : rowColor)),
                                            children: [
                                              ...widget.options.columns.indexedMap((c, i) {
                                                return TableRowInkWell(
                                                    onTap: () async {
                                                      final customItems = widget.options.customMenuItemsBuilder != null ? widget.options.customMenuItemsBuilder!(e) : <SmartTableDialogItem>[];
                                                      if (customItems.isEmpty && widget.options.onElementModify == null && widget.options.onRemoveElement == null) return;
                                                      if (customItems.isEmpty && widget.options.onElementModify != null && widget.options.onRemoveElement == null) {
                                                        final result = await widget.options.onElementModify!(e);
                                                        if (result == true) _tableController.refreshTable();
                                                        return;
                                                      }
                                                      if (customItems.length == 1 && widget.options.onElementModify == null && widget.options.onRemoveElement == null) {
                                                        customItems.first.onPressed();
                                                      } else {
                                                        showAnimatedDialog(
                                                            barrierDismissible: true,
                                                            context: context,
                                                            builder: (context) => SmartTableDialog<T>(smartTableOptions: widget.options, controller: _tableController, value: e),
                                                            animationType: DialogTransitionType.scale);
                                                      }
                                                    },
                                                    child: _buildCell(e, c, i, rowCellBuilder: widget.rows[c.name]));
                                              }),
                                            ]);
                                      }).toList() ??
                                          [],
                                    ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Obx(() =>
                  _tableController.tableData.value?.filterResponse.totalCount == 0
                      ? Positioned.fill(
                    child: Center(child: Text("Nincs találat!", style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge)),
                  )
                      : Container()),
                  Obx(() =>
                  _tableController.tableData.value == null
                      ? Positioned.fill(
                    child: AbsorbPointer(
                      child: Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(16.0)),
                          child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme
                              .of(context)
                              .primaryColor)))),
                    ),
                  )
                      : Container()),
                ],
              );
            }),
          ),
          SmartTableFooter(tableController: _tableController, smartTableDecoration: decoration)
        ],
      ),
    );
  }
}

class SmartTableFooter extends StatelessWidget {
  final SmartTableController tableController;
  final SmartTableDecoration? smartTableDecoration;

  const SmartTableFooter({Key? key, required this.tableController, this.smartTableDecoration}) : super(key: key);

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

      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            TextButton(
                onPressed: currentPage != 0 ? () => tableController.setPage(TablePageData.first()) : null,
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
                child: Icon(Icons.first_page, color: currentPage != 0 ? Colors.black : Colors.grey, size: 25)),
            const SizedBox(width: 16.0),
            TextButton(
                onPressed: currentPage != 0 ? () => tableController.setPage(TablePageData.fromPage(currentPage - 1)) : null,
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
                child: Icon(Icons.navigate_before, color: currentPage != 0 ? Colors.black : Colors.grey, size: 25)),
            const Spacer(),
            ..._getPages(tableController.totalPages ?? 0, currentPage)
                .map((e) =>
                InkWell(
                    onTap: () => tableController.setPage(TablePageData.fromPage(e - 1)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(e.toString(), style: TextStyle(color: currentPage + 1 == e ? Theme
                          .of(context)
                          .primaryColor : Colors.black, fontWeight: currentPage + 1 == e ? FontWeight.bold : FontWeight.normal)),
                    )))
                .toList(),
            const Spacer(),
            TextButton(
                onPressed: currentPage + 1 != totalPages && totalPages != 0 ? () => tableController.setPage(TablePageData.fromPage(currentPage + 1)) : null,
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
                child: Icon(Icons.navigate_next, color: currentPage + 1 != totalPages && totalPages != 0 ? Colors.black : Colors.grey, size: 25)),
            const SizedBox(width: 16.0),
            TextButton(
                onPressed: currentPage + 1 != totalPages && totalPages != 0 ? () => tableController.setPage(TablePageData.fromPage(totalPages - 1)) : null,
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
                child: Icon(Icons.last_page, color: currentPage + 1 != totalPages && totalPages != 0 ? Colors.black : Colors.grey, size: 25)),
          ],
        ),
      );
    });
  }
}

class SmartTableHeader<T> extends StatelessWidget {
  final SmartTableController tableController;
  final SmartTableOptions<T> options;

  const SmartTableHeader({Key? key, required this.tableController, required this.options /*, this.customHeaderBuilder*/
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          if (options.onAddNewElement != null || options.headerOptions?.showDisabledAddNewButton == true)
            Row(
              children: [
                TextButton.icon(
                    icon: Icon(Icons.add, color: options.headerOptions?.addNewButtonIconColor),
                    style: TextButton.styleFrom(foregroundColor: Theme
                        .of(context)
                        .primaryColor),
                    onPressed: options.onAddNewElement == null
                        ? null
                        : () async {
                      final newElement = await options.onAddNewElement!();
                      await tableController.refreshTable();
                    },
                    label: Text(options.headerOptions?.addNewButtonLabel ?? "Új elem hozzáadása"))
              ],
            ),
        ],
      ),
    );
  }
}
