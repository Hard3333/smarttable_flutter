import 'package:flutter/material.dart';
import 'package:smart_table_flutter/common/smart_table_sort_text_field.dart';
import 'package:smart_table_flutter/config.dart';
import 'package:intl/intl.dart';

class SmartTableDatePicker extends StatefulWidget {
  final ValueChanged<DateTime> onValueChanged;

  const SmartTableDatePicker({Key? key, required this.onValueChanged}) : super(key: key);

  @override
  State<SmartTableDatePicker> createState() => _SmartTableDatePickerState();
}

class _SmartTableDatePickerState extends State<SmartTableDatePicker> {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async{
          final startDate = DateTime(2022);
          final endDate = DateTime.now();
          final result = await showDatePicker(
              initialDate: endDate,
              builder: (context, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500,  maxHeight: 700),child: child))
                ],
              ),
              locale: const Locale("hu"),context: context, firstDate: startDate, lastDate: endDate);

          if(result != null){
            setState(() => textController.text = DateFormat(DEFAULT_DATE_FORMAT).format(result));
            widget.onValueChanged(result);
          }
        },
        child: SmartTableSortTextField(
            controller: textController,
            maxLines: 1,
            enabled: false, hintText: "Válasszon ki egy dátumot", suffixIcon: Icon(Icons.calendar_today,size: 16.0 ,color: Theme.of(context).dividerColor)));
  }
}
