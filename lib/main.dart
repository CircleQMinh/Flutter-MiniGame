import 'package:flutter/material.dart';
import 'package:minigame_app/screen/rock_paper_scissors/main.dart';
import 'package:minigame_app/screen/xidach/main.dart';

import 'screen/mainmenu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniGameAPP',
      initialRoute: "/",
      routes: {
        '/': (context) => MainMenuScreen(),
        "/RPS": (context) => RockPaperScissors(),
        "/XiDach": (context) => const BlackJackScreen(),
      },
    );
  }
}
