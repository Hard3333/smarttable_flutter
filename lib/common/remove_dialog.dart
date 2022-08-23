import 'package:flutter/material.dart';

class RemoveDialog extends StatelessWidget {
  final String removeElement;

  const RemoveDialog({Key? key,required this.removeElement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Elem eltávolítása")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Biztosan el szeretnéd távolítani a következő elemet: $removeElement?"),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Mégsem"))),
              const SizedBox(width: 16.0),
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Igen")))
            ],
          )
        ],
      ),
    );
  }
}
