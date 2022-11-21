import 'package:flutter/material.dart';
import 'package:smart_table_flutter/classes/classes.dart';
import 'package:smart_table_flutter/core/smart_table_controller.dart';

class SmartTableDialog<T> extends StatelessWidget {
  final T value;
  final SmartTableOptions<T> smartTableOptions;
  final SmartTableController<T> controller;

  const SmartTableDialog({Key? key, required this.smartTableOptions, required this.value, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Lehetőségek", textAlign: TextAlign.center),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(smartTableOptions.customMenuItemsBuilder != null) ...smartTableOptions.customMenuItemsBuilder!(value),
            if(smartTableOptions.onRemoveElement != null) Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SmartTableDialogItem(
                  iconWidget: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  title: "Törlés",
                  onPressed: () async{
                    final result = await smartTableOptions.onRemoveElement!(value);
                    if(result == true) controller.refreshTable();
                  }),
            ),
            if(smartTableOptions.onElementModify != null) Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SmartTableDialogItem(
                  icon: Icons.edit,
                  title: "Módosítás",
                  onPressed: () async{
                    final result = await smartTableOptions.onElementModify!(value);
                    if(result == true) controller.refreshTable();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SmartTableDialogItem extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final VoidCallback onPressed;
  const SmartTableDialogItem({Key? key, required this.onPressed, this.icon, required this.title, this.iconWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      child: InkWell(
        onTap: (){
          Navigator.pop(context);
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if(icon != null) Icon(icon, color: Theme.of(context).primaryColor, size: 20)
              else iconWidget!,
              const SizedBox(width: 16.0),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ),
        ),
      ),
    );
  }
}
