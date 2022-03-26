import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../widget/XiDach/cards_grid_view.dart';
import '../../widget/XiDach/custom_button.dart';

class BlackJackScreen extends StatefulWidget {
  const BlackJackScreen({Key? key}) : super(key: key);

  @override
  State<BlackJackScreen> createState() => _BlackJackScreenState();
}

class _BlackJackScreenState extends State<BlackJackScreen> {
  bool _isGameStarted = false;

  //Card Images
  List<Image> myCards = [];
  List<int> myCardsValue = [];
  List<Image> dealersCards = [];
  List<int> dealersCardsValue = [];

  //Cards
  String? dealersFirstCard;
  String? dealersSecondCard;
  String? playersFirstCard;
  String? playersSecondCard;

  //Scores
  int dealersScore = 0;
  int playersScore = 0;

  //Status
  String gameResult = "";
  String gameTurn = "";
  int winCount = 0;
  int highestWinCount = 0;

  //Error Message
  String errorMsg = "";

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

  @override
  void initState() {
    super.initState();
    playingCards.addAll(deckOfCards);
  }

  //Reset round && cards
  void startNewRound() {
    _isGameStarted = true;
    if (gameResult == "") {
      showMyDialogMessage(
          "Bạn phải kết thúc ván mới có thể qua ván mới! Để reset lại game chọn nút chơi lại");
      return;
    }

    gameResult = "";
    gameTurn = "Player";

    //Start new round with full deckofcards.
    playingCards = {};
    playingCards.addAll(deckOfCards);

    //reset card images
    myCards = [];
    dealersCards = [];

    myCardsValue = [];
    dealersCardsValue = [];

    //Random card one for dealer
    Random random = Random();
    String cardOneKey =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    //Remove used card key from playingCards
    playingCards.removeWhere((key, value) => key == cardOneKey);
    //Assign card keys to dealer's cards
    dealersFirstCard = cardOneKey;
    //Adding dealers card images to display them in Grid View
    dealersCards.add(Image.asset(dealersFirstCard!));
    //Score for dealer
    dealersCardsValue.add(deckOfCards[dealersFirstCard]!);
    dealersScore = calculateScore(dealersCardsValue);

    //Random card one for the player
    String cardThreeKey =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardThreeKey);

    //Random card two for the player
    String cardFourkey =
        playingCards.keys.elementAt(random.nextInt(playingCards.length));
    playingCards.removeWhere((key, value) => key == cardFourkey);

