import 'dart:convert';
import 'dart:async' show Future;
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:minigame_app/extension/extension.dart';
import 'package:minigame_app/model/RPS/RPS.dart';
import 'package:minigame_app/model/shared/ranking.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/XiDach/xidach.dart';
import '../../widget/XiDach/cards_grid_view.dart';
import '../../widget/XiDach/custom_button.dart';

class JoinMatchOnlineScreen extends StatefulWidget {
  bool isHost;
  JoinMatchOnlineScreen({required this.isHost});
  @override
  JoinMatchOnlineScreenState createState() => JoinMatchOnlineScreenState();
}

class JoinMatchOnlineScreenState extends State<JoinMatchOnlineScreen> {
  bool _isGameStarted = false;
  bool _isGameJoined = false;
  String gameCode = "";
  int gameTurn = 0;
  String gameResult = "";
  late BlackJackMatch current_match;
  //Card Images
  List<Image> player1Cards = [];
  List<int> player1CardsValue = [];
  List<Image> player2Cards = [];
  List<int> player2CardsValue = [];

  //Scores
  int player1Score = 0;
  int player2Score = 0;
  //Match Point
  int player1MP = 0;
  int player2MP = 0;
  //Deck of Cards
  final Map<String, int> deckOfCards = {
    "assets/xi_dach/2.1.png": 2,
    "assets/xi_dach/2.2.png": 2,
    "assets/xi_dach/2.3.png": 2,
    "assets/xi_dach/2.4.png": 2,
    "assets/xi_dach/3.1.png": 3,
    "assets/xi_dach/3.2.png": 3,
    "assets/xi_dach/3.3.png": 3,
    "assets/xi_dach/3.4.png": 3,
    "assets/xi_dach/4.1.png": 4,
    "assets/xi_dach/4.2.png": 4,
    "assets/xi_dach/4.3.png": 4,
    "assets/xi_dach/4.4.png": 4,
    "assets/xi_dach/5.1.png": 5,
    "assets/xi_dach/5.2.png": 5,
    "assets/xi_dach/5.3.png": 5,
    "assets/xi_dach/5.4.png": 5,
    "assets/xi_dach/6.1.png": 6,
    "assets/xi_dach/6.2.png": 6,
    "assets/xi_dach/6.3.png": 6,
    "assets/xi_dach/6.4.png": 6,
    "assets/xi_dach/7.1.png": 7,
    "assets/xi_dach/7.2.png": 7,
    "assets/xi_dach/7.3.png": 7,
    "assets/xi_dach/7.4.png": 7,
    "assets/xi_dach/8.1.png": 8,
    "assets/xi_dach/8.2.png": 8,
    "assets/xi_dach/8.3.png": 8,
    "assets/xi_dach/8.4.png": 8,
    "assets/xi_dach/9.1.png": 9,
    "assets/xi_dach/9.2.png": 9,
    "assets/xi_dach/9.3.png": 9,
    "assets/xi_dach/9.4.png": 9,
    "assets/xi_dach/10.1.png": 10,
    "assets/xi_dach/10.2.png": 10,
    "assets/xi_dach/10.3.png": 10,
    "assets/xi_dach/10.4.png": 10,
    "assets/xi_dach/J1.png": 10,
    "assets/xi_dach/J2.png": 10,
    "assets/xi_dach/J3.png": 10,
    "assets/xi_dach/J4.png": 10,
    "assets/xi_dach/Q1.png": 10,
    "assets/xi_dach/Q2.png": 10,
    "assets/xi_dach/Q3.png": 10,
    "assets/xi_dach/Q4.png": 10,
    "assets/xi_dach/K1.png": 10,
    "assets/xi_dach/K2.png": 10,
    "assets/xi_dach/K3.png": 10,
    "assets/xi_dach/K4.png": 10,
    "assets/xi_dach/A1.png": 11,
    "assets/xi_dach/A2.png": 11,
    "assets/xi_dach/A3.png": 11,
    "assets/xi_dach/A4.png": 11,
  };

  Map<String, int> playingCards = {};

  TextEditingController _textFieldController = TextEditingController();
  int round = 1;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 80;
    String image_src = "assets/logo/blackjack.png";
    // TODO: implement build
    void onExit() {
      current_match.status = 5;
      UpdateCurrentMatch();
      Navigator.of(context).pop(true);
    }

