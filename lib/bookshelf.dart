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

class _Slidable extends StatefulWidget {
  final List<DocumentSnapshot<Object?>> documents;
  final int index;
  final User user;
  _Slidable({
    required this.documents,
    required this.index,
    required this.user,
    // required this._selectedValue,
    Key? key,
  }) : super(key: key);

  @override
  State<_Slidable> createState() => __SlidableState();
}

class __SlidableState extends State<_Slidable> {
  String tagText = '';
  var _selectedValue = "";
  @override
  Widget build(BuildContext context) {
    return Slidable(
      // enabled: false, // falseにすると文字通りスライドしなくなります
      // closeOnScroll: false, // *2
      // dragStartBehavior: DragStartBehavior.start,
      key: UniqueKey(),
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          widget.documents[widget.index]['isChecked']
              ? SlidableAction(
                  onPressed: (_) {
                    FirebaseFirestore.instance
                        .collection('books')
                        .doc(widget.documents[widget.index].id)
                        .update({'isChecked': false});
                  },
                  backgroundColor:
                      const Color.fromARGB(255, 48, 89, 115), // (4)
                  foregroundColor: const Color.fromARGB(255, 222, 213, 196),
                  icon: Icons.star,
                  label: 'Unread',
                )
              : SlidableAction(
                  onPressed: (_) {
                    FirebaseFirestore.instance
                        .collection('books')
                        .doc(widget.documents[widget.index].id)
                        .update({'isChecked': true});
                  },
                  backgroundColor:
                      const Color.fromARGB(255, 48, 89, 115), // (4)
                  foregroundColor: const Color.fromARGB(255, 239, 126, 86),
                  icon: Icons.star,
                  label: 'Read',
                )
        ],
      ),
      endActionPane: ActionPane(
        // (2)
        extentRatio: 0.5,
        motion: const StretchMotion(), // (5)
        dismissible: DismissiblePane(onDismissed: () {
          setState(() {
            //ここ逆だと、一瞬removeAtで消えたやつの次のやつが間違って消される。
            //documentsで消しても大元が消えてないから
            //FirebaseFirestore.instance
            // .collection('books')
            // .doc(widget.documents[widget.index].id)
            // .delete();危ないから消しとく
            //widget.documents.removeAt(widget.index);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('message cannot dismissed')));
          });
        }),
        children: [
          SlidableAction(
            // (3)
            onPressed: (_) {
              FirebaseFirestore.instance
                  .collection('books')
                  .doc(widget.documents[widget.index].id)
                  .update({'isChecked': true});
            }, // (4)
            backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
            foregroundColor: const Color.fromARGB(255, 249, 249, 249), // (4)
            icon: Icons.chair_rounded, // (4)
            label: '詳細',
          ),
          SlidableAction(
            // (3)
            onPressed: (_) {
              FirebaseFirestore.instance
                  .collection('books')
                  .doc(widget.documents[widget.index].id)
                  .update({'isChecked': true});
            },
            backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
            foregroundColor: const Color.fromARGB(255, 222, 213, 196),
            icon: Icons.flag,
            label: 'Flag',
          ),
          SlidableAction(
            // (3)
            onPressed: (_) {
              //FirebaseFirestore.instance
              // .collection('books')
              // .doc(widget.documents[widget.index].id)
              // .delete();危ないから消しとく
            },
            backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
            foregroundColor: const Color.fromARGB(255, 239, 126, 86),
            icon: Icons.delete,
            label: '消去',
          ),
        ],
      ),
      child: Card(
          // child: Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     ListTile(
          //       leading: Image.network(
          //           'https://images-na.ssl-images-amazon.com/images/I/51HRqCnj7SL._SX344_BO1,204,203,200_.jpg'),
          //       title: Text('完訳 7つの習慣~人格主義の回復~'),
          //       subtitle: Text('送料無料'),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: <Widget>[
          //         TextButton(
          //           child: const Text('詳細'),
          //           onPressed: () {/* ... */},
          //         ),
          //         const SizedBox(width: 8),
          //         TextButton(
          //           child: const Text('今すぐ購入'),
          //           onPressed: () {/* ... */},
          //         ),
          //         const SizedBox(width: 8),
          //       ],
          //     ),
          //   ],
          // ),

          //TODO ここでエラー
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        widget.documents[widget.index]['email'] ==
                widget.user.email //元々!=nullにしてた
            ? ListTile(
                onTap: () async {
                  // 投稿画面に遷移
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return BookCards(
                          widget.user, widget.documents[widget.index]);
                    }),
                  );
                },
                //leading: documents[index]['image'],
                title: Text(widget.documents[widget.index]['name']),
                subtitle: Text(widget.documents[widget.index]['comment']),
                // 自分の投稿メッセージの場合は削除ボタンを表示
                leading: IconButton(
                  icon: const Icon(Icons.thumb_up),
                  onPressed: () async {},
                ),
                trailing: widget.documents[widget.index]['email'] ==
                        widget.user.email
                    ? IconButton(
                        icon: const Icon(Icons.verified),
                        onPressed: () async {
                          // 投稿メッセージのドキュメントを削除
                          // await FirebaseFirestore.instance
                          //     .collection('posts')
                          //     .doc(documents[index].id)
                          //     .delete();

//
                          await showDialog<int>(
                              context: context,
                              barrierDismissible: false, //ここ？
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    //できた！！！https://stackoverflow.com/questions/51962272/how-to-refresh-an-alertdialog-in-flutter
                                    builder: (context, setState) {
                                  return Dialog(
                                      child: Container(
                                    // alignment:
                                    width: 400,
                                    height: 200,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              widget.documents[widget.index]
                                                  ['name'],
                                              style: TextStyle(fontSize: 30)),
                                          Flexible(
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('books')
                                                    .doc(widget
                                                        .documents[widget.index]
                                                        .id)
                                                    .collection(widget
                                                            .documents[
                                                        widget.index]['name'])
                                                    .orderBy('date')
                                                    // .endBefore(["中枢神経", "questoion"])
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data != null) {
                                                      final List<
                                                              DocumentSnapshot>
                                                          documents =
                                                          snapshot.data!.docs;
                                                      // print("OKK1");
                                                      var tagList = <String>[
                                                        ""
                                                      ];
                                                      tagList.add(
                                                          'All'); //???なんかよくわからんけど空白とallがいる
                                                      // List<String> tagList = [];
                                                      // tagList.add("All");
                                                      for (var value
                                                          in documents) {
                                                        tagList
                                                            .add(value['tag']);
                                                      }
                                                      // tagList.toSet().toList();
                                                      tagList = tagList
                                                          .toSet()
                                                          .toList();
                                                      print(tagList);
                                                      print(_selectedValue);
                                                      var tagText = "";
                                                      return DropdownButton<
                                                          String>(
                                                        value: _selectedValue,
                                                        items: tagList
                                                            .map((String
                                                                    list) =>
                                                                DropdownMenuItem(
                                                                    value: list,
                                                                    child: Text(
                                                                        list)))
                                                            .toList(),
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedValue =
                                                                value!;
                                                            print(value);
                                                            print(
                                                                _selectedValue);
                                                            tagText =
                                                                _selectedValue;
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: Text("Game Start"),
                                                onPressed: () async {
                                                  // 投稿画面に遷移
                                                  if (_selectedValue != "") {
                                                    await Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                        return MemoriaGame(
                                                            widget.user,
                                                            widget.documents[
                                                                widget.index],
                                                            _selectedValue);
                                                      }),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          )
                                        ]),
                                  )
                                      // title: Text(
                                      //     widget.documents[widget.index]['name']),
                                      // content: Flexible(
                                      //   child: StreamBuilder<QuerySnapshot>(
                                      //       stream: FirebaseFirestore.instance
                                      //           .collection('books')
                                      //           .doc(widget
                                      //               .documents[widget.index].id)
                                      //           .collection(
                                      //               widget.documents[widget.index]
                                      //                   ['name'])
                                      //           .orderBy('date')
                                      //           // .endBefore(["中枢神経", "questoion"])
                                      //           .snapshots(),
                                      //       builder: (context, snapshot) {
                                      //         if (snapshot.hasData) {
                                      //           if (snapshot.data != null) {
                                      //             final List<DocumentSnapshot>
                                      //                 documents =
                                      //                 snapshot.data!.docs;
                                      //             // print("OKK1");
                                      //             var tagList = <String>[""];
                                      //             tagList.add(
                                      //                 'All'); //???なんかよくわからんけど空白とallがいる
                                      //             // List<String> tagList = [];
                                      //             // tagList.add("All");
                                      //             for (var value in documents) {
                                      //               tagList.add(value['tag']);
                                      //             }
                                      //             // tagList.toSet().toList();
                                      //             tagList =
                                      //                 tagList.toSet().toList();
                                      //             print(tagList);
                                      //             print(_selectedValue);
                                      //             var tagText = "";
                                      //             return DropdownButton<String>(
                                      //               value: _selectedValue,
                                      //               items: tagList
                                      //                   .map((String list) =>
                                      //                       DropdownMenuItem(
                                      //                           value: list,
                                      //                           child:
                                      //                               Text(list)))
                                      //                   .toList(),
                                      //               onChanged: (String? value) {
                                      //                 setState(() {
                                      //                   _selectedValue = value!;
                                      //                   print(value);
                                      //                   print(_selectedValue);
                                      //                   tagText = _selectedValue;
                                      //                   print("OKK2");
                                      //                 });
                                      //               },
                                      //             );
                                      //           } else {
                                      //             return Container();
                                      //           }
                                      //         }
                                      //         return const Center(
                                      //           child: Text('読み込み中...'),
                                      //         );
                                      //       }),
                                      // ),
                                      // actions: <Widget>[
                                      //   // ボタン領域
                                      //   // TextButton(
                                      //   //   child: Text("Cancel"),
                                      //   //   onPressed: () => Navigator.pop(context),
                                      //   // ),
                                      //   TextButton(
                                      //     child: Text("Cancel"),
                                      //     onPressed: () => Navigator.pop(context),
                                      //   ),
                                      //   TextButton(
                                      //     child: Text("Game Start"),
                                      //     onPressed: () async {
                                      //       // 投稿画面に遷移
                                      //       if (_selectedValue != "") {
                                      //         await Navigator.of(context).push(
                                      //           MaterialPageRoute(
                                      //               builder: (context) {
                                      //             return MemoriaGame(
                                      //                 widget.user,
                                      //                 widget.documents[
                                      //                     widget.index],
                                      //                 _selectedValue);
                                      //           }),
                                      //         );
                                      //       }
                                      //     },
                                      //   ),
                                      // ],
                                      );
                                });

                                //   }),
                                // );
                              });
                        },
                      )
                    : null)

            // 他人のは表示しない
            : Container()
        // : ListTile(
        //     onTap: () async {
        //       // 投稿画面に遷移
        //       await Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) {
        //           return BookCards(
        //               widget.user, widget.documents[widget.index]);
        //         }),
        //       );
        //     },
        //     //leading: documents[index]['image'],
        //     title: Text(widget.documents[widget.index]['name']),
        //     subtitle: Text(widget.documents[widget.index]['comment']),
        //     // 自分の投稿メッセージの場合は削除ボタンを表示
        //     leading: IconButton(
        //       icon: const Icon(Icons.thumb_up),
        //       onPressed: () async {},
        //     ),
        //     trailing:
        //         widget.documents[widget.index]['email'] == widget.user.email
        //             ? IconButton(
        //                 icon: const Icon(Icons.verified),
        //                 onPressed: () async {
        //                   // 投稿メッセージのドキュメントを削除
        //                   // await FirebaseFirestore.instance
        //                   //     .collection('posts')
        //                   //     .doc(documents[index].id)
        //                   //     .delete();
        //                 },
        //               )
        //             : null,
        //   ),
      ])),
    );
  }
}