    //Assign card keys to player's cards
    playersFirstCard = cardThreeKey;
    playersSecondCard = cardFourkey;
    //Adding player card images to display them in grid view
    myCards.add(Image.asset(playersFirstCard!));
    myCardsValue.add(deckOfCards[playersFirstCard]!);
    myCards.add(Image.asset(playersSecondCard!));
    myCardsValue.add(deckOfCards[playersSecondCard]!);
    //Calculate score for the player (my score)
    playersScore = calculateScore(myCardsValue);
    var isXiDach = checkIfBlackJack(myCardsValue);
    if (isXiDach) {
      gameResult = "Win";
      winCount += 1;
    }
    setState(() {});
  }

  //Reset round && cards && score && chains
  void startNewMatch() {
    winCount = 0;
    gameResult = "NewGame";
    startNewRound();
  }

  int calculateScore(List<int> cards) {
    // 3,11,11  -> 3,át,át
    int score = 0;
    for (int value in cards) {
      if (value == 11) {
        score += 1;
      } else {
        score += value;
      }
    }
    //5
    for (int value in cards) {
      if (value == 11) {
        if (score + 10 <= 21) {
          score += 10;
        }
      }
      //15
      //16
    }
    return score;
  }

  bool checkIfBlackJack(List<int> cards) {
    if (cards.length == 2) {
      if (cards[0] == 10 && cards[1] == 11 ||
          cards[0] == 11 && cards[1] == 11 ||
          cards[1] == 10 && cards[0] == 11) {
        return true;
      }
    }
    return false;
  }

  bool checkIfFlush(List<int> cards) {
    if (cards.length == 5 && calculateScore(cards) <= 21) {
      return true;
    }
    return false;
  }

  //Add extra card to the player
  void addCard() {
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
    }
    print("Rút bài");
    Random random = Random();

    if (playingCards.isNotEmpty) {
      String cardKey =
          playingCards.keys.elementAt(random.nextInt(playingCards.length));

      playingCards.removeWhere((key, value) => key == cardKey);
      myCards.add(Image.asset(cardKey));
      myCardsValue.add(deckOfCards[cardKey]!);

      playersScore = calculateScore(myCardsValue);
      var flush = checkIfFlush(myCardsValue);
      if (flush) {
        gameResult = "Win";
        winCount += 1;
      }
      if (playersScore > 21) {
        gameResult = "Lose";
        winCount = 0;
      }
      setState(() {});
    }
  }

  Future<void> endTurn() async {
    print("Kết thúc");
    if (playersScore < 16) {
      showMyDialogMessage("Chỉ kết thúc lượt khi bạn có ít nhất 16 nút");
      return;
    }
    if (gameResult != "") {
      showMyDialogMessage("Nhấn nút chơi tiếp để tiếp tục!");
    }

    gameTurn = "Com";
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));
    while (dealersScore <= playersScore && dealersScore != 21) {
      await Future.delayed(const Duration(seconds: 2));
      Random random = Random();
      String cardOneKey =
          playingCards.keys.elementAt(random.nextInt(playingCards.length));
      //Remove used card key from playingCards
      playingCards.removeWhere((key, value) => key == cardOneKey);
      //Assign card keys to dealer's cards
      var dealersCard = cardOneKey;
      //Adding dealers card images to display them in Grid View
      dealersCards.add(Image.asset(dealersCard));
      dealersCardsValue.add(deckOfCards[dealersCard]!);
      dealersScore = calculateScore(dealersCardsValue);
      var isXiDach = checkIfBlackJack(dealersCardsValue);
      if (isXiDach) {
        gameResult = "Lose";
        winCount = 0;
      }
      var flush = checkIfFlush(dealersCardsValue);
      if (flush) {
        gameResult = "Lose";
        winCount = 0;
      }
      setState(() {
        dealersCards = dealersCards;
        dealersCardsValue = dealersCardsValue;
      });
      print(dealersScore);
    }

    if (dealersScore > 21) {
      gameResult = "Win";
      winCount += 1;
      return;
    }

    if (dealersScore > playersScore) {
      gameResult = "Lose";
      winCount = 0;
      return;
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

  Widget getTurnText(String text) {
    if (text == "Player") {
      return const Text("Lượt của bạn !!!",
          style: TextStyle(
            fontFamily: "Manrope",
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            fontSize: 36,
            color: Colors.black,
          ));
    } else {
      return const Text("Lượt của máy...",
          style: TextStyle(
            fontFamily: "Manrope",
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
            fontSize: 36,
            color: Colors.black,
          ));
    }
  }

  Future<void> showMyDialogMessage(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isGameStarted
          ? SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "Nút của nhà cái: $dealersScore",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: dealersScore <= 21
                                ? Colors.green[900]
                                : Colors.red[900]),
                      ),
                      CardsGridView(cards: dealersCards),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getTurnText(gameTurn),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Nút của bạn: $playersScore",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: playersScore <= 21
                                  ? Colors.green[900]
                                  : Colors.red[900])),
                      CardsGridView(cards: myCards)
                    ],
                  ),
                  IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getResultText(gameResult),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('Chuỗi thắng : $winCount',
                                  textAlign: TextAlign.center),
                            ),
                            const Expanded(
                              child: Text('Chuỗi thắng dài nhất: 0',
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              onPressed: () {
                                addCard();
                              },
                              label: "Rút bài",
                            ),
                            CustomButton(
                              onPressed: () {
                                startNewMatch();
                              },
                              label: "Chơi lại",
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              onPressed: () {
                                endTurn();
                              },
                              label: "Kết thúc",
                            ),
                            CustomButton(
                              onPressed: () {
                                startNewRound();
                              },
                              label: "Chơi tiếp",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CustomButton(
                onPressed: () => startNewMatch(),
                label: "Start Game",
              ),
            ),
    );
  }
}
