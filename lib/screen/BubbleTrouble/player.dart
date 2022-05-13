import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget{
  final playerX;

  MyPlayer({ this.playerX });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(playerX, 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 80,
          width: 50,
          child: Image.asset('assets/bubble/player.png'),
        ),
      ),
    );
  }

}
