import 'package:flutter/material.dart';

class ShowPoint extends StatelessWidget {
  final text;
  ShowPoint({ this.text });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
                color: Colors.yellow.shade100,
                width: 50,
                height: 50,
                child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                      text.toString(),
                    style: TextStyle(fontStyle: FontStyle.normal, fontSize: 20),
                  ),
                )
            )
        )
    );
  }
}