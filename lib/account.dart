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
          widget.user.email != "guest@guest.com"
              ? Container(
                  padding: EdgeInsets.all(8),
                  child: Text('ログイン情報：${widget.user.email}'),
                )
              : Container(
                  padding: EdgeInsets.all(8),
                ),
          Container(
            height: 50,
            child: const Text('設定',
                style: TextStyle(color: Colors.white, fontSize: 32.0)),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.blue, Colors.white]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () async {
          // 投稿画面に遷移
          if (widget.user.email != "guest@guest.com") {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return Setting(widget.user);
              }),
            );
          }
        },
      ),
    );
  }
}