class BookShelf extends StatefulWidget {
  BookShelf(this.user);
  // ユーザー情報
  final User user;
  // var _selectedValue = "";
  @override
  State<BookShelf> createState() => _BookShelfState();
}

class _BookShelfState extends State<BookShelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${widget.user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    // 取得した投稿メッセージ一覧を元にリスト表示
                    return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //TODO 後で消す
                        //print('イメージ：${documents[index]['email']}');
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        //if (documents[index]['email'] == widget.user.email) {
                        return _Slidable(
                          documents: documents,
                          index: index,
                          user: widget.user,
                          // _selectedValue: '',
                        );
                      },

                      //} else {
                      // return Slidable(
                      //   // enabled: false,
                      //   startActionPane: ActionPane(
                      //     extentRatio: 0.2,
                      //     motion: const ScrollMotion(),
                      //     children: [
                      //       documents[index]['isChecked']
                      //           ? SlidableAction(
                      //               onPressed: (_) {
                      //                 //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                      //                 FirebaseFirestore.instance
                      //                     .collection('posts')
                      //                     .doc(documents[index].id)
                      //                     .update({
                      //                   //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                      //                   'isChecked': false
                      //                   //updatedAt: firebase.firestore.FieldValue.serverTimestamp();
                      //                 });
                      //               },
                      //               backgroundColor: const Color.fromARGB(
                      //                   255, 48, 89, 115), // (4)
                      //               foregroundColor: const Color.fromARGB(
                      //                   255, 222, 213, 196),
                      //               icon: Icons.star,
                      //               label: 'Unread',
                      //             )
                      //           : SlidableAction(
                      //               onPressed: (_) {
                      //                 FirebaseFirestore.instance
                      //                     .collection('posts')
                      //                     .doc(documents[index].id)
                      //                     .update({'isChecked': true});
                      //               },
                      //               backgroundColor: const Color.fromARGB(
                      //                   255, 48, 89, 115), // (4)
                      //               foregroundColor: const Color.fromARGB(
                      //                   255, 239, 126, 86),
                      //               icon: Icons.star,
                      //               label: 'Read',
                      //             )
                      //     ],
                      //   ),
                      //   child: Card(
                      //     child: ListTile(
                      //         title: Text(documents[index]['text']),
                      //         subtitle: Text(documents[index]['email']),
                      //         // 自分の投稿メッセージの場合は削除ボタンを表示
                      //         trailing: documents[index]['email'] ==
                      //                 widget.user.email
                      //             ? IconButton(
                      //                 icon: const Icon(Icons.delete),
                      //                 onPressed: () async {
                      //                   // 投稿メッセージのドキュメントを削除
                      //                   await FirebaseFirestore.instance
                      //                       .collection('posts')
                      //                       .doc(documents[index].id)
                      //                       .delete();
                      //                 },
                      //               )
                      //             : null),
                      //   ),
                      // );
                      //}
                    );
                  } else {
                    return Container();
                  }
                }
                // データが読込中の場合
                return const Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddBookPage(widget.user);
            }),
          );
        },
      ),
    );
  }
}
