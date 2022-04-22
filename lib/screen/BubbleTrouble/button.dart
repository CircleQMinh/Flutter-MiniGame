import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final icon;
  final func;

  MyButton({ this.icon, this.func });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: Colors.grey.shade100,
              width: 50,
              height: 50,
              child: Center(child: Icon(icon),)
          )
      )
    );
  }
}