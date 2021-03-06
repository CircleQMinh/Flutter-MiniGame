//brick shape
import 'dart:math';

import 'dart:ui';

import 'package:flutter/material.dart';

enum BrickShapeEnum { Square, LShape, RLShape, ZigZag, RZigZag, TShape, Line }

class BrickShapeStatic {
  static List<List<List<double>>> rotateLShape = [
    [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [1, 0, 0]
    ],
    [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 0]
    ]
  ];
  static List<List<List<double>>> rotateRLShape = [
    [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 0, 1]
    ],
    [
      [0, 1, 0],
      [0, 1, 0],
      [1, 1, 0]
    ]
  ];
  static List<List<List<double>>> rotateZigZag = [
    [
      [0, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 1, 0],
      [1, 1, 0],
      [1, 0, 0],
    ],
    [
      [0, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 1, 0],
      [1, 1, 0],
      [1, 0, 0],
    ],
  ];
  static List<List<List<double>>> rotateRZigZag = [
    [
      [0, 0, 0],
      [0, 1, 1],
      [1, 1, 0],
    ],
    [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 0],
    ],
    [
      [0, 0, 0],
      [0, 1, 1],
      [1, 1, 0],
    ],
    [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 0],
    ],
  ];
  static List<List<List<double>>> rotateTShape = [
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 1, 0],
      [1, 1, 0],
      [0, 1, 0],
    ],
  ];
  static List<List<List<double>>> rotateLine = [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
  ];
  //method to get corect rotation
  static List<List<double>> getListBrickOnEnum(BrickShapeEnum shapeEnum,
      {int direction = 0}) {
    List<List<double>> shapeList;
    if (shapeEnum == BrickShapeEnum.Square) {
      shapeList = [
        [1, 1],
        [1, 1]
      ];
    } else if (shapeEnum == BrickShapeEnum.LShape) {
      shapeList = rotateLShape[direction % 4];
    } else if (shapeEnum == BrickShapeEnum.RLShape) {
      shapeList = rotateRLShape[direction % 4];
    } else if (shapeEnum == BrickShapeEnum.ZigZag) {
      shapeList = rotateZigZag[direction % 4];
    } else if (shapeEnum == BrickShapeEnum.RZigZag) {
      shapeList = rotateRZigZag[direction % 4];
    } else if (shapeEnum == BrickShapeEnum.TShape) {
      shapeList = rotateTShape[direction % 4];
    } else if (shapeEnum == BrickShapeEnum.Line) {
      shapeList = rotateLine[direction % 4];
    } else {
      shapeList = [];
    }
    return shapeList;
  }
}

class BrickObjectDone {
  Color? color;
  int index;
  BrickObjectDone(int this.index, {this.color});
}

class BrickObject {
  Offset offset;
  BrickShapeEnum shapeEnum;
  int rotation;
  bool isDone;
  Size? sizeLayout;
  Size? size;
  List<int> pointArray = [];
  Color color;

  BrickObject({
    this.size,
    this.sizeLayout,
    this.isDone: false,
    this.offset: Offset.zero,
    this.shapeEnum: BrickShapeEnum.Line,
    this.rotation: 0,
    this.color: Colors.amber,
  }) {
    calculatePointArray();
  }

  static clone(BrickObject object) {
    return new BrickObject(
        offset: object.offset,
        shapeEnum: object.shapeEnum,
        rotation: object.rotation,
        isDone: object.isDone,
        sizeLayout: object.sizeLayout,
        size: object.size,
        color: object.color);
  }

  calculatePointArray({Offset? predict}) {
    List<int> lists = BrickShapeStatic.getListBrickOnEnum(this.shapeEnum,
            direction: this.rotation)
        // [0, 1, 0],
        // [1, 1, 0],
        // [0, 1, 0],
        .expand((element) => element)
        .map((e) => e.toInt())
        .toList(); //[0,1,0....]
    List<int> tempPoint = lists
        .asMap()
        .entries
        .map((e) => calculateOffset(
            e, lists.length, predict != null ? predict : this.offset))
        .toList();
    //  print(tempPoint);//[101, -99, -999, 114, 115, -999, -999, 128, -99]
    if (predict != null) {
      return tempPoint;
    } else {
      this.pointArray = tempPoint;
    }
  }

  setShape(BrickShapeEnum shapeEnum) {
    this.shapeEnum = shapeEnum;
    calculatePointArray();
  }

  calculateRotation(int flag) {
    this.rotation += flag;
    calculatePointArray();
  }

  int calculateOffset(MapEntry<int, int> entry, int length, Offset offset) {
    int value = entry.value;
    if (this.size != null) {
      if (value == 0) {
        value = -99999;
      } else {
        double left = offset.dx / this.size!.width + entry.key % sqrt(length);
        double top = offset.dy / this.size!.height + entry.key ~/ sqrt(length);
        int index = left.toInt() +
            (top * (this.sizeLayout!.width / size!.width)).toInt();
        value = index.toInt();
      }
    }
    return value;
  }
}
