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
