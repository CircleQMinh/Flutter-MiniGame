import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minigame_app/model/Tetris/Teris.dart';
import '../../extension/extension.dart';
import '../../widget/Tetris/BrickShape.dart';
import '../../widget/Tetris/TetrisWidget.dart';

class TetrisScreen extends StatefulWidget {
  const TetrisScreen({Key? key}) : super(key: key);

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen> {
  bool _isGameStarted = false;

  GlobalKey<TetrisWidgetState> keyGlobal = GlobalKey();
  ValueNotifier<List<BrickObject>> brickObjects =
      ValueNotifier<List<BrickObject>>(List<BrickObject>.from([]));

  int score = 0;
  int speed = 1;
  late Timer _clockTimer;
  @override
  void initState() {
    const oneSec = Duration(seconds: 1);
    _clockTimer = Timer.periodic(
        oneSec,
        (Timer t) => {
              setState(() {
                if (mounted) {
                  score = keyGlobal.currentState?.score ?? score;
                }
              })
            });
    print("init");
    List<String> sounds = ["clear.mp3", "move.mp3"];
    prepareLocalSound(sounds);
    super.initState();
  }

  void startGame() {
    _isGameStarted = true;

    setState(() {});
  }

  getNewSpeed(int s) {
    s++;
    if (s == 4) {
      s = 0;
    }
    speed = s;
    setState(() {});
  }

  GestureDetector startButton(String title, String subtitle, IconData icon,
      Color color, double width, String game) {
    return GestureDetector(
      onTap: () => {startGame()},
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontFamily: "Manrope",
                          color: Colors.white,
                          fontSize: 18,
                        )),
                  ),
                  Text(subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        fontFamily: "Manrope",
                        color: Colors.white,
                        fontSize: 12,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: FaIcon(
                icon,
                size: 35,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    print("dispose");
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát khỏi game?'),
            content: const Text('Bạn muốn thoát khỏi game?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        )) ??
        false;
  }

  String getSpeedText(int s) {
    switch (s) {
      case 1:
        return "X1";
      case 0:
        return "X0.5";

      case 2:
        return "X2";

      case 3:
        return "X3";

      default:
        return "X1";
    }
  }

  String getPauseString() {
    var bool = keyGlobal.currentState?.pause;
    if (bool == null) {
      return "Pause";
    } else {
      if (bool) {
        return "Continue";
      }
      return "Pause";
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizePerSquare = 30;
    double width = MediaQuery.of(context).size.width - 80;
    String image_src = "assets/logo/tetris.png";
    return WillPopScope(
        child: Scaffold(
          body: _isGameStarted
              ? Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: SafeArea(child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: constraints.biggest.width / 2,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //score and line
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Scores : $score ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          fontFamily: "Manrope",
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateColor
                                                        .resolveWith((states) =>
                                                            Colors.red[900]!)),
                                            onPressed: () {
                                              keyGlobal.currentState!
                                                  .resetGame();
                                            },
                                            child: Text(keyGlobal.currentState
                                                    ?.gameStartBtn ??
                                                "Start")),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateColor
                                                        .resolveWith((states) =>
                                                            Colors.red[900]!)),
                                            onPressed: () {
                                              keyGlobal.currentState!
                                                  .pauseGame();
                                            },
                                            child: Text(getPauseString())),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: constraints.biggest.width / 2,
                                height: constraints.biggest.height / 5,
                                color: Colors.yellow,
                                child: Column(
                                  children: [
                                    //score and line
                                    const Text("Next : "),
                                    //contain box show next tetris

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 10),
                                      child: ValueListenableBuilder(
                                        valueListenable: brickObjects,
                                        builder: (context,
                                            List<BrickObject> value, child) {
                                          BrickShapeEnum tempShapeEnum =
                                              value.isNotEmpty
                                                  ? value.last.shapeEnum
                                                  : BrickShapeEnum.Line;
                                          int rotation = value.isNotEmpty
                                              ? value.last.rotation
                                              : 0;
                                          return BrickShape(
                                            BrickShapeStatic.getListBrickOnEnum(
                                              tempShapeEnum,
                                              direction: rotation,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.green,
                              width: double.maxFinite,
                              child: LayoutBuilder(
                                  builder: ((context, constraints) {
                                return TetrisWidget(
                                    //sent size
                                    // constraints.biggest
                                    Size(
                                        MediaQuery.of(context).size.width,
                                        (MediaQuery.of(context).size.height) -
                                            (MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                7) -
                                            (MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                6) -
                                            sizePerSquare),
                                    key: keyGlobal,
                                    //size per box brick
                                    sizePerSquare: sizePerSquare,
                                    //make callback for next brick show after generate
                                    setNextBrick:
                                        (List<BrickObject> brickObjectPos) {
                                  brickObjects.value = brickObjectPos;
                                  brickObjects.notifyListeners();
                                });
                              })),
                            ),
                          ),
                          //controller
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                color: Colors.red,
                                height: constraints.biggest.height / 6,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                          color: Colors.red,
                                          child: Center(
                                            child: Ink(
                                              decoration: const ShapeDecoration(
                                                color: Colors.lightBlue,
                                                shape: CircleBorder(),
                                              ),
                                              child: IconButton(
                                                onPressed: () async => keyGlobal
                                                    .currentState!
                                                    .transformBrick(
                                                        Offset(
                                                            -sizePerSquare, 0),
                                                        null),
                                                icon: const Icon(
                                                    Icons.arrow_left),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 4),
                                          child: Material(
                                            color: Colors.red,
                                            child: Center(
                                              child: Ink(
                                                decoration:
                                                    const ShapeDecoration(
                                                  color: Colors.lightBlue,
                                                  shape: CircleBorder(),
                                                ),
                                                child: IconButton(
                                                  onPressed: () async =>
                                                      keyGlobal.currentState!
                                                          .transformBrick(
                                                              null, true),
                                                  icon: const Icon(Icons
                                                      .rotate_90_degrees_ccw_outlined),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.red,
                                          child: Center(
                                            child: Ink(
                                              decoration: const ShapeDecoration(
                                                color: Colors.lightBlue,
                                                shape: CircleBorder(),
                                              ),
                                              child: IconButton(
                                                onPressed: () async => keyGlobal
                                                    .currentState!
                                                    .transformBrick(
                                                        Offset(
                                                            sizePerSquare, 0),
                                                        null),
                                                icon: const Icon(
                                                    Icons.arrow_right),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Material(
                                          color: Colors.red,
                                          child: Center(
                                            child: Ink(
                                              decoration: const ShapeDecoration(
                                                color: Colors.lightBlue,
                                                shape: CircleBorder(),
                                              ),
                                              child: IconButton(
                                                onPressed: () async => keyGlobal
                                                    .currentState!
                                                    .transformBrick(
                                                        Offset(
                                                            0, sizePerSquare),
                                                        null),
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text("Speed : "),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) =>
                                                      Colors.red[900]!)),
                                      onPressed: () => {
                                            getNewSpeed(speed),
                                            keyGlobal.currentState!
                                                .changeSpeed(speed.toString())
                                          },
                                      child: Text(getSpeedText(speed))),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )),
                )
              : Scaffold(
                  backgroundColor: Colors.blue,
                  body: Container(
                    color: const Color.fromARGB(255, 94, 205, 224),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Mini-Game",
                                  style: TextStyle(
                                      fontFamily: "Manrope",
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                      fontSize: 36,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 0.7
                                        ..color = Colors.white),
                                ),
                                const Text(
                                  "Xếp hình",
                                  style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                    fontSize: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Center(child: Image.asset(image_src)),
                            Wrap(
                              runSpacing: 16,
                              children: [
                                startButton(
                                    "Start Game!",
                                    "Nhấn để bắt đầu trò chơi",
                                    FontAwesomeIcons.playCircle,
                                    Colors.red,
                                    width,
                                    ""),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        onWillPop: _onWillPop);
  }
}