    Future<bool> _onWillPop() async {
      return (await showDialog(
            barrierDismissible: false, // user must tap button!
            context: context,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('Thoát khỏi game?'),
                content: const Text('Bạn muốn thoát khỏi game?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Không'),
                  ),
                  TextButton(
                    onPressed: onExit,
                    child: const Text('Thoát'),
                  ),
                ],
              ),
            ),
          )) ??
          false;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: _isGameStarted
            ? SafeArea(
                child: Expanded(
                  child: Scrollbar(
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Wrap(children: [
                        Container(
                          color: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                color: Colors.black,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 3,
                                        bottom: 3,
                                      ),
                                      child: Text(
                                        "Nút của đối thủ: " +
                                            getPlayer1Score() +
                                            " - Ván thắng : $player1MP",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: 0 > 21
                                                ? Colors.red
                                                : Colors.yellow),
                                      ),
                                    ),
                                    CardsGridView(cards: getPlayer1Cards()),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.black,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.black,
                                      child: Text(getTurnString(),
                                          style: const TextStyle(
                                            fontFamily: "Manrope",
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                            fontSize: 18,
                                            color: Colors.yellow,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.black,
                                child: Column(
                                  children: [
                                    CardsGridView(cards: player2Cards),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 3,
                                        bottom: 3,
                                      ),
                                      child: Text(
                                          "Nút của bạn: $player2Score - Ván thắng : $player2MP",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: player2Score > 21
                                                ? Colors.red
                                                : Colors.yellow,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  runSpacing: 6,
                                  children: [
                                    Center(child: getResultText(gameResult)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('Ván đấu: $round',
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CustomButton(
                                          onPressed: () {
                                            addCard();
                                          },
                                          label: "Rút bài",
                                          icon: const Icon(Icons.add,
                                              color: Colors.black),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8),
                                          child: CustomButton(
                                            onPressed: () {
                                              endTurn();
                                            },
                                            label: "Kết thúc",
                                            icon: const Icon(Icons.stop_sharp,
                                                color: Colors.black),
                                          ),
                                        ),
                                        CustomButton(
                                          onPressed: () {
                                            startNewRound();
                                          },
                                          label: "Ván tiếp",
                                          icon: const Icon(Icons.skip_next,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(child: Image.asset(image_src)),
                    Center(
                      child: Text(
                        getStatusString(),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              textStyle: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          onPressed: AsyncOpenUserInputModal,
                          child: Text(
                            "Nhập mã ván đấu!",
                          )),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String getStatusString() {
    if (_isGameJoined) {
      return "Đã tham gia thành công, chờ khởi tạo ván đấu...";
    } else {
      return "Nhập mã ván đấu để tham gia";
    }
  }

  String getPlayer1Score() {
    if (gameTurn == 2) {
      return player1Score.toString();
    }
    return "???";
  }

  List<Image> getPlayer1Cards() {
    if (gameTurn == 2) {
      return player1Cards;
    } else {
      List<Image> img = [];
      for (var i = 0; i < player1Cards.length; i++) {
        var temp = Image.asset("assets/xi_dach/down.jpg");
        img.add(temp);
      }
      return img;
    }
  }

  String getTurnString() {
    switch (gameTurn) {
      case 0:
        return "Chờ lượt của đối thủ...";
      case 1:
        return "Lượt của bạn";
      case 2:
        return "Lật bài!!!";
      default:
        return "";
    }
  }

  Widget getResultText(String text) {
    if (text == "Lose") {
      return const Text(
        "Bạn Thua !",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Manrope",
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          fontSize: 36,
          color: Colors.black,
        ),
      );
    } else if (text == "Win") {
      return const Text(
        "Bạn Thắng !",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Manrope",
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          fontSize: 36,
          color: Colors.black,
        ),
      );
    } else if (text == "Draw") {
      return const Text(
        "Hòa!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Manrope",
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          fontSize: 36,
          color: Colors.black,
        ),
      );
    } else {
      return const Text(
        "",
        style: TextStyle(
          fontFamily: "Manrope",
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          fontSize: 36,
          color: Colors.black,
        ),
      );
    }
  }

  @override
  void initState() {
    print("join");
    super.initState();
  }

  Future<void> AsyncOpenUserInputModal() async {
    await OpenUserInputModal();
    var joinOK = await JoinGame(_textFieldController.text);
    if (joinOK) {
      sendReadySignal();
      setState(() {
        _isGameJoined = true;
      });
    }
    checkPlayer1StillPlaying();
    await GamePlay();
  }

  Future<void> GamePlay() async {
    while (true) {
      var wait = await WaitForCards();
      if (wait) {
        break;
      }
    }

    setState(() {});

    while (true) {
      var wait = await WaitForPlayer1();
      if (wait) {
        break;
      }
    }
    setState(() {
      gameTurn = 1;
    });

    UpdatePlayableCards();
  }

  Future<void> sendReadySignal() async {
    current_match.player2.status = 2;
    var url = Uri.parse(
        'https://random-website-7f4cf-default-rtdb.firebaseio.com/match/${current_match.code}.json');
    var response = await http.put(url, body: json.encode(current_match));
  }

  Future<void> OpenUserInputModal() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Nhập mã ván đấu"),
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: "Nhập mã ván đấu..."),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tiếp tục'),
              onPressed: () {
                try {
                  print(_textFieldController.text);
                  var input = _textFieldController.text;
                  if (input.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Bạn phải nhập mã ván đấu!", // message
                        toastLength: Toast.LENGTH_SHORT, // length
                        gravity: ToastGravity.CENTER, // location
                        timeInSecForIosWeb: 1 // duration
                        );
                  } else {
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "Không hợp lệ!", // message
                      toastLength: Toast.LENGTH_SHORT, // length
                      gravity: ToastGravity.CENTER, // location
                      timeInSecForIosWeb: 1 // duration
                      );
                }
              },
            ),
          ],
          title: const Text("Đặt cược"),
        ),
      ),
    );
  }

  Future<bool> JoinGame(String code) async {
    var url = Uri.https(
        'random-website-7f4cf-default-rtdb.firebaseio.com', 'match/$code.json');

    //print(url.path);
    // Await the http get response, then decode the json-formatted response.
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      if (json.decode(response.body) == null) {
        showMyDialogMessage("Kết nối thất bại");
        return false;
      }
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      var match = convertData(jsonResponse);
      setState(() {
        current_match = match;
        gameCode = match.code;
      });
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      showMyDialogMessage("Kết nối thất bại");
      return false;
    }
  }

  Future<void> showMyDialogMessage(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Hướng dẫn'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(text),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

//M02ZC01ZCR1R
  BlackJackMatch convertData(Map<String, dynamic> map) {
    BlackJackMatch result = BlackJackMatch(
        code: map["code"],
        player1: convertPlayerData(map["player1"]),
        player2: convertPlayerData(map["player2"]),
        status: map["status"]);
    print(result.toJson());
    return result;
  }

  Player convertPlayerData(Map<String, dynamic> map) {
    if (map["cards"] != null) {
      // print(map["cards"]);
      // print(map["status"]);
      List<String> cards = List<String>.from(map["cards"]);
      return Player(cards: cards, status: map["status"]);
    } else {
      return Player(cards: [], status: map["status"]);
    }
  }

  Future<bool> WaitForCards() async {
    await Future.delayed(const Duration(seconds: 1));
    var url = Uri.https('random-website-7f4cf-default-rtdb.firebaseio.com',
        'match/$gameCode.json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      //print(jsonResponse);
      var m = convertData(jsonResponse);

      if (m.player1.cards.isEmpty) {
        return false;
      } else {
        if (m.player1.cards.every(
            (element) => current_match.player1.cards.contains(element))) {
          return false;
        }
        setState(() {
          current_match = m;
          _isGameStarted = true;
          player1Cards = [];
          player1CardsValue = [];
          for (var card in current_match.player1.cards) {
            player1Cards.add(Image.asset(card));
            player1CardsValue.add(deckOfCards[card]!);
            player1Score = calculateScore(player1CardsValue);
          }
          player2Cards = [];
          player2CardsValue = [];
          for (var card in current_match.player2.cards) {
            player2Cards.add(Image.asset(card));
            player2CardsValue.add(deckOfCards[card]!);
            player2Score = calculateScore(player2CardsValue);
          }
        });
        return true;
      }
    }
    return false;
  }

  Future<bool> WaitForPlayer1() async {
    await Future.delayed(const Duration(seconds: 1));
    var url = Uri.https('random-website-7f4cf-default-rtdb.firebaseio.com',
        'match/$gameCode.json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      //print(jsonResponse);
      var m = convertData(jsonResponse);
      current_match = m;
      if (m.player1.cards.length > player1Cards.length) {
        await playLocalSound("newcard.mp3");
      }
      player1Cards = [];
      player1CardsValue = [];
      for (var element in m.player1.cards) {
        player1Cards.add(Image.asset(element));
        player1CardsValue.add(deckOfCards[element]!);
        player1Score = calculateScore(player1CardsValue);
      }
      setState(() {});
      if (m.player1.status == 1 || m.player1.status == 2) {
        return true;
      }
      return false;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return false;
    }
  }

  Future<void> addCard() async {
    if (gameTurn == 0) {
      showMyDialogMessage("Chưa đến lượt của bạn!");
      return;
    }
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
      return;
    }
    if (player2Score > 21) {
      showMyDialogMessage("Bạn không thể rút bài nữa!");
      return;
    }
    print("Rút bài");
    await playLocalSound("newcard.mp3");
    Random random = Random();
    if (playingCards.isNotEmpty) {
      String cardKey =
          playingCards.keys.elementAt(random.nextInt(playingCards.length));

      playingCards.removeWhere((key, value) => key == cardKey);
      player2Cards.add(Image.asset(cardKey));
      player2CardsValue.add(deckOfCards[cardKey]!);

      player2Score = calculateScore(player2CardsValue);

      current_match.player2.cards.add(cardKey);

      await UpdateCurrentMatch();

      setState(() {});
    }
  }

  Future<void> UpdateCurrentMatch() async {
    var url = Uri.parse(
        'https://random-website-7f4cf-default-rtdb.firebaseio.com/match/${current_match.code}.json');
    var response = await http.put(url, body: json.encode(current_match));
  }

  Future<void> endTurn() async {
    print("end");
    if (gameTurn == 0) {
      showMyDialogMessage("Chưa đến lượt của bạn!");
      return;
    }
    if (player2Score < 16) {
      if (!checkIfBlackJack(player2CardsValue)) {
        showMyDialogMessage("Chỉ kết thúc lượt khi bạn có ít nhất 16 nút");
        return;
      }
    }
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
      return;
    }

    current_match.player1.status = 2;
    current_match.player2.status = 2;

    await UpdateCurrentMatch();
    setState(() {
      gameTurn = 2;
    });

    CompareResult();
  }

  String getResultString() {
    if (checkIfBlackJack(player1CardsValue)) {
      if (checkIfBlackJack(player2CardsValue)) {
        return "Draw";
      }
      return "Lose";
    } else if (checkIfFlush(player1CardsValue)) {
      if (checkIfFlush(player2CardsValue)) {
        if (player1Score > player2Score) {
          return "Lose";
        } else if (player1Score == player2Score) {
          return "Draw";
        } else {
          return "Win";
        }
      }
      return "Lose";
    }
    if (player1Score <= 21) {
      if (player1Score > player2Score) {
        return "Lose";
      } else if (player1Score == player2Score) {
        return "Draw";
      } else {
        if (player2Score > 21) {
          return "Lose";
        }
        return "Win";
      }
    } else {
      if (player2Score > 21) {
        return "Draw";
      } else {
        return "Win";
      }
    }
  }

  Future<void> CompareResult() async {
    print("compare");
    gameTurn = 2;
    gameResult = getResultString();
    if (gameResult == "Win") {
      player2MP++;
      await playLocalSound("win.mp3");
    } else if (gameResult == "Draw") {
      await playLocalSound("lose.mp3");
    } else {
      player1MP++;
      await playLocalSound("lose.mp3");
    }
  }

  Future<void> startNewRound() async {
    if (gameTurn == 0) {
      showMyDialogMessage("Chưa đến lượt của bạn!");
      return;
    }
    if (gameTurn == 1) {
      showMyDialogMessage("Chưa thể kết thúc ván đấu!");
      return;
    }

    print("bat dau van mơi");
    setState(() {
      _isGameStarted = false;
      player1Score = 0;
      player2Score = 0;
      player1Cards = [];
      player2Cards = [];
      player1CardsValue = [];
      player2CardsValue = [];
      gameTurn = 0;
      gameResult = "";
      round++;
    });

    await GamePlay();
  }

  void UpdatePlayableCards() {
    playingCards = {};
    playingCards.addAll(deckOfCards);
    for (var card in current_match.player1.cards) {
      playingCards.removeWhere((key, value) => key == card);
    }
    for (var card in current_match.player2.cards) {
      playingCards.removeWhere((key, value) => key == card);
    }
  }

  void checkPlayer1StillPlaying() {
    Future.delayed(Duration(seconds: 1)).then((_) async {
      var url = Uri.https('random-website-7f4cf-default-rtdb.firebaseio.com',
          'match/$gameCode.json');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        //print(jsonResponse);
        var m = convertData(jsonResponse);
        if (m.status == 5) {
          showMyDialogMessage("Đối thủ đã rời trận");
        } else {
          checkPlayer1StillPlaying();
        }
      }
    });
  }
}
