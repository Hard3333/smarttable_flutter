import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_table_flutter/classes/classes.dart';

class SmartTableSortTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final SmartTableTextFieldDecoration? decoration;
  final bool enabled;
  final TextInputType? textInputType;
  final String hintText;

  const SmartTableSortTextField({Key? key, this.decoration, this.controller, this.onChanged, this.enabled = true, this.textInputType, required this.hintText}) : super(key: key);

  @override
  _SmartTableSortTextFieldState createState() => _SmartTableSortTextFieldState();
}

class _SmartTableSortTextFieldState extends State<SmartTableSortTextField> {
  late TextEditingController controller;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: false,
      enabled: widget.enabled,
      cursorColor: Theme.of(context).primaryColor,
      controller: controller,
      maxLines: widget.decoration?.maxLines,
      keyboardType: widget.textInputType,
      inputFormatters: [
        if(widget.textInputType == TextInputType.number) FilteringTextInputFormatter.digitsOnly
      ],
      style: widget.decoration?.style,
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if(widget.onChanged != null) widget.onChanged!(value);
        });
      },
      decoration: InputDecoration(
          fillColor: widget.decoration?.bgColor ?? Colors.transparent,
          filled: true,
          contentPadding: widget.decoration?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          hintText: widget.hintText,
          suffixIcon: widget.decoration?.suffixIcon,
          hintStyle: widget.decoration?.hintStyle ?? const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: widget.decoration?.disabledBorderColor ?? Colors.grey[400]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: controller.text != "" ? (widget.decoration?.focusedBorderColor ?? Theme.of(context).primaryColor) : (widget.decoration?.borderColor ?? Theme.of(context).dividerColor))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: widget.decoration?.focusedBorderColor ?? Theme.of(context).primaryColor))),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
