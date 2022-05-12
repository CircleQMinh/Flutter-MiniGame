import 'dart:convert';
import 'dart:async' show Future;
import 'dart:io';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:minigame_app/extension/extension.dart';
import 'package:minigame_app/model/shared/ranking.dart';
import 'package:minigame_app/screen/xidach/hostonline.dart';
import 'package:minigame_app/screen/xidach/joinonline.dart';
import 'package:path_provider/path_provider.dart';

class XDOnlineScreen extends StatefulWidget {
  XDOnlineScreen();
  @override
  XDOnlineScreenState createState() => XDOnlineScreenState();
}

class XDOnlineScreenState extends State<XDOnlineScreen> {
  TextEditingController _textFieldController = TextEditingController();
  GestureDetector startButton(String title, String subtitle, IconData icon,
      Color color, double width, String game, Function fun) {
    return GestureDetector(
      onTap: () => {fun()},
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

  void FindMatch() {}
  void CreateMatch() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostMatchOnlineScreen(
          isHost: true,
        ),
      ),
    );
  }

  void JoinMatch() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinMatchOnlineScreen(
          isHost: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 80;
    String image_src = "assets/logo/blackjack.png";
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        color: Color.fromARGB(255, 102, 111, 228),
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
                      "Xì Dách",
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
                Container(
                  child: Center(child: Image.asset(image_src)),
                ),
                Expanded(
                  child: Scrollbar(
                    isAlwaysShown: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Wrap(
                          runSpacing: 16,
                          children: [
                            startButton(
                                "Tạo trận Online!",
                                "Tạo trận đâu online",
                                FontAwesomeIcons.playCircle,
                                Colors.green,
                                width,
                                "",
                                CreateMatch),
                            startButton(
                                "Vào trận Online!",
                                "Vào trận đâu online đã tạo",
                                FontAwesomeIcons.playCircle,
                                Colors.green,
                                width,
                                "",
                                JoinMatch),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
