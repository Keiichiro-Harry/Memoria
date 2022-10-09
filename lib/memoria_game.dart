// import 'dart:html';

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
import './add_book_page.dart';
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
import 'dart:math' as math;

class MemoriaGame extends StatefulWidget {
  final User user;
  final DocumentSnapshot<Object?> bookInfo;
  final String tag;
  MemoriaGame(this.user, this.bookInfo, this.tag);
  @override
  _MemoriaGameState createState() => _MemoriaGameState();
}

class _MemoriaGameState extends State<MemoriaGame> {
  // var _progress = '';
  var db = FirebaseFirestore.instance;
  List<List<dynamic>> splittedAnswer =
      []; //面倒だから、問題番号ごとにquizを0,一文字ずつanswer配列を1、元answerを2,List<List>選択肢を3,answerIndex配列を4の単純配列にしちゃおう
  List<List<dynamic>> originalQuizList = []; //こっちは元answerまで
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // List<List<int>> answerIndex = [[]];
  int typedLength = 0; //
  int quizNumber = 0; //
  int result = 0; //正答率
  bool isSelectNow = true;
  int count = 0;
  // List<String> thisAnswer = [];

  Future<void> updateQuiz(BuildContext context, int typedAnswerKey) async {
    setState(() {
      isSelectNow = false;
    });
    // print("OKquiz");

    // if (typedLength == splittedAnswer[quizNumber].length - 1) {
    //   //最後の文字だったら
    //   if (int.parse(selectionsAndAnswer[quizNumber][typedLength][4]) ==
    //       typedAnswerKey) {
    //     //正解してたら
    //     result++;
    //     typedLength++;
    //     print(splittedAnswer);
    //     print(typedLength);
    //     print("ok1");
    //   }
    //   print("ok2");
    //   // await Future.delayed(const Duration(seconds: 1));
    //   setState(() {
    //     typedLength = 0;
    //     quizNumber++;
    //   });
    // } else {
    //   //最後の文字じゃなかったら
    //   if (int.parse(selectionsAndAnswer[quizNumber][typedLength][4]) !=
    //           typedAnswerKey &&
    //       quizNumber != originalQuizList.length - 1) {
    //     //typedlengthを既に+1しているから⇨訂正済み
    //     print(int.parse(selectionsAndAnswer[quizNumber][typedLength][4]));
    //     typedLength = selectionsAndAnswer[quizNumber].length;
    //     setState(() {
    //       typedLength = 0;
    //       quizNumber++;
    //       print("ok3");
    //     });
    //     // await Future.delayed(const Duration(seconds: 1));
    //   } else if (quizNumber == originalQuizList.length - 1) {
    //     await goToResult(context, originalQuizList, result);
    //   } else {
    //     setState(() {
    //       typedLength++;
    //     });
    //   }
    //   if (splittedAnswer[quizNumber][typedLength] == ' ') {
    //     typedLength++;
    //   }
    //   print("ok4");
    // }
    bool A = originalQuizList.length - 1 == quizNumber;
    bool B = int.parse(selectionsAndAnswer[quizNumber][typedLength][4]) ==
        typedAnswerKey;
    bool C = typedLength == splittedAnswer[quizNumber].length - 1;
    if (A && (B == false || (B && C))) {
      if (B) {
        result++;
        print("here1");
      }
      await goToResult(context, originalQuizList, result);
    } else if (B && C == false) {
      typedLength++;
      print("here2");
    } else if (B) {
      result++;
      typedLength = 0;
      quizNumber++;
      print("here3");
    } else {
      typedLength = 0;
      quizNumber++;
      print("here4");
    }
    if (splittedAnswer[quizNumber][typedLength] == ' ') {
      typedLength++;
    }

    // await Future.delayed(const Duration(seconds: 1));
    isSelectNow = true;
    setState(() {});
    // typedLength++;
    // if (quizNumber == originalQuizList.length - 1) {
    //   // await goToResult(context, originalQuizList, result);
    //   print("OKquiz");
    //   await goToResult(context, originalQuizList, result);
    // }
    setState(() {});
  }

