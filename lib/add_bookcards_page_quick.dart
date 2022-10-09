import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './account.dart';
import './add_post_page.dart';
import './assignments.dart';
import './bookcards.dart';
import './bookshelf.dart';
import './login_page.dart';
import './memoria_game.dart';
import './notification.dart';
import './recommendation.dart';
import './screen_transition.dart';
import './setting.dart';

//https://zenn.dev/maropook/articles/4bfa59b464520c

class AddBookCardsPageQuick extends StatefulWidget {
  AddBookCardsPageQuick(this.user, this.bookInfo);
  final User user;
  final DocumentSnapshot<Object?> bookInfo;

  @override
  _AddBookCardsPageQuickState createState() => _AddBookCardsPageQuickState();
}

class _AddBookCardsPageQuickState extends State<AddBookCardsPageQuick> {
  // List<String> questionText = [];
  // List<String> answerText = [];
  String nameText = '';
  // List<String> commentText = [];
  String originalText = '';
  late List<Map> quizList = [];
  String tagText = '';
  String newTagText = '';
  var _selectedValue = ""; //ここに移動させたらちゃんと反映されるようになった！
  var isSelectedItem = "None";
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カードを追加'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              // TextFormField(
              //   decoration: InputDecoration(labelText: '問題'),
              //   // 複数行のテキスト入力
              //   keyboardType: TextInputType.multiline,
              //   // 最大3行
              //   maxLines: 3,
              //   onChanged: (String value) {
              //     setState(() {
              //       questionText = value;
              //     });
              //   },
              // ),
              // TextFormField(
              //   decoration: InputDecoration(labelText: '答え'),
              //   // 複数行のテキスト入力
              //   keyboardType: TextInputType.multiline,
              //   // 最大3行
              //   maxLines: 3,
              //   onChanged: (String value) {
              //     setState(() {
              //       answerText = value;
              //     });
              //   },
              // ),
              Scrollbar(
                controller: _scrollController,
                child: TextFormField(
                  decoration: InputDecoration(labelText: '問題:答え:コメント'),
                  // 複数行のテキスト入力
                  keyboardType: TextInputType.multiline,
                  // 最大3行
                  maxLines: 3,
                  onChanged: (String value) {
                    setState(() {
                      originalText = value;
                    });
                  },
                ),
              ),

              Row(children: <Widget>[
                Text('タグ'),
                Container(height: 20, width: 20),
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('books')
                          .doc(widget.bookInfo.id)
                          .collection(widget.bookInfo['name'])
                          .orderBy('date')
                          // .endBefore(["中枢神経", "questoion"])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            print("OKK1");
                            var tagList = <String>[""];
                            for (var value in documents) {
                              tagList.add(value['tag']);
                            }
                            // tagList.toSet().toList();
                            tagList = tagList.toSet().toList();
                            print(tagList);
                            return DropdownButton<String>(
                              value: _selectedValue,
                              items: tagList
                                  .map((String list) => DropdownMenuItem(
                                      value: list, child: Text(list)))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedValue = value!;
                                  print(value);
                                  print(_selectedValue);
                                  tagText = _selectedValue;
                                  print("OKK2");
                                });
                              },
                            );
                          } else {
                            return Container();
                          }
                        }
                        return const Center(
                          child: Text('読み込み中...'),
                        );
                      }),
                ),
              ]),

              TextFormField(
                decoration: InputDecoration(labelText: '新しいタグ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String? value) {
                  setState(() {
                    newTagText = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('カードを追加'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = widget.user.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    quizList = await getData(originalText);
                    for (var value in quizList) {
                      await FirebaseFirestore.instance
                          .collection('books') // コレクションID指定
                          .doc(widget.bookInfo.id)
                          .collection(widget.bookInfo['name'])
                          .doc() // ドキュメントID自動生成
                          .set({
                        // 'question': questionText,
                        // 'answer': answerText,
                        'email': email,
                        'comment': value['comment'],
                        'tag': newTagText != "" ? newTagText : tagText,
                        'date': date,
                        'isChecked': false,
                        'question': value['question'],
                        'answer': value["answer"],
                        'stage': 1,
                      });
                      print(value);
                    }
                    // 1つ前の画面に戻る
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Quiz {
  String question;
  String answer;
  String comment;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'comment': comment,
    };
  }

  Quiz(
    this.question,
    this.answer,
    this.comment,
  );
}

Future<List<Map>> getData(String original) async {
  List<Map> quizList = [];
  // String csv = await rootBundle.loadString(path);
  for (String line in original.split("\n")) {
    if (quizList.length == original.split("\n").length) {
      //ここquiz.length+1にしてたら最後改行必須みたいになる
      break;
    }
    List rows = [];
    var count = 0;
    print("OK");
    for (var i = 1; i < line.split('').length; i++) {
      print("OK!");
      if (line.substring(i, i + 1) == ":" ||
          line.substring(i, i + 1) == ";" ||
          line.substring(i, i + 1) == "：" ||
          line.substring(i, i + 1) == "；") {
        rows.add(line.substring(count, i));
        count = i + 1;
      }
      print(rows);
    }
    rows.add(line.substring(count, line.length));
    Quiz quiz = Quiz(rows[0], rows[1], rows[2] ?? '');
    print("OK3");
    quizList.add(quiz.toMap());
  }
  print(quizList);
  return quizList;
}
