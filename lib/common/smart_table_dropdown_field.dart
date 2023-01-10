import 'package:flutter/material.dart';
import 'package:smart_table_flutter/classes/classes.dart';
import 'package:smart_table_flutter/extensions/dropdown_plus/dropdown_plus.dart';

class SmartTableDropdownField<T> extends StatefulWidget {
  final Future<List<T>> Function(String str) findFn;
  final String title;
  final void Function(T? item)? onChanged;
  final String Function(T item)? itemToString;
  final bool inverseBg;
  final T? value;
  final bool loadFirstItem;
  final Future<void> Function()? onEmptyCreate;
  final SmartTableDropdownDecoration? decoration;

  const SmartTableDropdownField({Key? key, required this.findFn, required this.title, this.onChanged, required this.itemToString, this.inverseBg = false, this.value, this.loadFirstItem = false, this.onEmptyCreate, this.decoration}) : super(key: key);

  @override
  State<SmartTableDropdownField<T>> createState() => _SmartTableDropdownFieldState<T>();
}

class _SmartTableDropdownFieldState<T> extends State<SmartTableDropdownField<T>> {
  final DropdownEditingController<T> controller = DropdownEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.value != null) controller.value = widget.value;
    if(widget.loadFirstItem){
      widget.findFn("").then((List<T> list) {
        if(list.isNotEmpty) {
          setState(() => controller.value = list.first);
          if(widget.onChanged != null) widget.onChanged!(controller.value!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: DropdownFormField<T>(
        onEmptyActionPressed: widget.onEmptyCreate,
        emptyText: "Nincs találat",
        emptyActionText: "Létrehozás",
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey[400]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            filled: true,
            contentPadding: const EdgeInsets.only(left: 8.0,right: 8.0,top:8.0),
            hintStyle: widget.decoration?.hintStyle ?? const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
            fillColor: widget.decoration?.bgColor ?? Colors.transparent,
            hintText: widget.title,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            focusColor: widget.decoration?.focusColor ?? Theme.of(context).primaryColor,
            alignLabelWithHint: false),
        onSaved: (str) {},
        onChanged: (dynamic str) => widget.onChanged != null ? widget.onChanged!(str) : {},
        displayItemFn: (dynamic item) => Row(
          children: [
            Text(
              item != null ? (widget.itemToString != null ? widget.itemToString!(item) : item.toString()) : "",
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            if(controller.value != null) InkWell(
                onTap: () {
                  widget.onChanged!(null);
                  controller.value = null;
                },
                child: Icon(Icons.clear,size: 18 ,color: Theme.of(context).disabledColor))
          ],
        ),
        controller: controller,
        dropdownColor: widget.decoration?.dropdownColor ?? (widget.decoration?.bgColor ?? Colors.white),
        dropdownBorderColor: widget.decoration?.dropdownBorderColor ?? (widget.decoration?.bgColor ?? Colors.white),
        findFn: widget.findFn,
        dropdownItemFn: (dynamic item, position, focused,
            dynamic lastSelectedItem, onTap) =>
            Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                title: Text(widget.itemToString != null ? widget.itemToString!(item) : item.toString(), style: Theme.of(context).textTheme.bodyMedium),
                tileColor: focused ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                onTap: onTap,
              ),
            ),
      ),
    );
  }
}
