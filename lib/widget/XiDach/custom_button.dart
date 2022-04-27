import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Icon icon;
  const CustomButton(
      {required this.onPressed, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.yellow),
      ),
      icon: icon,
      onPressed: onPressed,
      label: Text(label, style: TextStyle(color: Colors.black)),
    );
  }
}
