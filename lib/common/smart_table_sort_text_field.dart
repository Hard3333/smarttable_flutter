import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartTableSortTextField extends StatefulWidget {
  final bool enabled;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final Color? bgColor;
  final InputDecoration? decoration;
  final TextInputType? textInputType;
  final Color? borderColor;
  final bool inverseBgColor;
  final Icon? suffixIcon;

  const SmartTableSortTextField({Key? key, this.enabled = true, this.controller, this.hintText, this.obscureText = false, this.onChanged, this.maxLines, this.bgColor, this.decoration, this.textInputType, this.borderColor, this.inverseBgColor = false, this.suffixIcon}) : super(key: key);

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
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      cursorColor: Theme.of(context).primaryColor,
      controller: controller,
      maxLines: widget.maxLines,
      keyboardType: widget.textInputType,
      inputFormatters: [
        if(widget.textInputType == TextInputType.number) FilteringTextInputFormatter.digitsOnly
      ],
      style: Theme.of(context).textTheme.bodyText1,
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          if(widget.onChanged != null) widget.onChanged!(value);
        });
      },
      decoration: widget.decoration ?? InputDecoration(
          fillColor: widget.bgColor ?? (widget.inverseBgColor ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).canvasColor),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          hintText: widget.hintText,
          suffixIcon: widget.suffixIcon,
          hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme.of(context).canvasColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: controller.text != "" ? Theme.of(context).primaryColor : (widget.borderColor ?? Theme.of(context).canvasColor))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme.of(context).primaryColor))),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
