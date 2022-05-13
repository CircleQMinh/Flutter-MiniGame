import 'package:flutter/material.dart';

class MyMissle extends StatelessWidget {

  final missileX;
  final height;

  MyMissle({ this.missileX, this.height });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(missileX, 1),
      child: Container(
          width: 2,
          height: height,
          color: Colors.orange
      )
    );
  }
  
}