import 'package:flutter/material.dart';

class SmartTableSortCheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const SmartTableSortCheckbox({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<SmartTableSortCheckbox> createState() => _SmartTableSortCheckboxState();
}

class _SmartTableSortCheckboxState extends State<SmartTableSortCheckbox> {
  bool selectedValue = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Checkbox(value: selectedValue, onChanged: (newValue) {
        setState(() => selectedValue = newValue!);
        widget.onChanged(selectedValue);
      }),
    );
  }
}
