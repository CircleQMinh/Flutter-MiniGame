import 'package:flutter/material.dart';
import 'package:minigame_app/screen/rock_paper_scissors/main.dart';

import 'screen/mainmenu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniGameAPP',
      initialRoute: "/",
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => MainMenuScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        "/RPS": (context) => RockPaperScissors(),
      },
    );
  }
}
