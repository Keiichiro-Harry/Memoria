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
