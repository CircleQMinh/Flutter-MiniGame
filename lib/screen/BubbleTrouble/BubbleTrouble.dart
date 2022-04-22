import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minigame_app/screen/BubbleTrouble/player.dart';

import 'button.dart';

class BubbleTroublePage extends StatefulWidget{
  @override
  _BubbleTroublePage createState () => _BubbleTroublePage();
}

class _BubbleTroublePage extends State<BubbleTroublePage> {
  // vi tri nguoi choi
  double playerX = 0;

  // bien vi tri mui ten
  double missibleX = 0;
  double missibleY = 1;

  moveL() {
    print('Left');
    setState(() {
      if(playerX - 0.1 < -1) {
      } else {
        playerX -= 0.1;
      }
    });
  }

  moveR() {
    print('Right');

    setState(() {
      if(playerX + 0.1 > 1) {
      } else {
        playerX += 0.1;
      }
    });
  }

  fireMissile() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        missibleY -= 0.1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveL();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveR();
        }

        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.pink.shade100,
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment(missibleX, missibleY),
                    child: Container(
                        width: 30,
                        height: 30,
                        color: Colors.red
                    ),
                  ),
                  MyPlayer(playerX: this.playerX)
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
                color: Colors.grey.shade500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(icon: Icons.arrow_back, func: moveL),
                  MyButton(icon: Icons.arrow_upward, func: fireMissile),
                  MyButton(icon: Icons.arrow_forward, func: moveR)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
}