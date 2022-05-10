import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

Map<String, int> GetUserScore(String text) {
  Map<String, int> map = {};
  var list = text.split("/");
  list.forEach((element) {
    var temp = element.split(":");
    map.addAll({temp[0]: int.parse(temp[1])});
  });
  return map;
}

String UserScoreToText(Map<String, int> map) {
  var result = "";
  map.keys.forEach((key) {
    var text = "$key:${map[key]}";
    result += text;
    result += "/";
  });
  result = result.substring(0, result.length - 1);

  return result;
}

String DateToddMMyyyy(DateTime date) {
  return "";
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<File> get localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<File> writeToFile(String c) async {
  final file = await _localFile;
  return file.writeAsString(c);
}

Future<String> readFile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return (contents);
  } catch (e) {
    return "";
  }
}

Future<String> loadUserScoreString(BuildContext context) async {
  var s = await readFile();
  if (s.isEmpty) {
    String default_stat = "tetris:0/snake:0/xidach:0/bird:0/bubles:0";
    await writeToFile(default_stat);
    s = await readFile();
  }
  print(s);
  return s;
}

Future<AudioPlayer> playLocalSound(String name) async {
  final player = AudioCache(prefix: 'assets/sound/');

  // call this method when desired
  return await player.play(name, volume: 1);
}

Future<AudioPlayer> loopLocalSound(String name) async {
  final player = AudioCache(prefix: 'assets/sound/');

  // call this method when desired
  return await player.loop(name, volume: 1);
}

const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

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