  Future<void> goToResult(BuildContext context, quizList, result) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Result(result, quizList)));
  }

  @override
  //
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.bookInfo['name'] + '【' + widget.tag + '】'),
  //     ),
  //     body: Center(
  //       child: Container(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           // mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             const SizedBox(height: 100, width: 20),
  //             // Text(_progress),
  //             Text('Bold34567890-098765432',
  //                 style: const TextStyle(
  //                     // fontWeight: FontWeight.bold,
  //                     fontSize: 36)),
  //             const SizedBox(height: 60, width: 20),
  //             Text('Bold34567890-098765432',
  //                 style: const TextStyle(
  //                     // fontWeight: FontWeight.bold,
  //                     fontSize: 36)),
  //             const SizedBox(height: 60, width: 20),
  //             Flexible(
  //                 child: widget.tag != 'All'
  //                     ? StreamBuilder<QuerySnapshot>(
  //                         stream: FirebaseFirestore.instance
  //                             .collection('books')
  //                             .doc(widget.bookInfo.id)
  //                             .collection(widget.bookInfo['name'])
  //                             .orderBy('date')
  //                             .where('tag', isEqualTo: widget.tag)
  //                             .snapshots(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData) {
  //                             final List<DocumentSnapshot> documents =
  //                                 snapshot.data!.docs;
  //                             final quizGenerator(documents);
  //                             return Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: <Widget>[
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20)
  //                               ],
  //                             );
  //                           }
  //                         },
  //                       )
  //                     : StreamBuilder<QuerySnapshot>(
  //                         stream: FirebaseFirestore.instance
  //                             .collection('books')
  //                             .doc(widget.bookInfo.id)
  //                             .collection(widget.bookInfo['name'])
  //                             .orderBy('date')
  //                             .snapshots(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData) {
  //                             final List<DocumentSnapshot> documents =
  //                                 snapshot.data!.docs;
  //                             final quizGenerator(documents);
  //                             return Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: <Widget>[
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20)
  //                               ],
  //                             );
  //                           }
  //                         },
  //                       ))
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Flexible(
      child: widget.tag == 'All'
          ? StreamBuilder<QuerySnapshot>(
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
                    final Iterable<QueryDocumentSnapshot<Object?>> documents =
                        snapshot.data!.docs;
                    // print("OKK1");
                    // var tagList = <String>[""];
                    // List<String> thisAnswer = [];
                    if (count == 0) {
                      for (var value in documents) {
                        // thisAnswer.add(value["answer"]);
                        originalQuizList.add([
                          value['question'],
                          value['answer']
                          // thisAnswer[thisAnswer.length - 1].split(''), //ここあやしい
                          // thisAnswer
                        ]);
                        // print(splittedAnswer);
                        splittedAnswer.add(
                            originalQuizList[originalQuizList.length - 1][1]
                                .split(''));
                      }
                      // print("OKquiz");
                      // splittedAnswer.removeAt(0);
                      // originalQuizList.removeAt(0);
                      // selectionsAndAnswer.removeAt(0);
                      selectionsAndAnswer = quizGenerator(splittedAnswer);
                      count++;
                    }
                    // print("OKquiz");
                    // tagList.toSet().toList();
                    // tagList = tagList.toSet().toList();
                    // print(tagList);
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                            widget.bookInfo['name'] + '【' + widget.tag + '】'),
                      ),
                      body: quizNumber < originalQuizList.length
                          ? CustomScrollView(
                              slivers: <Widget>[
                                SliverList(
                                    delegate: SliverChildListDelegate([
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4)),
                                  Text(
                                    originalQuizList[quizNumber][0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    originalQuizList[quizNumber][1]
                                        .substring(0, typedLength),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                  ),
                                ])),
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (context, key) {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Column(
                                            // mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  // Positioned.fill(
                                                  // child:
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: <Color>[
                                                          Color(0xFF0D47A1),
                                                          Color(0xFF1976D2),
                                                          Color(0xFF42A5F5),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // ),
                                                  TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 20),
                                                      ),
                                                      onPressed: () async {
                                                        if (!isSelectNow)
                                                          return;
                                                        await updateQuiz(
                                                            context, key);
                                                      },
                                                      child: isSelectNow ||
                                                              typedLength !=
                                                                  originalQuizList[quizNumber]
                                                                      .length
                                                          ? Text(selectionsAndAnswer[quizNumber]
                                                                  [typedLength]
                                                              [key])
                                                          : selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] ==
                                                                  key
                                                              ? Text(selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] +
                                                                  "○")
                                                              : Text(selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] +
                                                                  "×")),
                                                ],
                                              ),
                                            ]));
                                    // //
                                    // TextButton(
                                    //     style: TextButton.styleFrom(
                                    //       foregroundColor: Colors.white,
                                    //       padding: const EdgeInsets.all(16.0),
                                    //       textStyle: const TextStyle(fontSize: 20),
                                    //     ),
                                    //     onPressed: () async {
                                    //       if (!isSelectNow) return;
                                    //       await updateQuiz(context, key);
                                    //     },
                                    //     child: isSelectNow ||
                                    //             typedLength !=
                                    //                 originalQuizList[quizNumber]
                                    //                     .length
                                    //         ? Text(selectionsAndAnswer[quizNumber]
                                    //             [typedLength][key])
                                    //         : selectionsAndAnswer[quizNumber]
                                    //                     [typedLength][key] ==
                                    //                 key
                                    //             ? Text(
                                    //                 selectionsAndAnswer[quizNumber]
                                    //                         [typedLength][key] +
                                    //                     "○")
                                    //             : Text(
                                    //                 selectionsAndAnswer[quizNumber]
                                    //                         [typedLength][key] +
                                    //                     "×"));
                                    // //
                                  },
                                  childCount: 4,
                                )),
                              ],
                            )
                          : Container(),
                    );
                  } else {
                    return Container();
                  }
                }
                return const Center(
                  child: Text('読み込み中...'),
                );
              })
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .doc(widget.bookInfo.id)
                  .collection(widget.bookInfo['name'])
                  // .where("tag","==", widget.tag)
                  .orderBy('date')
                  // .endBefore(["中枢神経", "questoion"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    final Iterable<QueryDocumentSnapshot<Object?>> documents =
                        snapshot.data!.docs;
                    print("OKK1");
                    // var tagList = <String>[""];
                    // List<String> thisAnswer = [];
                    if (count == 0) {
                      for (var value in documents) {
                        // thisAnswer.add(value["answer"]);
                        if (value["tag"] == widget.tag) {
                          originalQuizList.add([
                            value['question'],
                            value['answer']
                            // thisAnswer[thisAnswer.length - 1].split(''), //ここあやしい
                            // thisAnswer
                          ]);

                          // print(splittedAnswer);
                          splittedAnswer.add(
                              originalQuizList[originalQuizList.length - 1][1]
                                  .split(''));
                        }
                      }
                      print("OKquiz");
                      // splittedAnswer.removeAt(0);
                      // originalQuizList.removeAt(0);
                      // selectionsAndAnswer.removeAt(0);
                      selectionsAndAnswer = quizGenerator(splittedAnswer);
                      count++;
                    }
                    // print("OKquiz");
                    // tagList.toSet().toList();
                    // tagList = tagList.toSet().toList();
                    //print(tagList);
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                            widget.bookInfo['name'] + '【' + widget.tag + '】'),
                      ),
                      body: quizNumber < originalQuizList.length
                          ? CustomScrollView(
                              slivers: <Widget>[
                                SliverList(
                                    delegate: SliverChildListDelegate([
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4)),
                                  Text(
                                    originalQuizList[quizNumber][0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    originalQuizList[quizNumber][1]
                                        .substring(0, typedLength),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                  ),
                                ])),
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (context, key) {
                                    return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Column(
                                            // mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  // Positioned.fill(
                                                  // child:
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: <Color>[
                                                          Color(0xFF0D47A1),
                                                          Color(0xFF1976D2),
                                                          Color(0xFF42A5F5),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // ),
                                                  TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 20),
                                                      ),
                                                      onPressed: () async {
                                                        if (!isSelectNow)
                                                          return;
                                                        print("here");
                                                        await updateQuiz(
                                                            context, key);
                                                        print(typedLength);
                                                        print(quizNumber);
                                                        print(originalQuizList);
                                                      },
                                                      child: isSelectNow ||
                                                              typedLength !=
                                                                  originalQuizList[quizNumber]
                                                                      .length
                                                          ? Text(selectionsAndAnswer[quizNumber]
                                                                  [typedLength]
                                                              [key])
                                                          : selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] ==
                                                                  key
                                                              ? Text(selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] +
                                                                  "○")
                                                              : Text(selectionsAndAnswer[quizNumber]
                                                                          [typedLength]
                                                                      [key] +
                                                                  "×")),
                                                ],
                                              ),
                                            ]));
                                    // //
                                    // TextButton(
                                    //     style: TextButton.styleFrom(
                                    //       foregroundColor: Colors.white,
                                    //       padding: const EdgeInsets.all(16.0),
                                    //       textStyle: const TextStyle(fontSize: 20),
                                    //     ),
                                    //     onPressed: () async {
                                    //       if (!isSelectNow) return;
                                    //       await updateQuiz(context, key);
                                    //     },
                                    //     child: isSelectNow ||
                                    //             typedLength !=
                                    //                 originalQuizList[quizNumber]
                                    //                     .length
                                    //         ? Text(selectionsAndAnswer[quizNumber]
                                    //             [typedLength][key])
                                    //         : selectionsAndAnswer[quizNumber]
                                    //                     [typedLength][key] ==
                                    //                 key
                                    //             ? Text(
                                    //                 selectionsAndAnswer[quizNumber]
                                    //                         [typedLength][key] +
                                    //                     "○")
                                    //             : Text(
                                    //                 selectionsAndAnswer[quizNumber]
                                    //                         [typedLength][key] +
                                    //                     "×"));
                                    // //
                                  },
                                  childCount: 4,
                                )),
                              ],
                            )
                          : Container(),
                    );
                  } else {
                    return Container();
                  }
                }
                return const Center(
                  child: Text('読み込み中...'),
                );
              }),
    );
  }
}

