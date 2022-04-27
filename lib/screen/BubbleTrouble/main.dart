import 'package:flutter/material.dart';
import 'package:minigame_app/screen/BubbleTrouble/BubbleTrouble.dart';

void main() {
  runApp(const BubbleApp());
}

class BubbleApp extends StatelessWidget {
  const BubbleApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BubbleTroublePage()
    );
  }

}