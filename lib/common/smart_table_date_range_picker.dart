import 'package:flutter/material.dart';
import 'package:smart_table_flutter/common/smart_table_sort_text_field.dart';
import 'package:smart_table_flutter/config.dart';
import 'package:intl/intl.dart';

class SmartTableDateRangePicker extends StatefulWidget {
  final ValueChanged<MapEntry<DateTime, DateTime>> onValueChanged;

  const SmartTableDateRangePicker({Key? key, required this.onValueChanged}) : super(key: key);

  @override
  State<SmartTableDateRangePicker> createState() => _SmartTableDateRangePickerState();
}

class _SmartTableDateRangePickerState extends State<SmartTableDateRangePicker> {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async{
          final startDate = DateTime(2022);
          final endDate = DateTime.now();
          final result = await showDateRangePicker(
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
            setState(() => textController.text = "${DateFormat(DEFAULT_DATE_FORMAT).format(result.start)} - ${DateFormat(DEFAULT_DATE_FORMAT).format(result.end)}");
            final mapEntry = MapEntry<DateTime, DateTime>(result.start, result.end);
            widget.onValueChanged(mapEntry);
          }
          /*showCustomDateRangePicker(
            context,
            dismissible: true,
            minimumDate: DateTime.now(),
            maximumDate: DateTime.now().add(const Duration(days: 30)),
            endDate: endDate,
            startDate: startDate,
            onApplyClick: (start, end) {
              textController.text = "${DateFormat(DEFAULT_DATE_FORMAT).format(start)} - ${DateFormat(DEFAULT_DATE_FORMAT).format(end)}";
              final mapEntry = MapEntry<DateTime, DateTime>(start, end);
               widget.onValueChanged(mapEntry);
            },
            onCancelClick: () {},
          );*/
        },
        child: SmartTableSortTextField(controller: textController,
            maxLines: 1,
            enabled: false, hintText: "Adjon meg egy dátumot", suffixIcon: Icon(Icons.calendar_today, color: Theme.of(context).dividerColor)));
  }
}
