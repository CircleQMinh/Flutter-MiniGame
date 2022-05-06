import 'package:flutter/material.dart';

class Barrier extends StatelessWidget {
  final barrierWidth;
  final barrierHeight;
  final barrierX;
  final bool isThisBottomBarrier;

  Barrier(
      {this.barrierHeight,
      this.barrierWidth,
      required this.isThisBottomBarrier,
      this.barrierX});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      width: MediaQuery.of(context).size.width * barrierWidth / 2,
      height: MediaQuery.of(context).size.height * 3 / 4 * barrierHeight / 2,
      decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(width: 10, color: Colors.green.shade800),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}
