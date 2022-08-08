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

void main() {
  // Fireabse初期化
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class Controller extends GetxController {
  //(1) 選択されたタブの番号
  var selected = 0.obs;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // アプリ名
      title: 'Memoria',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.blue,
      ),
      // ログイン画面を表示
      home: const LoginPage(),
    );
  }
}

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                  child: Text('ユーザー登録'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ユーザー登録に成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      Navigator.of(context).pushReplacement(
                        //awaitを消した
                        MaterialPageRoute(builder: (context) {
                          return ScreenTransition(result.user!);
                        }),
                      );
                    } catch (e) {
                      // 登録に失敗した場合
                      setState(() {
                        infoText = "登録に失敗しました：${e.toString()}";
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログイン登録ボタン
                child: OutlinedButton(
                  child: Text('ログイン'),
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                        // email: email,
                        // password: password,
                        email: "keiichiroharry884@gmail.com",
                        password: "Keiichiro884@",
                      );
                      // ログインに成功した場合
                      // チャット画面に遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ScreenTransition(result.user!);
                        }),
                      );
                    } catch (e) {
                      // ログインに失敗した場合
                      setState(() {
                        infoText = "ログインに失敗しました：${e.toString()}";
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//画面遷移中央Widget
class ScreenTransition extends StatefulWidget {
  late final List<Widget> _screens;

  final User user;

  ScreenTransition(this.user, {Key? key}) : super(key: key) {
    _screens = [
      BookShelf(user),
      Recommendation(user),
      Assingments(user),
      Notification(user),
      Account(user)
    ];
  }
  @override
  State<ScreenTransition> createState() => _ScreenTransitionState();
}

//ScreenTransition _screenTransition = _ScreenTransition();

class _ScreenTransitionState extends State<ScreenTransition> {
  //(2) PageViewとBottomBarを連動させるための準備
  // final PageController pager = PageController();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var state = Get.put(Controller());
  String bar_name = "本棚";
  List<String> names_list = ['本棚', 'オススメ', '課題', '通知', 'アカウント'];
  void change_name(name) => setState(() => bar_name = name);
  final views = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: Text(bar_name), actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                // ログイン画面に遷移＋チャット画面を破棄
                await FirebaseAuth.instance.signOut();
                // ログイン画面に遷移＋チャット画面を破棄
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
            ),
          ]),
          //(3) ページ切替機構
          body: widget._screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (int i) {
              _onItemTapped(i);
              state.selected.value = i;
              _ScreenTransitionState().change_name(names_list[i]);
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.auto_stories_rounded),
                  label: names_list[0],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.star),
                  label: names_list[1],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment_rounded),
                  label: names_list[2],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: names_list[3],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.people),
                  label: names_list[4],
                  backgroundColor: Colors.blue),
            ],
            // PageView(
            //   controller: pager,
            //   children: <Widget>[
            //     BookShelf(widget.user),
            //     Recommendation(widget.user),
            //     Assingments(
            //         widget.user), //widget.userでStatefulWidgetが受け取るところから引っ張ってこれる！
            //     Notification(widget.user),
            //     Account(widget.user),
            //   ],
            //   onPageChanged: (int i) {
            //     state.selected.value = i;
            //   },
          ),
          //(4) 下のナビゲーションバー
          // bottomNavigationBar: Obx(() => BottomNavigationBar(
          //       items: [
          //         BottomNavigationBarItem(
          //             icon: Icon(Icons.auto_stories_rounded),
          //             label: names_list[0],
          //             backgroundColor: Colors.blue),
          //         BottomNavigationBarItem(
          //             icon: Icon(Icons.star),
          //             label: names_list[1],
          //             backgroundColor: Colors.blue),
          //         BottomNavigationBarItem(
          //             icon: Icon(Icons.assignment_rounded),
          //             label: names_list[2],
          //             backgroundColor: Colors.blue),
          //         BottomNavigationBarItem(
          //             icon: Icon(Icons.chat_bubble_outline_rounded),
          //             label: names_list[3],
          //             backgroundColor: Colors.blue),
          //         BottomNavigationBarItem(
          //             icon: Icon(Icons.people),
          //             label: names_list[4],
          //             backgroundColor: Colors.blue),
          //       ],
          //       currentIndex: state.selected.value,
          //       onTap: (int i) {
          //         state.selected.value = i;
          //         pager.jumpToPage(i);
          //         _screenTransition.change_name(names_list[i]);
          //       },
          // )),
        ));
  }
}

