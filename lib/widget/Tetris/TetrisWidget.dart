import 'dart:math';

import 'package:flutter/material.dart';

import '../../extension/extension.dart';
import '../../model/Tetris/Teris.dart';
import '../../screen/shared/submit.dart';
import 'BrickShape.dart';

class TetrisWidget extends StatefulWidget {
  final Size size;
  final double? sizePerSquare;
  Function(List<BrickObject> brickObjectPos)? setNextBrick;

  TetrisWidget(this.size, {Key? key, this.setNextBrick, this.sizePerSquare})
      : super(key: key);

  @override
  State<TetrisWidget> createState() => TetrisWidgetState();
}

class TetrisWidgetState extends State<TetrisWidget>
    with SingleTickerProviderStateMixin {
  //set animation & controller animation
  //lazy
  late Animation<double>? animation;
  late AnimationController animationController;

  late Size sizeBox;
  late List<int> levelBases;
  // brick hiện tại
  ValueNotifier<List<BrickObject>> listOfBricks =
      ValueNotifier<List<BrickObject>>([]);
  //vị trí đã xong
  ValueNotifier<List<BrickObjectDone>> donePointsValue =
      ValueNotifier<List<BrickObjectDone>>([]);
  ValueNotifier<int> animationPosTickValue = ValueNotifier<int>(0);
  //điểm
  int score = 0;
  @override
  void initState() {
    super.initState();

    //tính độ lớn size của khung chơi
    calculateSizeBox();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addListener(animationLoop);

    animationController.forward();
  }

  calculateSizeBox() {
    //tính size của khung game
    sizeBox = Size(
        (widget.size.width ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
        (widget.size.height ~/ widget.sizePerSquare!) * widget.sizePerSquare!);

    //tính toán vị trí của khung game

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
    if (animation!.isCompleted && listOfBricks.value.length > 1) {
      print("run");
      //lấy brick hiện tại
      BrickObject currentObj =
          listOfBricks.value[listOfBricks.value.length - 2];
      //dịch chuyển xuống 1 ô
      Offset target = currentObj.offset.translate(0, widget.sizePerSquare!);
      //check có đến vị trí cuối chưa

      if (checkTargetMove(target, currentObj)) {
        //nếu ko thì
        currentObj.offset = target; //di chuyển
        currentObj.calculatePointArray(); // tính toán vị trí mới để vẽ gạch
        listOfBricks.notifyListeners();
      } else {
        //đánh dấu hoàn thành
        currentObj.isDone = true;
        //thêm những vị trí của viên gạch vào danh sách hoàn thành
        currentObj.pointArray
            .where((element) => element != -99999)
            .toList()
            .forEach((element) {
          donePointsValue.value
              .add(BrickObjectDone(element, color: currentObj.color));
        });

        donePointsValue.notifyListeners();
        //bỏ viên gạch ra khỏi danh sách gạch hiện tại
        listOfBricks.value.removeAt(listOfBricks.value.length - 2);

        //kiểm tra xem có hoàn thành hàng không
        await checkCompleteLine();

        //check gameover
        bool status = await checkGameOver();
        if (!status) {
          randomBrick();
        } else {
          print("game over");
          endGame();
        }
      }

      listOfBricks.notifyListeners();
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

    //danh sách các điểm bắt đầu bên trái
    List<int> leftIndex = List.generate(numberOfRow, (index) {
      return index * (numberOfCol);
    });

    //số cột không phải là tường
    int totalCol = (sizeBox.width ~/ widget.sizePerSquare!) - 2;

    List<int> lineDestroys = leftIndex
        .where((element) {
          return donePointsValue.value
              .where((point) => point.index == element + 1)
              .isNotEmpty;
        }) //lấy index các dòng có ô kế bên là gạch
        .where((donePoint) {
          List<int> rows =
              List.generate(totalCol, (index) => donePoint + 1 + index)
                  .toList(); //lấy các điểm trên dòng này

          return rows.where((row) {
                return donePointsValue.value
                    .where((element) => element.index == row)
                    .isNotEmpty;
              }).length ==
              rows.length;
          //lấy index các dòng có toàn bộ dòng nằm trong donePointsValue
        })
        .map((e) {
          return List.generate(totalCol, (index) => e + 1 + index).toList();
          //map từ index thành row
        })
        .expand((element) => element)
        .toList();

    List<BrickObjectDone> tempDonePoints = donePointsValue.value;
    //nếu có line thỏa dk
    if (lineDestroys.isNotEmpty) {
      await playLocalSound("clear.mp3");
      lineDestroys.sort(((a, b) => a.compareTo(b)));

      tempDonePoints.sort(((a, b) => a.index.compareTo(b.index)));
      int firstIndex = tempDonePoints
          .indexWhere((element) => element.index == lineDestroys.first);
      if (firstIndex >= 0) {
        tempDonePoints.removeWhere((element) {
          return lineDestroys.where((line) => line == element.index).isNotEmpty;
        });

        donePointsValue.value = tempDonePoints.map((e) {
          if (e.index < lineDestroys.first) {
            int totalRowDelete = lineDestroys.length ~/ totalCol;
            e.index = e.index + ((totalCol + 2) * totalRowDelete);
          }
          return e;
        }).toList();
        var increase = (lineDestroys.length * 10 / (numberOfCol - 2)).ceil();
        score += int.parse(increase.toString());

        donePointsValue.notifyListeners();
      }
    }
  }

  Future<bool> checkGameOver() async {
    return donePointsValue.value
        .where((element) => element.index < 0 && element.index != -99999)
        .isNotEmpty;
  }

  endGame() async {
    animationController.stop();
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
                    builder: (context) => SubmitScoreScreen(0, score),
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

  Future<void> UpdateLocalScore() async {
    var text = await loadUserScoreString(context);

    var data = GetUserScore(text);

    var currentScore = data["tetris"] ?? 0;
    if (score > currentScore) {
      data["tetris"] = score;
    }
    var newData = UserScoreToText(data);
    final file = await localFile;
    file.writeAsString(newData);
  }

  pauseGame() async {
    animationController.stop();
    await showDialog(
      barrierDismissible: false, // user must tap button!
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text("Trò chơi đang tạm dừng"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tiếp tục'),
              onPressed: () {
                Navigator.of(context).pop();
                animationController.forward();
              },
            ),
          ],
          title: const Text("Tạm dừng"),
        ),
      ),
    );
  }

  resetGame() async {
    animationController.stop();
    setState(() {
      score = 0;
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Reset/Start Game'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                donePointsValue.value = [];
                donePointsValue.notifyListeners();
                listOfBricks.value = [];
                listOfBricks.notifyListeners();

                Navigator.of(context).pop();

                calculateSizeBox();
                randomBrick(start: true);
                animationController.reset();
                animationController.stop();
                animationController.forward();
              },
            ),
            TextButton(
              child: const Text('Start'),
              onPressed: () {
                donePointsValue.value = [];
                donePointsValue.notifyListeners();
                listOfBricks.value = [];
                listOfBricks.notifyListeners();

                Navigator.of(context).pop();

                calculateSizeBox();
                randomBrick(start: true);
                animationController.reset();
                animationController.stop();
                animationController.forward();
              },
            ),
          ],
          title: const Text("Reset/Start Game"),
        ),
      ),
    );
  }

  bool checkTargetMove(Offset targetPos, BrickObject object) {
    List<int> pointsPredict = object.calculatePointArray(predict: targetPos);
    List<int> hitsIndex = [];
    //add all wall
    hitsIndex.addAll(levelBases);
    //add all point done
    hitsIndex.addAll(donePointsValue.value.map((e) => e.index));
    //get number hit on point hit
    int numberHitBase = pointsPredict
        .map((e) =>
            hitsIndex.indexWhere((element) => element == e) >
            -1) //lấy ra những point có trùng với tường hoặc gạch khác
        .where((element) => element)
        .length; //lấy tổng số

    return numberHitBase ==
        0; //chấp nhận nếu không đụng vào tường hay gạch khác
  }

  randomBrick({
    start: false,
  }) {
    //start =true generate 2 random brick, =false generate 1
    listOfBricks.value.add(getNewBrickPos());

    if (start) {
      listOfBricks.value.add(getNewBrickPos());
    }

    widget.setNextBrick!.call(listOfBricks.value);
    listOfBricks.notifyListeners();
  }

  BrickObject getNewBrickPos() {
    return BrickObject(
      size: Size.square(widget.sizePerSquare!),
      sizeLayout: sizeBox,
      color:
          Colors.primaries[Random().nextInt(Colors.primaries.length)].shade800,
      rotation: Random().nextInt(4),
      offset: Offset(widget.sizePerSquare! * 4, -widget.sizePerSquare! * 4),
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
          builder: (context, List<BrickObjectDone> donePoints, child) {
            return ValueListenableBuilder(
              valueListenable: listOfBricks,
              builder: (context, List<BrickObject> brickObjects, child) {
                return Stack(
                  children: [
                    //khung chơi
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
                                    ? Colors.black
                                    : Colors.transparent,
                                border: Border.all(width: 0.1)),
                            width: widget.sizePerSquare,
                            height: widget.sizePerSquare,
                            // child: Text(
                            //     "${CheckIndexHitBase(index) ? index : ""}"),
                          ));
                    }).toList(),
                    //show brick
                    if (brickObjects.length > 1)
                      ...brickObjects
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

  transformBrick(Offset? move, bool? rotate) async {
    if (move != null || rotate != null) {
      //get gạch hiện tại
      BrickObject currentObj =
          listOfBricks.value[listOfBricks.value.length - 2];
      late Offset target;
      if (move != null) {
        target = currentObj.offset.translate(move.dx, move.dy);
        if (checkTargetMove(target, currentObj)) {
          currentObj.offset = target;
          await playLocalSound("move.mp3");
          currentObj.calculatePointArray();
          listOfBricks.notifyListeners();
        }
      } else {
        currentObj.calculateRotation(1);
        if (checkTargetMove(currentObj.offset, currentObj)) {
          currentObj.calculatePointArray();
          await playLocalSound("move.mp3");
          listOfBricks.notifyListeners();
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
      border: Border.all(width: 0.1),
    ),
  );
}
