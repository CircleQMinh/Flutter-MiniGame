import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minigame_app/extension/extension.dart';
import 'package:minigame_app/screen/ranking.dart';
import 'package:minigame_app/screen/shared/submit.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 80;
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/logo/back1.gif"),
              fit: BoxFit.cover,
            ),
          ),
          // color: const Color(0xFF272837),
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
                        "Flutter",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      circButton(
                          FontAwesomeIcons.info,
                          () => {
                                Fluttertoast.showToast(
                                    msg:
                                        "Phi??n b???n ng??y 13:55 21/05!", // message
                                    toastLength: Toast.LENGTH_SHORT, // length
                                    gravity: ToastGravity.SNACKBAR, // location
                                    timeInSecForIosWeb: 1 // duration
                                    )
                              }),
                      circButton(
                          FontAwesomeIcons.medal,
                          () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RankingScreen(0),
                                  ),
                                )
                              }),
                    ],
                  ),
                  Expanded(
                    child: Scrollbar(
                      isAlwaysShown: true,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            direction: Axis.horizontal,
                            runSpacing: 16,
                            children: [
                              modeButton(
                                  "X?? D??ch",
                                  "Tr?? ch??i x?? d??ch!",
                                  FontAwesomeIcons.heart,
                                  Colors.deepOrange,
                                  width,
                                  "/XiDach"),
                              modeButton(
                                  "Caro",
                                  "Tr?? ch??i caro!",
                                  FontAwesomeIcons.timesCircle,
                                  Colors.blue,
                                  width,
                                  "/tictactoe"),
                              modeButton(
                                  "X???p h??nh",
                                  "Tr?? ch??i x???p h??nh!",
                                  FontAwesomeIcons.square,
                                  Colors.orangeAccent,
                                  width,
                                  "/tetris"),
                              modeButton(
                                  "Con r???n",
                                  "Tr?? ch??i con r???n!",
                                  FontAwesomeIcons.python,
                                  Colors.green,
                                  width,
                                  "/snake"),
                              modeButton(
                                  "B???n bong b??ng",
                                  "Tr?? ch??i b???n bong b??ng!",
                                  FontAwesomeIcons.bowlingBall,
                                  Colors.pink,
                                  width,
                                  "/bubble"),
                              modeButton(
                                  "Flappy Bird",
                                  "Tr?? ch??i flappy bird!",
                                  FontAwesomeIcons.kiwiBird,
                                  Colors.lime,
                                  width,
                                  "/flappy"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Padding circButton(IconData icon, Function()? function) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RawMaterialButton(
        onPressed: function,
        fillColor: Colors.white,
        shape: const CircleBorder(),
        constraints: const BoxConstraints(minHeight: 35, minWidth: 35),
        child: FaIcon(
          icon,
          size: 22,
          color: const Color(0xFF2F3041),
        ),
      ),
    );
  }

  GestureDetector modeButton(String title, String subtitle, IconData icon,
      Color color, double width, String game) {
    return GestureDetector(
      onTap: () => {Navigator.pushNamed(context, game)},
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
}