class BookShelf extends StatefulWidget {
  BookShelf(this.user);
  // ユーザー情報
  final User user;
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
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        //if (documents[index]['email'] == widget.user.email) {
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
                                            .doc(documents[index].id)
                                            .update({'isChecked': true});
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
                                    .doc(documents[index].id)
                                    .delete();
                                documents.removeAt(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('message cannot dismissed')));
                              });
                            }),
                            children: [
                              SlidableAction(
                                // (3)
                                onPressed: (_) {
                                  FirebaseFirestore.instance
                                      .collection('books')
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
                                      .doc(documents[index].id)
                                      .update({'isChecked': true});
                                },
                                backgroundColor: const Color.fromARGB(
                                    255, 48, 89, 115), // (4)
                                foregroundColor:
                                    const Color.fromARGB(255, 222, 213, 196),
                                icon: Icons.flag,
                                label: 'Flag',
                              ),
                              SlidableAction(
                                // (3)
                                onPressed: (_) {
                                  FirebaseFirestore.instance
                                      .collection('books')
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
                              child: documents[index]['image'] != null
                                  ? ListTile(
                                      onTap: () {},
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['name']),
                                      subtitle:
                                          Text(documents[index]['comment']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon:
                                                  const Icon(Icons.thumb_down),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                // await FirebaseFirestore.instance
                                                //     .collection('posts')
                                                //     .doc(documents[index].id)
                                                //     .delete();
                                              },
                                            )
                                          : null)
                                  : ListTile(
                                      onTap: () {},
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['name']),
                                      subtitle:
                                          Text(documents[index]['comment']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon:
                                                  const Icon(Icons.thumb_down),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                // await FirebaseFirestore.instance
                                                //     .collection('posts')
                                                //     .doc(documents[index].id)
                                                //     .delete();
                                              },
                                            )
                                          : null)),
                        );
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
              return AddBookPage(widget.user);
            }),
          );
        },
      ),
    );
  }
}

class BookCards extends StatefulWidget {
  BookCards(this.user);
  // ユーザー情報
  final User user;
  @override
  State<BookCards> createState() => _BookCardsState();
}

class _BookCardsState extends State<BookCards> {
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
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        if (documents[index]['email'] == widget.user.email) {
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
                                              .collection('posts')
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
                                              .collection('posts')
                                              .doc(documents[index].id)
                                              .update({'isChecked': true});
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
                                      .collection('posts')
                                      .doc(documents[index].id)
                                      .delete();
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
                                        .collection('posts')
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
                                        .collection('posts')
                                        .doc(documents[index].id)
                                        .update({'isChecked': true});
                                  },
                                  backgroundColor: const Color.fromARGB(
                                      255, 48, 89, 115), // (4)
                                  foregroundColor:
                                      const Color.fromARGB(255, 222, 213, 196),
                                  icon: Icons.flag,
                                  label: 'Flag',
                                ),
                                SlidableAction(
                                  // (3)
                                  onPressed: (_) {
                                    FirebaseFirestore.instance
                                        .collection('books')
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
                              child: documents[index]['image'] != null
                                  ? ListTile(
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['text']),
                                      subtitle: Text(documents[index]['email']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                await FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(documents[index].id)
                                                    .delete();
                                              },
                                            )
                                          : null)
                                  : ListTile(
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['text']),
                                      subtitle: Text(documents[index]['email']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                await FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(documents[index].id)
                                                    .delete();
                                              },
                                            )
                                          : null),
                            ),
                          );
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
                                              .collection('posts')
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
                                              .collection('posts')
                                              .doc(documents[index].id)
                                              .update({'isChecked': true});
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
                                  title: Text(documents[index]['text']),
                                  subtitle: Text(documents[index]['email']),
                                  // 自分の投稿メッセージの場合は削除ボタンを表示
                                  trailing: documents[index]['email'] ==
                                          widget.user.email
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            // 投稿メッセージのドキュメントを削除
                                            await FirebaseFirestore.instance
                                                .collection('posts')
                                                .doc(documents[index].id)
                                                .delete();
                                          },
                                        )
                                      : null),
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
              return AddPostPage(widget.user);
            }),
          );
        },
      ),
    );
  }
}

class Recommendation extends StatelessWidget {
  Recommendation(this.user);
  // ユーザー情報
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(document['email']),
                          // 自分の投稿メッセージの場合は削除ボタンを表示
                          trailing: document['email'] == user.email
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを削除
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(document.id)
                                        .delete();
                                  },
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
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
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}

class Assingments extends StatelessWidget {
  // 引数からユーザー情報を受け取れるようにする
  Assingments(this.user);
  // ユーザー情報
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // title: Text('チャット'),
      // actions: <Widget>[
      // IconButton(
      // icon: Icon(Icons.logout),
      // onPressed: () async {
      // ログイン画面に遷移＋チャット画面を破棄
      // await FirebaseAuth.instance.signOut();
      // ログイン画面に遷移＋チャット画面を破棄
      // await Navigator.of(context).pushReplacement(
      // MaterialPageRoute(builder: (context) {
      // return LoginPage();
      // }),
      // );
      // },
      // ),
      // ],
      // ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(document['email']),
                          // 自分の投稿メッセージの場合は削除ボタンを表示
                          trailing: document['email'] == user.email
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを削除
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(document.id)
                                        .delete();
                                  },
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
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
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}

