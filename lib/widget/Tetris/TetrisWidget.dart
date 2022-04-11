import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/Tetris/Teris.dart';
import 'BrickShape.dart';

class TetrisWidget extends StatefulWidget {
  final Size size;
  final double? sizePerSquare;
  Function(List<BrickObjectPos> brickObjectPos)? setNextBrick;

  TetrisWidget(this.size, {Key? key, this.setNextBrick, this.sizePerSquare})
      : super(key: key);

  @override
  State<TetrisWidget> createState() => TetrisWidgetState();
}

class TetrisWidgetState extends State<TetrisWidget>
    with SingleTickerProviderStateMixin {
  //set animation & controller animation
  late Animation<double>? animation;
  late AnimationController animationController;

  late Size sizeBox;
  late List<int> levelBases;
  //current brick
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>([]);
  //for point already done
  ValueNotifier<List<BrickObjectPosDone>> donePointsValue =
      ValueNotifier<List<BrickObjectPosDone>>([]);
  //declate all param
  ValueNotifier<int> animationPosTickValue = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();

    //calculate size box base size box tetris
    calculateSizeBox();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addListener(animationLoop);

    animationController.forward();
  }

  calculateSizeBox() {
    //sizebox to calculate overall size which need for tetris take place
    sizeBox = Size(
        (widget.size.width ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
        (widget.size.height ~/ widget.sizePerSquare!) * widget.sizePerSquare!);

    //calculate base level ingame

    var numberOfCol = sizeBox.width ~/ widget.sizePerSquare!;
    var numberOfRow = sizeBox.height ~/ widget.sizePerSquare!;
    print("numberOfCol: ${numberOfCol}");
    print("numberOfRow: ${numberOfRow}");
    //bottom
    var bottom = List.generate(sizeBox.width ~/ widget.sizePerSquare!, (index) {
      return (index +
          (sizeBox.width ~/ widget.sizePerSquare!) *
              ((sizeBox.height ~/ widget.sizePerSquare!) - 1));
    });
    levelBases = bottom;
    print("bottom: ${bottom}");
    //left
    var left = List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return index * (sizeBox.width ~/ widget.sizePerSquare!);
    });
    levelBases.addAll(left);
    print("left: ${left}");
    //right
    var right = List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return (index * (sizeBox.width ~/ widget.sizePerSquare!)) +
          (sizeBox.width ~/ widget.sizePerSquare! - 1);
    });
    levelBases.addAll(right);
    print("r: ${right}");
  }

  animationLoop() async {
    if (animation!.isCompleted && brickObjectPosValue.value.length > 1) {
      print("run");
      //get current move
      BrickObjectPos currentObj =
          brickObjectPosValue.value[brickObjectPosValue.value.length - 2];
      //calculate offset target on animate
      Offset target = currentObj.offset.translate(0, widget.sizePerSquare!);
      //check target move exceed wall or base

      if (checkTargetMove(target, currentObj)) {
        currentObj.offset = target;
        currentObj.calculateHit();
        brickObjectPosValue.notifyListeners();
      } else {
        currentObj.isDone = true;

        currentObj.pointArray
            .where((element) => element != -99999)
            .toList()
            .forEach((element) {
          donePointsValue.value
              .add(BrickObjectPosDone(element, color: currentObj.color));
        });

        donePointsValue.notifyListeners();
        //remove second last array
        //show on our layout
        brickObjectPosValue.value
            .removeAt(brickObjectPosValue.value.length - 2);

        //check complete line
        await checkCompleteLine();

        //checkgameover
        bool status = await checkGameOver();
        if (!status) {
          randomBrick();
        } else {
          print("game over");
        }
      }

      brickObjectPosValue.notifyListeners();
      animationController.reset();
      animationController.forward();
    }
    // else {
    //   randomBrick(start: true);
    // }
  }

  checkCompleteLine() async {
    var numberOfCol = sizeBox.width ~/ widget.sizePerSquare!;
    var numberOfRow = sizeBox.height ~/ widget.sizePerSquare!;
    List<int> leftIndex =
        List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return index * (sizeBox.width ~/ widget.sizePerSquare!);
    });

    int totalCol = (sizeBox.width ~/ widget.sizePerSquare!) - 2;

    List<int> lineDestroys = leftIndex
        .where((element) {
          return donePointsValue.value
                  .where((point) => point.index == element + 1)
                  .length >
              0;
        })
        .where((donePoint) {
          List<int> rows =
              List.generate(totalCol, (index) => donePoint + 1 + index)
                  .toList();
          return rows.where((row) {
                return donePointsValue.value
                        .where((element) => element.index == row)
                        .length >
                    0;
              }).length ==
              rows.length;
        })
        .map((e) {
          return List.generate(totalCol, (index) => e + 1 + index).toList();
        })
        .expand((element) => element)
        .toList();

    List<BrickObjectPosDone> tempDonePoints = donePointsValue.value;
    if (lineDestroys.length > 0) {
      lineDestroys.sort(((a, b) => a.compareTo(b)));
      tempDonePoints.sort(((a, b) => a.index.compareTo(b.index)));
      int firstIndex = tempDonePoints
          .indexWhere((element) => element.index == lineDestroys.first);
      if (firstIndex >= 0) {
        tempDonePoints.removeWhere((element) {
          return lineDestroys.where((line) => line == element.index).length > 0;
        });

        donePointsValue.value = tempDonePoints.map((e) {
          if (e.index < lineDestroys.first) {
            int totalRowDelete = lineDestroys.length ~/ totalCol;
            e.index = e.index + ((totalCol + 2) * totalRowDelete);
          }
          return e;
        }).toList();
        donePointsValue.notifyListeners();
      }
    }
  }

  Future<bool> checkGameOver() async {
    return donePointsValue.value
            .where((element) => element.index < 0 && element.index != -99999)
            .length >
        0;
  }

  pauseGame() async {
    animationController.stop();
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          Text("Pause Game"),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                animationController.forward();
              },
              child: Text("Resume"))
        ],
      ),
    );
  }

  resetGame() async {
    animationController.stop();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        children: [
          Text("Reset Game"),
          ElevatedButton(
            onPressed: () {
              donePointsValue.value = [];
              donePointsValue.notifyListeners();
              brickObjectPosValue.value = [];
              brickObjectPosValue.notifyListeners();

              Navigator.of(context).pop();

              calculateSizeBox();
              randomBrick(start: true);
              animationController.reset();
              animationController.stop();
              animationController.forward();
            },
            child: Text("Start/Reset"),
          )
        ],
      ),
    );
  }

  bool checkTargetMove(Offset targetPos, BrickObjectPos object) {
    List<int> pointsPredict = object.calculateHit(predict: targetPos);
    List<int> hitsIndex = [];
    //add all wall
    hitsIndex.addAll(levelBases);
    //add all point done
    hitsIndex.addAll(donePointsValue.value.map((e) => e.index));
    //get number hit on point hit
    int numberHitBase = pointsPredict
        .map((e) => hitsIndex.indexWhere((element) => element == e) > -1)
        .where((element) => element)
        .length;

    return numberHitBase == 0;
  }

  randomBrick({
    start: false,
  }) {
    //start =true generate 2 random brick, =false generate 1
    brickObjectPosValue.value.add(getNewBrickPos());

    if (start) {
      brickObjectPosValue.value.add(getNewBrickPos());
    }

    widget.setNextBrick!.call(brickObjectPosValue.value);
    brickObjectPosValue.notifyListeners();
  }

  BrickObjectPos getNewBrickPos() {
    return BrickObjectPos(
      size: Size.square(widget.sizePerSquare!),
      sizeLayout: sizeBox,
      color:
          Colors.primaries[Random().nextInt(Colors.primaries.length)].shade800,
      rotation: Random().nextInt(4),
      offset: Offset(widget.sizePerSquare! * 4, -widget.sizePerSquare! * 3),
      shapeEnum:
          BrickShapeEnum.values[Random().nextInt(BrickShapeEnum.values.length)],
    );
  }

  @override
  void dispose() {
    animation!.removeListener(animationLoop);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //show generate brick
    return Container(
      alignment: Alignment.center,
      color: Colors.brown,
      child: Container(
        color: Colors.white,
        width: sizeBox.width,
        height: sizeBox.height,
        alignment: Alignment.center,
        child: ValueListenableBuilder(
          valueListenable: donePointsValue,
          builder: (context, List<BrickObjectPosDone> donePoints, child) {
            return ValueListenableBuilder(
              valueListenable: brickObjectPosValue,
              builder: (context, List<BrickObjectPos> brickObjectPoses, child) {
                return Stack(
                  children: [
                    //1st generate box show our grid
                    ...List.generate(
                        sizeBox.width ~/
                            widget.sizePerSquare! *
                            sizeBox.height ~/
                            widget.sizePerSquare!, (index) {
                      return Positioned(
                          left: index %
                              (sizeBox.width / widget.sizePerSquare!) *
                              widget.sizePerSquare!,
                          top: index ~/
                              (sizeBox.width / widget.sizePerSquare!) *
                              widget.sizePerSquare!,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                //wall by list before

                                color: CheckIndexHitBase(index)
                                    ? Colors.black54
                                    : Colors.transparent,
                                border: Border.all(width: 1)),
                            width: widget.sizePerSquare,
                            height: widget.sizePerSquare,
                            // child: Text(
                            //     "${CheckIndexHitBase(index) ? index : ""}"),
                          ));
                    }).toList(),
                    //show brick
                    if (brickObjectPoses.length > 1)
                      ...brickObjectPoses
                          .where((element) => !element.isDone)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (e) => Positioned(
                              left: e.value.offset.dx,
                              top: e.value.offset.dy,
                              child: BrickShape(
                                BrickShapeStatic.getListBrickOnEnum(
                                    e.value.shapeEnum,
                                    direction: e.value.rotation),
                                sizePerSquare: widget.sizePerSquare!,
                                point: e.value.pointArray,
                                color: e.value.color,
                              ),
                            ),
                          )
                          .toList(),
                    if (donePoints.length > 0)
                      ...donePoints.map(
                        (e) => Positioned(
                          left: e.index %
                              (sizeBox.width / widget.sizePerSquare!) *
                              widget.sizePerSquare!,
                          top: (e.index ~/
                                  (sizeBox.width / widget.sizePerSquare!) *
                                  widget.sizePerSquare!)
                              .toDouble(),
                          child: Container(
                            width: widget.sizePerSquare!,
                            height: widget.sizePerSquare!,
                            child: boxBrick(e.color!, text: e.index),
                          ),
                        ),
                      )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  CheckIndexHitBase(int index) {
    return levelBases.indexWhere((element) => element == index) != -1;
  }

  transformBrick(Offset? move, bool? rotate) {
    if (move != null || rotate != null) {
      //get current move
      BrickObjectPos currentObj =
          brickObjectPosValue.value[brickObjectPosValue.value.length - 2];
      late Offset target;
      if (move != null) {
        target = currentObj.offset.translate(move.dx, move.dy);
        if (checkTargetMove(target, currentObj)) {
          currentObj.offset = target;
          currentObj.calculateHit();
          brickObjectPosValue.notifyListeners();
        }
      } else {
        currentObj.calculateRotation(1);
        if (checkTargetMove(currentObj.offset, currentObj)) {
          currentObj.calculateHit();
          brickObjectPosValue.notifyListeners();
        } else {
          currentObj.calculateRotation(-1);
        }
      }
    }
  }
}

Widget boxBrick(Color color, {text: ""}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(width: 1),
    ),
  );
}
