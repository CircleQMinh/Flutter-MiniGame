import 'package:flutter/material.dart';

import 'TetrisWidget.dart';

class BrickShape extends StatefulWidget {
  List<List<double>> list;
  List? point;
  double sizePerSquare;
  Color? color;
  BrickShape(this.list,
      {Key? key, this.color, this.point, this.sizePerSquare: 20})
      : super(key: key);

  @override
  _BrickShapeState createState() => _BrickShapeState();
}

class _BrickShapeState extends State<BrickShape> {
  @override
  Widget build(BuildContext context) {
    int totalPointList = widget.list.expand((element) => element).length;
    int columnNumm = (totalPointList ~/ widget.list.length);
    // print("list: ${widget.list}");
    // print("point: ${totalPointList}");
    return Container(
      //height: 20,
      width: widget.sizePerSquare * columnNumm,
      // color: Colors.black,
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: totalPointList,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnNumm,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return Offstage(
              offstage:
                  widget.list.expand((element) => element).toList()[index] == 0,
              child: boxBrick(widget.color ?? Colors.cyan,
                  text: widget.point?[index] ?? ""),
            );
          }),
    );
  }
}