class Notification extends StatefulWidget {
  Notification(this.user);
  // ユーザー情報
  final User user;
  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
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
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        if (documents[index]['email'] == widget.user.email) {
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
                                              .collection('posts')
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
                                              .collection('posts')
                                              .doc(documents[index].id)
                                              .update({'isChecked': true});
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
                                      .collection('posts')
                                      .doc(documents[index].id)
                                      .delete();
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
                                        .collection('posts')
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
                                        .collection('posts')
                                        .doc(documents[index].id)
                                        .update({'isChecked': true});
                                  },
                                  backgroundColor: const Color.fromARGB(
                                      255, 48, 89, 115), // (4)
                                  foregroundColor:
                                      const Color.fromARGB(255, 222, 213, 196),
                                  icon: Icons.flag,
                                  label: 'Flag',
                                ),
                                SlidableAction(
                                  // (3)
                                  onPressed: (_) {
                                    FirebaseFirestore.instance
                                        .collection('books')
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
                              child: documents[index]['image'] != null
                                  ? ListTile(
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['text']),
                                      subtitle: Text(documents[index]['email']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                await FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(documents[index].id)
                                                    .delete();
                                              },
                                            )
                                          : null)
                                  : ListTile(
                                      //leading: documents[index]['image'],
                                      title: Text(documents[index]['text']),
                                      subtitle: Text(documents[index]['email']),
                                      // 自分の投稿メッセージの場合は削除ボタンを表示
                                      trailing: documents[index]['email'] ==
                                              widget.user.email
                                          ? IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                // 投稿メッセージのドキュメントを削除
                                                await FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(documents[index].id)
                                                    .delete();
                                              },
                                            )
                                          : null),
                            ),
                          );
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
                                              .collection('posts')
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
                                              .collection('posts')
                                              .doc(documents[index].id)
                                              .update({'isChecked': true});
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
                                  title: Text(documents[index]['text']),
                                  subtitle: Text(documents[index]['email']),
                                  // 自分の投稿メッセージの場合は削除ボタンを表示
                                  trailing: documents[index]['email'] ==
                                          widget.user.email
                                      ? IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            // 投稿メッセージのドキュメントを削除
                                            await FirebaseFirestore.instance
                                                .collection('posts')
                                                .doc(documents[index].id)
                                                .delete();
                                          },
                                        )
                                      : null),
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
              return AddPostPage(widget.user);
            }),
          );
        },
      ),
    );
  }
}

//基本的なStatefulWidgetの書き方はこう
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';

// class MyWidget extends StatefulWidget {
//   const MyWidget({Key? key}) : super(key: key);

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   @override
//   Widget build(BuildContext context) {

//   }
// }

class Account extends StatefulWidget {
  //参照⇨https://qiita.com/agajo/items/50d5d7497d28730de1d3
  Account(this.user);
  // ユーザー情報
  final User user;
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
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
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(document['email']),
                          // 自分の投稿メッセージの場合は削除ボタンを表示
                          trailing: document['email'] == widget.user.email
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを削除
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(document.id)
                                        .delete();
                                  },
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return Setting(widget.user);
            }),
          );
        },
      ),
    );
  }
}

class Setting extends StatelessWidget {
  Setting(this.user);
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: <Widget>[
        const SizedBox(height: 200),
        Container(
          height: 50,
          child: const Text('設定',
              style: TextStyle(color: Colors.white, fontSize: 32.0)),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.purpleAccent, Colors.white]),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 30,
          child: ElevatedButton.icon(
            onPressed: () async {
              // 1つ前の画面に戻る
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.thumb_up),
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              elevation: 5,
            ),
            label: Text('戻る'),
          ),
        ),
      ]),
    ));
  }
}

// チャット画面用Widget

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  AddPostPage(this.user);
  final User user;

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String messageText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              TextFormField(
                decoration: InputDecoration(labelText: '投稿メッセージ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('投稿'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = widget.user.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      'text': messageText,
                      'email': email,
                      'date': date,
                      'isChecked': false,
                    });
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

class AddBookPage extends StatefulWidget {
  AddBookPage(this.user);
  final User user;

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  String questionText = '';
  String answerText = '';
  String nameText = '';
  String commentText = '';
  String tagText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('単語帳を追加'),
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
              TextFormField(
                decoration: InputDecoration(labelText: '名前'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    nameText = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'コメント'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    commentText = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'タグ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    tagText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('単語帳を追加'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = widget.user.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('books') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      // 'question': questionText,
                      // 'answer': answerText,
                      'email': email,
                      'commnet': commentText,
                      'tag': tagText,
                      'date': date,
                      'isChecked': false,
                      'name': nameText,
                    });
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

class Memoria_Game extends StatefulWidget {
  final User user;
  final List<List> wordlist;
  Memoria_Game(this.user, this.wordlist);
  @override
  _Memoria_GameState createState() => _Memoria_GameState();
}

class _Memoria_GameState extends State<Memoria_Game> {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Memoria Game'), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return BookShelf(widget.user);
                }),
              );
            },
          ),
        ]),
        //body: _screens[_selectedIndex],
      ),
    );
  }
}
