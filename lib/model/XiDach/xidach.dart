import 'dart:convert';

class Player {
  int status; //0 not connect 1 connect 2 end
  List<String> cards;
  Player({required this.cards, required this.status});
  Map toJson() => {
        'cards': cards,
        'status': status,
      };
  Player.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        cards = json['cards'];
}

class BlackJackMatch {
  String code;
  int status;
  Player player1;
  Player player2;
  BlackJackMatch(
      {required this.code,
      required this.player1,
      required this.player2,
      required this.status});
  Map toJson() {
    return {
      'code': code,
      'status': status,
      "player1": player1.toJson(),
      "player2": player2.toJson(),
    };
  }

  BlackJackMatch.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        code = json["code"],
        player1 = Player.fromJson(json["player1"]),
        player2 = Player.fromJson(json["player2"]);
}
