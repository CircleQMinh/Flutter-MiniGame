import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minigame_app/screen/flaggyBird/Page/Barrier.dart';
import 'package:minigame_app/screen/flaggyBird/Page/bird.dart';

class HomeFlaggyBirdPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeFlaggyBirdPageState();
  }
}

class _HomeFlaggyBirdPageState extends State<HomeFlaggyBirdPage>{

  static double birdY = 0;
  double birdHeight = 0.2;
  double birdWidth = 0.2;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.9;
  double velocity = 2;

  int score = 0;

  bool gameHasStarted = false;

  static List<double> barrierX = [1, 2.5];
  static double barrierWidth = 0.2;
  List<List<double>> barrierHeight = [
    [0.4, 0.3],
    [0.3, 0.4]
  ];

  double barrierXone = 1;

  void startGame(){
    gameHasStarted = true;
    score = 0;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = gravity * time * time + velocity * time;
      setState(() {
        if(barrierXone < -1.1){
          barrierXone += 3.6;
        } else {
          barrierXone -= 0.03;
        }
        for(int i = 0 ; i < barrierX.length; i++){
          if(barrierX[i] < -1.1){
            barrierX[i] += 3.5;
          } else {
            barrierX[i] -= 0.03;
          }
        }
        birdY = initialPos - height;
      });

      print(birdY);

      if(birdIsDead()){
        timer.cancel();
        gameHasStarted = false;
        _showDialog();
      }

      time += 0.01;
    });

    Timer.periodic(Duration(milliseconds: 1000), (timer1) {
      score++;
      if(birdIsDead()){
        timer1.cancel();
      }
    });
  }

  void resetGame(){
    Navigator.pop(context);
    setState(() {
      birdY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdY;
      barrierX = [2, 2+ 1.5];
    });
  }

  void _showDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: Center(
              child: Text(
                "G A M E  O V E R",
                style: const TextStyle( color: Colors.white),
              ),
            ),
            content: Text(
              "Score: 1",
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    color: Colors.brown,
                    child: Text(
                      'PLAY AGAIN',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          );
        }
    );
  }

  void jump(){
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  bool birdIsDead(){
    if(birdY <= - 1 || birdY > 1){
      return true;
    }

    for(int i = 0; i < barrierX.length; i++){
      if(barrierX[i] <= birdWidth
          && barrierX[i] + barrierWidth >= -birdWidth
          && (birdY <= -0.9 + barrierHeight[i][0] ||  birdY + birdHeight >= 0.9- barrierHeight[i][1]))
      {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  color: Colors.blue,
                  child: Center(child:
                  Stack(
                    children: [
                      Bird(
                          birdY: birdY,
                          birdHeight: MediaQuery.of(context).size.width * birdHeight,
                          birdWidth: MediaQuery.of(context).size.width * birdWidth
                      ),
                      AnimatedContainer(
                          alignment: Alignment(barrierX[0], 1.1),
                          duration: Duration(milliseconds: 0),
                          child: Barrier(
                              barrierX: barrierX[0],
                              barrierWidth: barrierWidth,
                              barrierHeight: barrierHeight[0][0],
                              isThisBottomBarrier: true
                          )
                      ),
                      AnimatedContainer(
                          alignment: Alignment(barrierX[0], -1.1),
                          duration: Duration(milliseconds: 0),
                          child: Barrier(
                              barrierX: barrierX[0],
                              barrierWidth: barrierWidth,
                              barrierHeight: barrierHeight[0][1],
                              isThisBottomBarrier: false
                          )
                      ),

                      AnimatedContainer(
                          alignment: Alignment(barrierX[1], 1.1),
                          duration: Duration(milliseconds: 0),
                          child: Barrier(
                              barrierX: barrierX[1],
                              barrierWidth: barrierWidth,
                              barrierHeight: barrierHeight[1][0],
                              isThisBottomBarrier: true
                          )
                      ),
                      AnimatedContainer(
                          alignment: Alignment(barrierX[1], -1.1),
                          duration: Duration(milliseconds: 0),
                          child: Barrier(
                              barrierX: barrierX[1],
                              barrierWidth: barrierWidth,
                              barrierHeight: barrierHeight[1][1],
                              isThisBottomBarrier: false
                          )
                      ),


                      Container(
                        alignment: Alignment(0, -0.5),
                        child: Text(
                            gameHasStarted ? '' : 'T A P  T O  P L A Y',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20
                            )
                        ),
                      )
                    ],
                  ),
                  ),
                )
            ),
            Expanded(
                child: Container(
                    color: Colors.brown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("SCORE", style: const TextStyle(color: Colors.white, fontSize: 20)),
                            SizedBox(height: 20,),
                            Text(score.toString(), style: const TextStyle(color: Colors.white, fontSize: 35))
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("BEST", style: const TextStyle(color: Colors.white, fontSize: 20)),
                            SizedBox(height: 20,),
                            Text("10", style: const TextStyle(color: Colors.white, fontSize: 35))
                          ],
                        )
                      ],
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}
