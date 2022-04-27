import 'dart:io';

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
    String default_stat = "tetris:0/snake:0/xidach:0";
    await writeToFile(default_stat);
    s = await readFile();
  }
  print(s);
  return s;
}