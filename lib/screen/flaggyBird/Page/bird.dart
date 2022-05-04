import 'package:flutter/material.dart';

class Bird extends StatelessWidget{
  final birdY;
  final double birdHeight;
  final double birdWidth;
  Bird({this.birdY, required this.birdWidth, required this.birdHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, birdY),//(2 * birdY * birdHeight) / (2 - birdHeight)
      child: Image.asset(
        '/flappy.png',
        width: birdWidth,
        height: birdHeight,
      ),
    );
  }
}