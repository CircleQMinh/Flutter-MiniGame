import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:minigame_app/screen/ranking.dart';

import 'package:minigame_app/screen/BubbleTrouble/main.dart';
import 'package:minigame_app/screen/rock_paper_scissors/main.dart';
import 'package:minigame_app/screen/shared/submit.dart';
import 'package:minigame_app/screen/xidach/main.dart';
import 'package:minigame_app/screen/tictactoe/pages/home/home_page.dart';

import 'screen/mainmenu.dart';
import 'screen/tetris/main.dart';
import 'screen/snake/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MiniGameAPP',
      initialRoute: "/",
      routes: {
        '/': (context) => MainMenuScreen(),
        "/RPS": (context) => RockPaperScissors(),
        "/XiDach": (context) => const BlackJackScreen(),
        "/tictactoe": (context) => const TictactoePage(),
        "/tetris": (context) => const TetrisScreen(),
        "/snake": (context) => const SnakeApp(),

        "/ranking": (context) => RankingScreen(0),
        "/submit": (context) => SubmitScoreScreen(0, 0)

        "/bubble": (context) => const BubbleApp()
      },
    );
  }
}
