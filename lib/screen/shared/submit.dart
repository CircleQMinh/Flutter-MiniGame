import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minigame_app/extension/extension.dart';
import 'package:minigame_app/model/shared/ranking.dart';

import '../../widget/shared/submitForm.dart';

class SubmitScoreScreen extends StatefulWidget {
  int gameIndex;
  int score;
  SubmitScoreScreen(this.gameIndex, this.score);
  @override
  SubmitScoreState createState() => SubmitScoreState();
}

class SubmitScoreState extends State<SubmitScoreScreen> {
  List<String> listOfGame = ["tetris", "xidach", "snake", "bird", "bubble"];
  List<RankingInfo> listItems = [];
  Map<String, int> userScore = {};

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          color: const Color(0xFF272837),
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
                        "Hãy nhập tên của bạn",
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 18.0, right: 10, left: 10),
                        child: SubmitScoreForm(
                            widget.score, listOfGame[widget.gameIndex]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
