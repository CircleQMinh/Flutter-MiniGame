// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:minigame_app/model/shared/ranking.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../extension/extension.dart';

// Create a Form widget.
class SubmitScoreForm extends StatefulWidget {
  late int score;
  late String game;
  SubmitScoreForm(this.score, this.game, {Key? key}) : super(key: key);

  @override
  SubmitScoreState createState() {
    return SubmitScoreState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SubmitScoreState extends State<SubmitScoreForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String name = "";

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Nhập tên của bạn',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                border: OutlineInputBorder()),
            onFieldSubmitted: (value) {
              setState(() {
                name = value;
              });
            },
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 3) {
                return 'Name must contain at least 3 characters';
              } else if (value.contains(RegExp(r'^[0-9_\-=@,\.;]+$'))) {
                return 'Name cannot contain special characters';
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60)),
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                print("Hợp lệ");
                DateTime now = DateTime.now();
                String formattedDate = DateFormat('dd/MM/yyy').format(now);
                RankingInfo ri =
                    new RankingInfo(name, widget.score, formattedDate);
                try {
                  SubmitScore(ri).then((value) => {
                        print("done"),
                        UpdateLocalScore()
                            .then((value) => {OpenCompleteDialog()}),
                      });
                } catch (e) {
                  print(e);
                }
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> SubmitScore(RankingInfo info) async {
    // print(info.name);
    // print(info.score);
    // print(info.date);
    // print(widget.game);

    var url = Uri.parse(
        'https://random-website-7f4cf-default-rtdb.firebaseio.com/${widget.game}.json');
    var response = await http.post(url,
        body: json.encode(
            {'name': info.name, 'score': info.score, 'date': info.date}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  Future<void> UpdateLocalScore() async {
    var text = await loadAsset(context);

    var data = GetUserScore(text);

    var currentScore = data[widget.game] ?? 0;
    if (widget.score > currentScore) {
      data[widget.game] = widget.score;
    }
    var newData = UserScoreToText(data);
    final file = await localFile;
    file.writeAsString(newData);
  }

  Future<void> OpenCompleteDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text("Đã ghi nhận điểm của bạn!"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
        title: const Text("Thành công"),
      ),
    );
  }

  Future<String> loadAsset(BuildContext context) async {
    var s = await readFile();
    if (s.isEmpty) {
      String default_stat = "tetris:0/snake:0/xidach:0";
      await writeToFile(default_stat);
      s = await readFile();
    }
    print(s);
    return s;
  }
}
