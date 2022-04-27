import 'dart:convert';
import 'dart:async' show Future;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minigame_app/extension/extension.dart';
import 'package:minigame_app/model/shared/ranking.dart';
import 'package:path_provider/path_provider.dart';

class RankingScreen extends StatefulWidget {
  int gameIndex;
  RankingScreen(this.gameIndex);
  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  List<String> listOfGame = ["tetris", "xidach", "snake"];
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
                        "Ranking",
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.yellow),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(fontSize: 30)),
                              ),
                              onPressed: () => {OnGameChange(-1)},
                              child: const Icon(
                                Icons.arrow_left_sharp,
                                size: 30,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Text(
                              getFormatGameName(listOfGame[
                                      widget.gameIndex % listOfGame.length])
                                  .capitalize(),
                              style: const TextStyle(
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.yellow),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(fontSize: 30)),
                              ),
                              onPressed: () => {OnGameChange(1)},
                              child: const Icon(
                                Icons.arrow_right_sharp,
                                size: 30,
                              )),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Thành tích của bạn : ${userScore[listOfGame[widget.gameIndex % listOfGame.length]] ?? 0}",
                          style: TextStyle(
                            fontFamily: "Manrope",
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            tileColor: Colors.greenAccent,
                            leading: leadingWidgetRanking(index),
                            title: Text(
                              '${listItems[index].name} (${listItems[index].date})',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Score : ${listItems[index].score}',
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: trailingWidgetRanking(index),
                            onTap: () {
                              print("Tapped");
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    GetData(listOfGame[widget.gameIndex % listOfGame.length]);
    asyncMethod(context).then((value) => {
          //print(value),
          setState(() {
            userScore = value;
          })
        });
  }

  void GetData(String name) async {
    var url = Uri.https('random-website-7f4cf-default-rtdb.firebaseio.com',
        '$name.json', {'orderBy': '"score"'});

    //print(url.path);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      print(jsonResponse);
      print(url);
      var rankingInfo = convertData(jsonResponse);
      // rankingInfo.forEach((element) {
      //   print(element.name);
      //   print(element.score);
      //   print(element.date);
      // });
      setState(() {
        listItems = rankingInfo;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void OnGameChange(int count) {
    widget.gameIndex += count;
    GetData(listOfGame[widget.gameIndex % listOfGame.length]);
  }

  List<RankingInfo> convertData(Map<String, dynamic> map) {
    List<RankingInfo> result =
        List.generate(0, (index) => new RankingInfo("name", 1, "date"));

    map.keys.forEach((key) {
      var temp = map[key];
      var a = RankingInfo(temp["name"], temp["score"], temp["date"]);
      result.add(a);
    });
    result.sort(((a, b) => b.score - a.score));
    result.take(20);
    return result;
  }
}

Widget leadingWidgetRanking(int index) {
  String result = index == 0
      ? "1st"
      : index == 1
          ? "2nd"
          : index == 2
              ? "3rd"
              : "${index + 1}th";

  return Container(
    width: 50,
    height: 50,
    child: Center(
      child: Text(
        result,
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}

Widget trailingWidgetRanking(int index) {
  return Icon(
    Icons.star,
    color: index == 0
        ? Colors.yellow
        : index == 1
            ? Colors.white
            : index == 2
                ? Colors.orange
                : Colors.grey,
  );
}

String getFormatGameName(String text) {
  switch (text) {
    case "tetris":
      return "Tetris";
    case "xidach":
      return "Xì Dách";
    case "snake":
      return "Snake";
    default:
      return "";
  }
}

Future<Map<String, int>> asyncMethod(BuildContext context) async {
  var text = await loadUserScoreString(context);

  var data = GetUserScore(text);

  return data;
  // print(text);
  // print(data);
  // var con = UserScoreToText(data);
  // print(con);
}
