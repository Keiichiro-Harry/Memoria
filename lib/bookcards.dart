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
import './add_bookcards_page.dart';
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

class BookCards extends StatefulWidget {
  BookCards(this.user, this.bookInfo);
  // ユーザー情報
  final User user;
  final DocumentSnapshot<Object?> bookInfo;
  @override
  State<BookCards> createState() => _BookCardsState();
}

class _BookCardsState extends State<BookCards> {
  @override
  Widget build(BuildContext context) {
    print("OK1");
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
                  .doc(widget.bookInfo.id)
                  .collection(widget.bookInfo['name'])
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  //final List<DocumentSnapshot> newDocuments = //indexを数字で指定するから無理だぁ〜！
                  print("OK2");
                  // print(documents[documents['books'].doc(widget.bookInfo.id)
                  // .collection(widget.bookInfo['name'])][0]['color']);
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        print('OKKKKK');
                        if (documents['Noutan']['comment'] ==
                            widget.user.email) {
                          //ここを何とかしたい
                          print("OK3");
                          return Slidable(
                              // enabled: false, // falseにすると文字通りスライドしなくなります
                              // closeOnScroll: false, // *2
                              // dragStartBehavior: DragStartBehavior.start,
                              key: UniqueKey(),
                              startActionPane: ActionPane(
                                extentRatio: 0.2,
                                motion: const ScrollMotion(),
                                children: [
                                  documents[index]['isChecked']
                                      ? SlidableAction(
                                          onPressed: (_) {
                                            FirebaseFirestore.instance
                                                .collection('books')
                                                .doc(widget.bookInfo.id)
                                                .collection(
                                                    widget.bookInfo['name'])
                                                .doc(documents[index].id)
                                                .update({'isChecked': false});
                                          },
                                          backgroundColor: const Color.fromARGB(
                                              255, 48, 89, 115), // (4)
                                          foregroundColor: const Color.fromARGB(
                                              255, 222, 213, 196),
                                          icon: Icons.star,
                                          label: 'Unread',
                                        )
                                      : SlidableAction(
                                          onPressed: (_) {
                                            FirebaseFirestore.instance
                                                .collection('books')
                                                .doc(widget.bookInfo.id)
                                                .collection(
                                                    widget.bookInfo['name'])
                                                .doc(documents[index].id)
                                                .update({'isChecked': true});
                                            print("OK4");
                                          },
                                          backgroundColor: const Color.fromARGB(
                                              255, 48, 89, 115), // (4)
                                          foregroundColor: const Color.fromARGB(
                                              255, 239, 126, 86),
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
                                    FirebaseFirestore.instance
                                        .collection('books')
                                        .doc(widget.bookInfo.id)
                                        .collection(widget.bookInfo['name'])
                                        .doc(documents[index].id)
                                        .delete();
                                    print("OK5");
                                    documents.removeAt(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'message cannot dismissed')));
                                  });
                                }),
                                children: [
                                  SlidableAction(
                                    // (3)
                                    onPressed: (_) {
                                      FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(widget.bookInfo.id)
                                          .collection(widget.bookInfo['name'])
                                          .doc(documents[index].id)
                                          .update({'isChecked': true});
                                    }, // (4)
                                    backgroundColor: const Color.fromARGB(
                                        255, 48, 89, 115), // (4)
                                    foregroundColor: const Color.fromARGB(
                                        255, 249, 249, 249), // (4)
                                    icon: Icons.chair_rounded, // (4)
                                    label: '詳細',
                                  ),
                                  SlidableAction(
                                    // (3)
                                    onPressed: (_) {
                                      FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(widget.bookInfo.id)
                                          .collection(widget.bookInfo['name'])
                                          .doc(documents[index].id)
                                          .update({'isChecked': true});
                                      print("OK6");
                                    },
                                    backgroundColor: const Color.fromARGB(
                                        255, 48, 89, 115), // (4)
                                    foregroundColor: const Color.fromARGB(
                                        255, 222, 213, 196),
                                    icon: Icons.flag,
                                    label: 'Flag',
                                  ),
                                  SlidableAction(
                                    // (3)
                                    onPressed: (_) {
                                      FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(widget.bookInfo.id)
                                          .collection(widget.bookInfo['name'])
                                          .doc(documents[index].id)
                                          .delete();
                                    },
                                    backgroundColor: const Color.fromARGB(
                                        255, 48, 89, 115), // (4)
                                    foregroundColor:
                                        const Color.fromARGB(255, 239, 126, 86),
                                    icon: Icons.delete,
                                    label: '消去',
                                  ),
                                ],
                              ),
                              child: Card(
                                child: ListTile(
                                    //leading: documents[index]['image'],
                                    title: Text(documents[index]['question']),
                                    subtitle: Text(documents[index]['comment']),
                                    // 自分の投稿メッセージの場合は削除ボタンを表示
                                    trailing: IconButton(
                                      icon: const Icon(Icons.thumb_up),
                                      onPressed: () async {
                                        // 投稿メッセージのドキュメントを削除
                                        FirebaseFirestore.instance
                                            .collection('books')
                                            .doc(widget.bookInfo.id)
                                            .collection(widget.bookInfo['name'])
                                            .doc(documents[index].id)
                                            .update({
                                          'stage': documents[index]['stage'] + 1
                                        });
                                        print("OK7");
                                      },
                                    )),
                              ));
                        } else {
                          return Slidable(
                            // enabled: false,
                            startActionPane: ActionPane(
                              extentRatio: 0.2,
                              motion: const ScrollMotion(),
                              children: [
                                documents[index]['isChecked']
                                    ? SlidableAction(
                                        onPressed: (_) {
                                          //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                                          FirebaseFirestore.instance
                                              .collection('books')
                                              .doc(widget.bookInfo.id)
                                              .collection(
                                                  widget.bookInfo['name'])
                                              .doc(documents[index].id)
                                              .update({
                                            //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                                            'isChecked': false
                                            //updatedAt: firebase.firestore.FieldValue.serverTimestamp();
                                          });
                                        },
                                        backgroundColor: const Color.fromARGB(
                                            255, 48, 89, 115), // (4)
                                        foregroundColor: const Color.fromARGB(
                                            255, 222, 213, 196),
                                        icon: Icons.star,
                                        label: 'Unread',
                                      )
                                    : SlidableAction(
                                        onPressed: (_) {
                                          FirebaseFirestore.instance
                                              .collection('books')
                                              .doc(widget.bookInfo.id)
                                              .collection(
                                                  widget.bookInfo['name'])
                                              .doc(documents[index].id)
                                              .update({'isChecked': true});
                                          print("OK8");
                                        },
                                        backgroundColor: const Color.fromARGB(
                                            255, 48, 89, 115), // (4)
                                        foregroundColor: const Color.fromARGB(
                                            255, 239, 126, 86),
                                        icon: Icons.star,
                                        label: 'Read',
                                      )
                              ],
                            ),
                            child: Card(
                              child: ListTile(
                                  title: Text(documents[index]['question']),
                                  subtitle: Text(documents[index]['comment']),
                                  // 自分の投稿メッセージの場合は削除ボタンを表示
                                  trailing: IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () async {
                                      // 投稿メッセージのドキュメントを削除
                                      await FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(widget.bookInfo.id)
                                          .collection(widget.bookInfo['name'])
                                          .doc(documents[index].id)
                                          .delete();
                                      print("OK9");
                                    },
                                  )),
                            ),
                          );
                        }
                      });
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
              return AddBookCardsPage(widget.user, widget.bookInfo);
            }),
          );
        },
      ),
    );
  }
}
