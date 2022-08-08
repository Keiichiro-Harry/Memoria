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
