import 'dart:convert';
import 'dart:async' show Future;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minigame_app/extension/extension.dart';

import '../../model/XiDach/xidach.dart';
import '../../widget/XiDach/cards_grid_view.dart';
import '../../widget/XiDach/custom_button.dart';

class HostMatchOnlineScreen extends StatefulWidget {
  bool isHost;
  HostMatchOnlineScreen({required this.isHost});
  @override
  HostMatchOnlineScreenState createState() => HostMatchOnlineScreenState();
}

class HostMatchOnlineScreenState extends State<HostMatchOnlineScreen> {
  bool _isGameStarted = false;
  bool _isGameCreated = false;
  bool _isGameReady = false;
  String gameCode = "";
  int gameTurn = 2;
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
  int coins = 1000;
  int bet = 0;
  int round = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 80;
    String image_src = "assets/logo/blackjack.png";
    // TODO: implement build
    void onExit() {
      try {
        current_match.status = 5;
        UpdateCurrentMatch();
      } catch (e) {
        Navigator.of(context).pop(true);
      }

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
                                            getPlayer2Score() +
                                            " - Ván thắng : $player2MP",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: 0 > 21
                                                ? Colors.red
                                                : Colors.yellow),
                                      ),
                                    ),
                                    CardsGridView(cards: getPlayer2Cards()),
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
                                    CardsGridView(cards: player1Cards),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 3,
                                        bottom: 3,
                                      ),
                                      child: Text(
                                          "Nút của bạn: $player1Score - Ván thắng : $player1MP",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: player1Score > 21
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
                                            startNewMatch();
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(child: getGameCodeText()),
                    Center(child: getStartButton()),
                  ],
                ),
              ),
      ),
    );
  }

  String getStatusString() {
    if (_isGameCreated) {
      return "Đã tạo ván đấu, chờ người chơi 2 tham gia.";
    } else {
      return "Đang tạo ván đấu, xin chờ một tí...";
    }
  }

  String getPlayer2Score() {
    if (gameTurn == 2) {
      return player2Score.toString();
    }
    return "???";
  }

  List<Image> getPlayer2Cards() {
    if (gameTurn == 2) {
      return player2Cards;
    } else {
      List<Image> img = [];
      for (var i = 0; i < player2Cards.length; i++) {
        var temp = Image.asset("assets/xi_dach/down.jpg");
        img.add(temp);
      }
      return img;
    }
  }

  String getTurnString() {
    switch (gameTurn) {
      case 0:
        return "Lượt của bạn";
      case 1:
        return "Chờ lượt của đối thủ...";
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

  String getResultString() {
    if (checkIfBlackJack(player1CardsValue)) {
      if (checkIfBlackJack(player2CardsValue)) {
        return "Draw";
      }
      return "Win";
    } else if (checkIfFlush(player1CardsValue)) {
      if (checkIfFlush(player2CardsValue)) {
        if (player1Score > player2Score) {
          return "Win";
        } else if (player1Score == player2Score) {
          return "Draw";
        } else {
          return "Lose";
        }
      }
      return "Win";
    }
    if (player1Score <= 21) {
      if (player1Score > player2Score) {
        return "Win";
      } else if (player1Score == player2Score) {
        return "Draw";
      } else {
        if (player2Score > 21) {
          return "Win";
        }
        return "Lose";
      }
    } else {
      if (player2Score > 21) {
        return "Draw";
      } else {
        return "Lose";
      }
    }
  }

  Widget getGameCodeText() {
    if (_isGameCreated) {
      return Text(
        "Mã ván đấu : $gameCode",
        style: Theme.of(context).textTheme.headline4,
      );
    }
    return Text("");
  }

  Widget getStartButton() {
    if (_isGameReady) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            onPressed: startNewMatch,
            child: Text(
              "Bắt đầu ván đấu!",
            )),
      );
    }
    return Text("");
  }

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      CreateGame();
    }
  }

  Future<void> CreateGame() async {
    // print(info.name);
    // print(info.score);
    // print(info.date);
    // print(widget.game);

    Player player1 = Player(cards: [], status: 1);
    Player player2 = Player(cards: [], status: 0);

    BlackJackMatch match = BlackJackMatch(
        code: getRandomString(6),
        player1: player1,
        player2: player2,
        status: 0);
    checkPlayer2StillPlaying();
    var url = Uri.parse(
        'https://random-website-7f4cf-default-rtdb.firebaseio.com/match/${match.code}.json');
    var response = await http.put(url, body: json.encode(match));
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    setState(() {
      gameCode = match.code;
      _isGameCreated = true;
    });

    while (true) {
      try {
        var wait = await WaitForPlayer2(match.code);
        if (wait) {
          break;
        }
      } catch (e) {
        break;
      }
    }
    setState(() {
      _isGameReady = true;
    });
  }

  Future<bool> WaitForPlayer2(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    var url = Uri.https(
        'random-website-7f4cf-default-rtdb.firebaseio.com', 'match/$code.json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      //print(jsonResponse);
      var m = convertData(jsonResponse);
      current_match = m;
      if (m.player2.cards.length > player2Cards.length) {
        await playLocalSound("newcard.mp3");
      }
      player2Cards = [];
      player2CardsValue = [];
      m.player2.cards.forEach((element) {
        player2Cards.add(Image.asset(element));
        player2CardsValue.add(deckOfCards[element]!);
        player2Score = calculateScore(player2CardsValue);
      });
      if (mounted) {
        setState(() {});
      }

      if (m.player2.status == 1 || m.player2.status == 2) {
        return true;
      }
      return false;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return false;
    }
  }

  BlackJackMatch convertData(Map<String, dynamic> map) {
    BlackJackMatch result = BlackJackMatch(
        code: map["code"],
        player1: convertPlayerData(map["player1"]),
        player2: convertPlayerData(map["player2"]),
        status: map["status"]);
    //print(result.toJson());
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

  Future<void> addCard() async {
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
      return;
    }
    if (player1Score > 21) {
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
      player1Cards.add(Image.asset(cardKey));
      player1CardsValue.add(deckOfCards[cardKey]!);

      player1Score = calculateScore(player1CardsValue);

      current_match.player1.cards.add(cardKey);

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
    if (player1Score < 16) {
      if (!checkIfBlackJack(player1CardsValue)) {
        showMyDialogMessage("Chỉ kết thúc lượt khi bạn có ít nhất 16 nút");
        return;
      }
    }
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
      return;
    }
    current_match.player1.status = 2;
    current_match.player2.status = 0;
    setState(() {
      gameTurn = 1;
    });

    await UpdateCurrentMatch();

    while (true) {
      var wait = await WaitForPlayer2(current_match.code);
      if (wait) {
        break;
      }
      setState(() {});
    }

    CompareResult();
  }

  Future<void> CompareResult() async {
    print("compare");
    gameTurn = 2;
    gameResult = getResultString();
    if (gameResult == "Win") {
      player1MP++;
      await playLocalSound("win.mp3");
    } else if (gameResult == "Draw") {
      await playLocalSound("lose.mp3");
    } else {
      player2MP++;
      await playLocalSound("lose.mp3");
    }
  }

  Future<void> startNewMatch() async {
    if (gameTurn != 2) {
      showMyDialogMessage("Chưa thể kết thúc ván đấu");
      return;
    }
    print("bat dau game");
    setState(() {
      _isGameStarted = true;
      player1Score = 0;
      player2Score = 0;
      player1Cards = [];
      player2Cards = [];
      player1CardsValue = [];
      player2CardsValue = [];
      current_match.player1.cards = [];
      current_match.player2.cards = [];
      current_match.player1.status = 0;
      current_match.player2.status = 0;
      gameTurn = 0;
      gameResult = "";
      round++;
    });
    playingCards = {};
    playingCards.addAll(deckOfCards);
    //Random card one for dealer
    Random random = Random();
    String cardOne =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardOne);
    player1Cards.add(Image.asset(cardOne));
    String cardTwo =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardTwo);
    player1Cards.add(Image.asset(cardTwo));
    player1CardsValue.add(deckOfCards[cardOne]!);
    player1CardsValue.add(deckOfCards[cardTwo]!);
    player1Score = calculateScore(player1CardsValue);

    String cardThree =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardThree);
    player2Cards.add(Image.asset(cardThree));
    String cardFour =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardFour);
    player2Cards.add(Image.asset(cardFour));
    player2CardsValue.add(deckOfCards[cardThree]!);
    player2CardsValue.add(deckOfCards[cardFour]!);
    player2Score = calculateScore(player2CardsValue);
    setState(() {});

    current_match.player1.cards.add(cardOne);
    current_match.player1.cards.add(cardTwo);
    current_match.player1.status = 0;

    current_match.player2.cards.add(cardThree);
    current_match.player2.cards.add(cardFour);
    current_match.player2.status = 0;

    await UpdateCurrentMatch();

    setState(() {});
  }

  void checkPlayer2StillPlaying() {
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
          checkPlayer2StillPlaying();
        }
      }
    });
  }
}