class Quiz {
  // String question;
  List<List<dynamic>> splittedAnswer;
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // String answerAll;
  List<List<int>> answerIndex = [];

  // List<String> select1 = [];
  // List<String> select2 = [];
  // List<String> select3 = [];
  // List<List<String>> selection;
  List<String> hiragana = [
    'あ',
    'い',
    'う',
    'え',
    'お',
    'か',
    'き',
    'く',
    'け',
    'こ',
    'さ',
    'し',
    'す',
    'せ',
    'そ',
    'た',
    'ち',
    'つ',
    'て',
    'と',
    'な',
    'に',
    'ぬ',
    'ね',
    'の',
    'は',
    'ひ',
    'ふ',
    'へ',
    'ほ',
    'ま',
    'み',
    'む',
    'め',
    'も',
    'や',
    'ゆ',
    'よ',
    'ら',
    'り',
    'る',
    'れ',
    'ろ',
    'わ',
    'を',
    'ん',
    'が',
    'ぎ',
    'ぐ',
    'げ',
    'ご',
    'ざ',
    'じ',
    'ず',
    'ぜ',
    'ぞ',
    'だ',
    'ぢ',
    'づ',
    'で',
    'ど',
    'ば',
    'び',
    'ぶ',
    'べ',
    'ぼ',
    'ぱ',
    'ぴ',
    'ぷ',
    'ぺ',
    'ぽ',
    'ぁ',
    'ぃ',
    'ぅ',
    'ぇ',
    'ぉ',
    'ゃ',
    'ゅ',
    'ょ',
    '、',
    '。'
  ]; //81こ
  List<String> katakana = [
    'ア',
    'イ',
    'ウ',
    'エ',
    'オ',
    'カ',
    'キ',
    'ク',
    'ケ',
    'コ',
    'サ',
    'シ',
    'ス',
    'セ',
    'ソ',
    'タ',
    'チ',
    'ツ',
    'テ',
    'ト',
    'ナ',
    'ニ',
    'ヌ',
    'ネ',
    'ノ',
    'ハ',
    'ヒ',
    'フ',
    'ヘ',
    'ホ',
    'マ',
    'ミ',
    'ム',
    'メ',
    'モ',
    'ヤ',
    'ユ',
    'ヨ',
    'ラ',
    'リ',
    'ル',
    'レ',
    'ロ',
    'ワ',
    'ヲ',
    'ン',
    'ガ',
    'ギ',
    'グ',
    'ゲ',
    'ゴ',
    'ザ',
    'ジ',
    'ズ',
    'ゼ',
    'ゾ',
    'ダ',
    'ヂ',
    'ヅ',
    'デ',
    'ド',
    'バ',
    'ビ',
    'ブ',
    'ベ',
    'ボ',
    'パ',
    'ピ',
    'プ',
    'ペ',
    'ポ',
    'ァ',
    'ィ',
    'ゥ',
    'ェ',
    'ォ',
    'ャ',
    'ュ',
    'ョ',
  ]; //79こ
  List<String> alphabetSmall = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    ',',
    '.'
  ]; //28こ
  List<String> alphabetCapital = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ]; //26こ
  List<String> number = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ]; //10こ

  List<List<List<dynamic>>> toMap(List<List<dynamic>> splittedAnswer) {
    List<List<List<dynamic>>> select = [];
    List<dynamic> selectProgress1 = [];
    List<List<dynamic>> selectProgress2 = [];
    List<int> answerIndexProgress = [];
    // print("OKquiz1");
    for (var a = 0; a < splittedAnswer.length; a++) {
      // print(splittedAnswer);
      selectProgress2 = [];
      answerIndexProgress = [];
      for (var b = 0; b < splittedAnswer[a].length; b++) {
        print(a);
        print(b);
        // print("OKquiz2");
        if (splittedAnswer[a][b] == 'あ' ||
            splittedAnswer[a][b] == 'い' ||
            splittedAnswer[a][b] == 'う' ||
            splittedAnswer[a][b] == 'え' ||
            splittedAnswer[a][b] == 'お' ||
            splittedAnswer[a][b] == 'か' ||
            splittedAnswer[a][b] == 'き' ||
            splittedAnswer[a][b] == 'く' ||
            splittedAnswer[a][b] == 'け' ||
            splittedAnswer[a][b] == 'こ' ||
            splittedAnswer[a][b] == 'さ' ||
            splittedAnswer[a][b] == 'し' ||
            splittedAnswer[a][b] == 'す' ||
            splittedAnswer[a][b] == 'せ' ||
            splittedAnswer[a][b] == 'そ' ||
            splittedAnswer[a][b] == 'た' ||
            splittedAnswer[a][b] == 'ち' ||
            splittedAnswer[a][b] == 'つ' ||
            splittedAnswer[a][b] == 'て' ||
            splittedAnswer[a][b] == 'と' ||
            splittedAnswer[a][b] == 'な' ||
            splittedAnswer[a][b] == 'に' ||
            splittedAnswer[a][b] == 'ぬ' ||
            splittedAnswer[a][b] == 'ね' ||
            splittedAnswer[a][b] == 'の' ||
            splittedAnswer[a][b] == 'は' ||
            splittedAnswer[a][b] == 'ひ' ||
            splittedAnswer[a][b] == 'ふ' ||
            splittedAnswer[a][b] == 'へ' ||
            splittedAnswer[a][b] == 'ほ' ||
            splittedAnswer[a][b] == 'ま' ||
            splittedAnswer[a][b] == 'み' ||
            splittedAnswer[a][b] == 'む' ||
            splittedAnswer[a][b] == 'め' ||
            splittedAnswer[a][b] == 'も' ||
            splittedAnswer[a][b] == 'や' ||
            splittedAnswer[a][b] == 'ゆ' ||
            splittedAnswer[a][b] == 'よ' ||
            splittedAnswer[a][b] == 'ら' ||
            splittedAnswer[a][b] == 'り' ||
            splittedAnswer[a][b] == 'る' ||
            splittedAnswer[a][b] == 'れ' ||
            splittedAnswer[a][b] == 'ろ' ||
            splittedAnswer[a][b] == 'わ' ||
            splittedAnswer[a][b] == 'を' ||
            splittedAnswer[a][b] == 'ん' ||
            splittedAnswer[a][b] == 'が' ||
            splittedAnswer[a][b] == 'ぎ' ||
            splittedAnswer[a][b] == 'ぐ' ||
            splittedAnswer[a][b] == 'げ' ||
            splittedAnswer[a][b] == 'ご' ||
            splittedAnswer[a][b] == 'ざ' ||
            splittedAnswer[a][b] == 'じ' ||
            splittedAnswer[a][b] == 'ず' ||
            splittedAnswer[a][b] == 'ぜ' ||
            splittedAnswer[a][b] == 'ぞ' ||
            splittedAnswer[a][b] == 'だ' ||
            splittedAnswer[a][b] == 'ぢ' ||
            splittedAnswer[a][b] == 'づ' ||
            splittedAnswer[a][b] == 'で' ||
            splittedAnswer[a][b] == 'ど' ||
            splittedAnswer[a][b] == 'ば' ||
            splittedAnswer[a][b] == 'び' ||
            splittedAnswer[a][b] == 'ぶ' ||
            splittedAnswer[a][b] == 'べ' ||
            splittedAnswer[a][b] == 'ぼ' ||
            splittedAnswer[a][b] == 'ぱ' ||
            splittedAnswer[a][b] == 'ぴ' ||
            splittedAnswer[a][b] == 'ぷ' ||
            splittedAnswer[a][b] == 'ぺ' ||
            splittedAnswer[a][b] == 'ぽ' ||
            splittedAnswer[a][b] == 'ぁ' ||
            splittedAnswer[a][b] == 'ぃ' ||
            splittedAnswer[a][b] == 'ぅ' ||
            splittedAnswer[a][b] == 'ぇ' ||
            splittedAnswer[a][b] == 'ぉ' ||
            splittedAnswer[a][b] == 'ゃ' ||
            splittedAnswer[a][b] == 'ゅ' ||
            splittedAnswer[a][b] == 'ょ' ||
            splittedAnswer[a][b] == '、' ||
            splittedAnswer[a][b] == '。') {
          var rand = math.Random();
          // print("OKquiz3");
          hiragana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(80 - i);
            selectProgress1.add(hiragana[randomNumber]);
            hiragana.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          hiragana = [
            'あ',
            'い',
            'う',
            'え',
            'お',
            'か',
            'き',
            'く',
            'け',
            'こ',
            'さ',
            'し',
            'す',
            'せ',
            'そ',
            'た',
            'ち',
            'つ',
            'て',
            'と',
            'な',
            'に',
            'ぬ',
            'ね',
            'の',
            'は',
            'ひ',
            'ふ',
            'へ',
            'ほ',
            'ま',
            'み',
            'む',
            'め',
            'も',
            'や',
            'ゆ',
            'よ',
            'ら',
            'り',
            'る',
            'れ',
            'ろ',
            'わ',
            'を',
            'ん',
            'が',
            'ぎ',
            'ぐ',
            'げ',
            'ご',
            'ざ',
            'じ',
            'ず',
            'ぜ',
            'ぞ',
            'だ',
            'ぢ',
            'づ',
            'で',
            'ど',
            'ば',
            'び',
            'ぶ',
            'べ',
            'ぼ',
            'ぱ',
            'ぴ',
            'ぷ',
            'ぺ',
            'ぽ',
            'ぁ',
            'ぃ',
            'ぅ',
            'ぇ',
            'ぉ',
            'ゃ',
            'ゅ',
            'ょ',
            '、',
            '。'
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[a][b][answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'ア' ||
            splittedAnswer[a][b] == 'イ' ||
            splittedAnswer[a][b] == 'ウ' ||
            splittedAnswer[a][b] == 'エ' ||
            splittedAnswer[a][b] == 'オ' ||
            splittedAnswer[a][b] == 'カ' ||
            splittedAnswer[a][b] == 'キ' ||
            splittedAnswer[a][b] == 'ク' ||
            splittedAnswer[a][b] == 'ケ' ||
            splittedAnswer[a][b] == 'コ' ||
            splittedAnswer[a][b] == 'サ' ||
            splittedAnswer[a][b] == 'シ' ||
            splittedAnswer[a][b] == 'ス' ||
            splittedAnswer[a][b] == 'セ' ||
            splittedAnswer[a][b] == 'ソ' ||
            splittedAnswer[a][b] == 'タ' ||
            splittedAnswer[a][b] == 'チ' ||
            splittedAnswer[a][b] == 'ツ' ||
            splittedAnswer[a][b] == 'テ' ||
            splittedAnswer[a][b] == 'ト' ||
            splittedAnswer[a][b] == 'ナ' ||
            splittedAnswer[a][b] == 'ニ' ||
            splittedAnswer[a][b] == 'ヌ' ||
            splittedAnswer[a][b] == 'ネ' ||
            splittedAnswer[a][b] == 'ノ' ||
            splittedAnswer[a][b] == 'ハ' ||
            splittedAnswer[a][b] == 'ヒ' ||
            splittedAnswer[a][b] == 'フ' ||
            splittedAnswer[a][b] == 'ヘ' ||
            splittedAnswer[a][b] == 'ホ' ||
            splittedAnswer[a][b] == 'マ' ||
            splittedAnswer[a][b] == 'ミ' ||
            splittedAnswer[a][b] == 'ム' ||
            splittedAnswer[a][b] == 'メ' ||
            splittedAnswer[a][b] == 'モ' ||
            splittedAnswer[a][b] == 'ヤ' ||
            splittedAnswer[a][b] == 'ユ' ||
            splittedAnswer[a][b] == 'ヨ' ||
            splittedAnswer[a][b] == 'ラ' ||
            splittedAnswer[a][b] == 'リ' ||
            splittedAnswer[a][b] == 'ル' ||
            splittedAnswer[a][b] == 'レ' ||
            splittedAnswer[a][b] == 'ロ' ||
            splittedAnswer[a][b] == 'ワ' ||
            splittedAnswer[a][b] == 'ヲ' ||
            splittedAnswer[a][b] == 'ン' ||
            splittedAnswer[a][b] == 'ガ' ||
            splittedAnswer[a][b] == 'ギ' ||
            splittedAnswer[a][b] == 'グ' ||
            splittedAnswer[a][b] == 'ゲ' ||
            splittedAnswer[a][b] == 'ゴ' ||
            splittedAnswer[a][b] == 'ザ' ||
            splittedAnswer[a][b] == 'ジ' ||
            splittedAnswer[a][b] == 'ズ' ||
            splittedAnswer[a][b] == 'ゼ' ||
            splittedAnswer[a][b] == 'ゾ' ||
            splittedAnswer[a][b] == 'ダ' ||
            splittedAnswer[a][b] == 'ヂ' ||
            splittedAnswer[a][b] == 'ヅ' ||
            splittedAnswer[a][b] == 'デ' ||
            splittedAnswer[a][b] == 'ド' ||
            splittedAnswer[a][b] == 'バ' ||
            splittedAnswer[a][b] == 'ビ' ||
            splittedAnswer[a][b] == 'ブ' ||
            splittedAnswer[a][b] == 'ベ' ||
            splittedAnswer[a][b] == 'ボ' ||
            splittedAnswer[a][b] == 'パ' ||
            splittedAnswer[a][b] == 'ピ' ||
            splittedAnswer[a][b] == 'プ' ||
            splittedAnswer[a][b] == 'ペ' ||
            splittedAnswer[a][b] == 'ポ' ||
            splittedAnswer[a][b] == 'ァ' ||
            splittedAnswer[a][b] == 'ィ' ||
            splittedAnswer[a][b] == 'ゥ' ||
            splittedAnswer[a][b] == 'ェ' ||
            splittedAnswer[a][b] == 'ォ' ||
            splittedAnswer[a][b] == 'ャ' ||
            splittedAnswer[a][b] == 'ュ' ||
            splittedAnswer[a][b] == 'ョ') {
          var rand = math.Random();
          // print("OKquiz3");
          katakana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(78 - i);
            selectProgress1.add(katakana[randomNumber]);
            katakana.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);
          katakana = [
            'ア',
            'イ',
            'ウ',
            'エ',
            'オ',
            'カ',
            'キ',
            'ク',
            'ケ',
            'コ',
            'サ',
            'シ',
            'ス',
            'セ',
            'ソ',
            'タ',
            'チ',
            'ツ',
            'テ',
            'ト',
            'ナ',
            'ニ',
            'ヌ',
            'ネ',
            'ノ',
            'ハ',
            'ヒ',
            'フ',
            'ヘ',
            'ホ',
            'マ',
            'ミ',
            'ム',
            'メ',
            'モ',
            'ヤ',
            'ユ',
            'ヨ',
            'ラ',
            'リ',
            'ル',
            'レ',
            'ロ',
            'ワ',
            'ヲ',
            'ン',
            'ガ',
            'ギ',
            'グ',
            'ゲ',
            'ゴ',
            'ザ',
            'ジ',
            'ズ',
            'ゼ',
            'ゾ',
            'ダ',
            'ヂ',
            'ヅ',
            'デ',
            'ド',
            'バ',
            'ビ',
            'ブ',
            'ベ',
            'ボ',
            'パ',
            'ピ',
            'プ',
            'ペ',
            'ポ',
            'ァ',
            'ィ',
            'ゥ',
            'ェ',
            'ォ',
            'ャ',
            'ュ',
            'ョ',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'a' ||
            splittedAnswer[a][b] == 'b' ||
            splittedAnswer[a][b] == 'c' ||
            splittedAnswer[a][b] == 'd' ||
            splittedAnswer[a][b] == 'e' ||
            splittedAnswer[a][b] == 'f' ||
            splittedAnswer[a][b] == 'g' ||
            splittedAnswer[a][b] == 'h' ||
            splittedAnswer[a][b] == 'i' ||
            splittedAnswer[a][b] == 'j' ||
            splittedAnswer[a][b] == 'k' ||
            splittedAnswer[a][b] == 'l' ||
            splittedAnswer[a][b] == 'm' ||
            splittedAnswer[a][b] == 'n' ||
            splittedAnswer[a][b] == 'o' ||
            splittedAnswer[a][b] == 'p' ||
            splittedAnswer[a][b] == 'q' ||
            splittedAnswer[a][b] == 'r' ||
            splittedAnswer[a][b] == 's' ||
            splittedAnswer[a][b] == 't' ||
            splittedAnswer[a][b] == 'u' ||
            splittedAnswer[a][b] == 'v' ||
            splittedAnswer[a][b] == 'w' ||
            splittedAnswer[a][b] == 'x' ||
            splittedAnswer[a][b] == 'y' ||
            splittedAnswer[a][b] == 'z' ||
            splittedAnswer[a][b] == ',' ||
            splittedAnswer[a][b] == '.') {
          var rand = math.Random();
          // print("OKquiz3");
          alphabetSmall.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(27 - i);
            selectProgress1.add(alphabetSmall[randomNumber]);
            alphabetSmall.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);
          alphabetSmall = [
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
            'g',
            'h',
            'i',
            'j',
            'k',
            'l',
            'm',
            'n',
            'o',
            'p',
            'q',
            'r',
            's',
            't',
            'u',
            'v',
            'w',
            'x',
            'y',
            'z',
            ',',
            '.'
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'A' ||
            splittedAnswer[a][b] == 'B' ||
            splittedAnswer[a][b] == 'C' ||
            splittedAnswer[a][b] == 'D' ||
            splittedAnswer[a][b] == 'E' ||
            splittedAnswer[a][b] == 'F' ||
            splittedAnswer[a][b] == 'G' ||
            splittedAnswer[a][b] == 'H' ||
            splittedAnswer[a][b] == 'I' ||
            splittedAnswer[a][b] == 'J' ||
            splittedAnswer[a][b] == 'K' ||
            splittedAnswer[a][b] == 'L' ||
            splittedAnswer[a][b] == 'M' ||
            splittedAnswer[a][b] == 'N' ||
            splittedAnswer[a][b] == 'O' ||
            splittedAnswer[a][b] == 'P' ||
            splittedAnswer[a][b] == 'Q' ||
            splittedAnswer[a][b] == 'R' ||
            splittedAnswer[a][b] == 'S' ||
            splittedAnswer[a][b] == 'T' ||
            splittedAnswer[a][b] == 'U' ||
            splittedAnswer[a][b] == 'V' ||
            splittedAnswer[a][b] == 'W' ||
            splittedAnswer[a][b] == 'X' ||
            splittedAnswer[a][b] == 'Y' ||
            splittedAnswer[a][b] == 'Z') {
          var rand = math.Random();
          // print("OKquiz3");
          alphabetCapital.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(25 - i);
            selectProgress1.add(alphabetCapital[randomNumber]);
            alphabetCapital.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          alphabetCapital = [
            'A',
            'B',
            'C',
            'D',
            'E',
            'F',
            'G',
            'H',
            'I',
            'J',
            'K',
            'L',
            'M',
            'N',
            'O',
            'P',
            'Q',
            'R',
            'S',
            'T',
            'U',
            'V',
            'W',
            'X',
            'Y',
            'Z',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        } else if (splittedAnswer[a][b] == '0' ||
            splittedAnswer[a][b] == '1' ||
            splittedAnswer[a][b] == '2' ||
            splittedAnswer[a][b] == '3' ||
            splittedAnswer[a][b] == '4' ||
            splittedAnswer[a][b] == '5' ||
            splittedAnswer[a][b] == '6' ||
            splittedAnswer[a][b] == '7' ||
            splittedAnswer[a][b] == '8' ||
            splittedAnswer[a][b] == '9') {
          var rand = math.Random();
          // print("OKquiz3");
          number.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(9 - i);
            selectProgress1.add(number[randomNumber]);
            hiragana.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          number = [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        } else {
          var rand = math.Random();
          // print("OKquiz3");
          // hiragana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            selectProgress1.add('?');
          }
          selectProgress2.add(selectProgress1);

          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        }
        // print("quizisOK");
      }
      select.add(selectProgress2);
      answerIndex.add(answerIndexProgress);
    }
    // print("quizisOK");
    // answerIndex[0].remove(0);
    // print(select);
    // print(answerIndex);
    selectionsAndAnswer = select;
    // selectionsAndAnswer[a][b].add(answerIndex);
    for (var a = 0; a < splittedAnswer.length; a++) {
      for (var b = 0; b < splittedAnswer[a].length; b++) {
        // print("here?");
        selectionsAndAnswer[a][b].add(answerIndex[a][b].toString());
      }
    }
    for (var value in selectionsAndAnswer) {
      print(value);
    }
    // print("quizisOK");
    // selectionsAndAnswer.add(answerIndex);
    return selectionsAndAnswer;
  }

  Quiz(
    // this.question,
    this.splittedAnswer,
    // this.answerAll,
    // this.answerIndex,
    // this.select0,
    // this.select1,
    // this.select2,
    // this.select3,
  );
}

List<List<List<dynamic>>> quizGenerator(List<List<dynamic>> splittedAnswer) {
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // late List<List<String>> selection;

  // for (var value in splittedAnswer) {
  //   // String answer = value['answer'];

  //   Quiz quiz = Quiz(
  //     value, //question
  //     // value[1], //splitted answer
  //     // value[2],
  //   );
  //   // quizList.add(Quiz(value[0],value[1],value[2]));

  //   selectionsAndAnswer.add(quiz);
  // }
  var quiz = Quiz(splittedAnswer);
  // print('四角形の面積は${rect.getArea()}㎠'); // メソッドの呼び出し
  // List<List<List<dynamic>>> quiz = Quiz.toMap(splittedAnswer);
  selectionsAndAnswer = quiz.toMap(splittedAnswer);
  return selectionsAndAnswer;
}

class Result extends StatelessWidget {
  Result(this.result, this.quizList, {Key? key}) : super(key: key);
  int result;
  List<List<dynamic>> quizList;
  late String comment;

  Future<void> goToTop(BuildContext context) async {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    switch (result.round() * 100 ~/ quizList.length) {
      case 60:
        comment = "まあまあ";
        break;
      case 70:
        comment = "まあまあ";
        break;
      case 80:
        comment = "いいね";
        break;
      case 90:
        comment = "すごい";
        break;
      case 100:
        comment = "よくできました";
        break;
      default:
        comment = "頑張りましょう";
        break;
    }
    print("${result / quizList.length * 100}");

    return Scaffold(
      body: Center(
        child: Column(
          //Columnの中に入れたものは縦に並べられる．Rowだと横に並べられる
          mainAxisAlignment: MainAxisAlignment.center, //Coloumの中身を真ん中に配置
          children: <Widget>[
            Text(comment),
            Text('正答数$result'),
            Text('正答率${result / quizList.length * 100}%'),
            ElevatedButton(
                onPressed: () async {
                  await goToTop(context);
                },
                child: const Text('トップへ戻る')),
          ],
        ),
      ),
    );
  }
}
