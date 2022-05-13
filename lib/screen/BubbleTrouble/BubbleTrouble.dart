import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minigame_app/screen/BubbleTrouble/Ball.dart';
import 'package:minigame_app/screen/BubbleTrouble/Missile.dart';
import 'package:minigame_app/screen/BubbleTrouble/ShowPoint.dart';
import 'package:minigame_app/screen/BubbleTrouble/player.dart';
import 'package:minigame_app/screen/shared/submit.dart';

import 'button.dart';

class BubbleTroublePage extends StatefulWidget{
  @override
  _BubbleTroublePage createState () => _BubbleTroublePage();
}

enum direction { LEFT, RIGHT }

class _BubbleTroublePage extends State<BubbleTroublePage> {

  bool isStartGame = false;

  // vi tri nguoi choi
  static double playerX = 0;

  int point = 0;

  // bien vi tri mui ten
  double missileX = playerX;
  double missileHeight = 10;
  bool missShot = false;

  // Bien ball
  double ballX = 0.5;
  double ballY = 0;

  var ballDirection = direction.LEFT;

  startGame() {

    if(isStartGame) {
      return;
    }
    Random rnd;
    rnd = new Random();
    if(!isStartGame) {
      var isLeft = rnd.nextBool();
      double r = (isLeft ? -1 : 1) * rnd.nextInt(100).toDouble()*0.01;
      setState(() {
        if(ballDirection == direction.LEFT) {
          ballDirection = direction.RIGHT;
        }
        else {
          ballDirection = direction.LEFT;
        }
        playerX = 0;
        missileX = playerX;
        missileHeight = 10;
        missShot = false;
        ballX = r;
        ballY = 0;
        isStartGame = true;
        point = 0;
      });
    }

    double time = rnd.nextInt(100).toDouble()*0.01;
    double height = 0;
    double velocity = 65;

    Timer.periodic(Duration(milliseconds: 10), (timer) {

      height = -4*time*time + velocity*time;

      // Neu cham vao nen thi nhay len lai
      if(height < 0) {
        time = 0;
      }

      // cap nhat vi tri bong
      setState(() {
        ballY = heightToPosition(height);
      });

      time+=0.1;

      // Neu cham vao tuong trai
      if(ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
        // Neu bong cham vao tuong phai
      } else if(ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }

      // Di chuyen bong dung huong
      if(ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if(ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      // Neu bong cham vao nguoi thi chet
      if(playerDead()) {
        timer.cancel();
        setState(() {
          ballX = 0.5;
          isStartGame = false;
        });
        endGame();
      }
    });
  }

  showInfoDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("You dead", style: TextStyle(color: Colors.black))
          );
        }
    );
  }

  bool playerDead () {
    if((ballX - playerX).abs() < 0.15 && ballY > 0.95) {
      return true;
    }
    else {
      return false;
    }
  }

  moveL() {
    if(!isStartGame) {
      return;
    }
    setState(() {
      if(playerX - 0.1 < -1) {
      } else {
        playerX -= 0.1;
      }

      if(!missShot) {
        missileX = playerX;
      }
    });
  }

  moveR() {

    if(!isStartGame) {
      return;
    }

    setState(() {
      if(playerX + 0.1 > 1) {
      } else {
        playerX += 0.1;
      }

      if(!missShot) {
        missileX = playerX;
      }
    });
  }

  fireMissile() {

    if(!isStartGame) {
      return;
    }

    if(!missShot) {
      Timer.periodic(Duration(milliseconds: 15), (timer) {
        // Ban trung
        missShot = true;

        // Vien dan len top man hinh
        setState(() {
          missileHeight += 10;
        });

        // dung vien dan khi no cham vao top Height
        if(missileHeight >= MediaQuery.of(context).size.height*0.6){
          missileX = playerX;
          missileHeight = 10;
          timer.cancel();
          resetMissile();
        }

        // kiem tra neu vien dan cham vao bong
        if(ballY > heightToPosition(missileHeight) &&
          (ballX - missileX).abs() < 0.03) {
          setState(() {
            point += 1;
          });
          resetMissile();
          ballX = 0.5;
          timer.cancel();
        }
      });
    }
  }

  // chuyen doi chieu cao sang toa do
  double heightToPosition(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3/4;
    double position = 1 - 2*height/totalHeight;
    return position;
  }

  resetMissile() {
    setState(() {
      missileX = playerX;
      missileHeight = 10;
      missShot = false;
    });
  }

  endGame() async {
    await showDialog(
      barrierDismissible: false, // user must tap button!
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    "Thành tích của bạn đã được lưu lại. Bạn có muốn chia sẻ thành tích lên bảng xếp hạng?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitScoreScreen(4, point),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          title: const Text("Game Over!"),
        ),
      ),
    );
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/bubble/background.webp"),
                      fit: BoxFit.cover),
                ),
              child: Stack(
                children: [
                  MyBall(ballX: this.ballX, ballY: this.ballY),
                  MyMissle(
                    missileX: this.missileX,
                    height: this.missileHeight
                  ),
                  MyPlayer(playerX: playerX),
                  Positioned(
                      top: 50.0,
                      left: 0.0,
                      right: 0.0,
                      child: ShowPoint(
                        text: "Điểm của bạn: " + point.toString(),
                      )
                  )
                ],
              )
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/bubble/Background.png"),
                    fit: BoxFit.cover),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(icon: Icons.play_arrow, func: startGame),
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