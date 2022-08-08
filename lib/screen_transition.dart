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

class Controller extends GetxController {
  //(1) 選択されたタブの番号
  var selected = 0.obs;
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
      Notifications(user),
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
  String barName = "本棚";
  List<String> namesList = ['本棚', 'オススメ', '課題', '通知', 'アカウント'];
  void changeName(name) => setState(() => barName = name);
  final views = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: Text(barName), actions: <Widget>[
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
              changeName(namesList[i]);
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.auto_stories_rounded),
                  label: namesList[0],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.star),
                  label: namesList[1],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment_rounded),
                  label: namesList[2],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: namesList[3],
                  backgroundColor: Colors.blue),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.people),
                  label: namesList[4],
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
