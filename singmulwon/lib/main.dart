// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './plant_feed.dart';
import 'Plant/edit_plant.dart';
import 'Plant/manage_plant.dart';
import './home.dart';
import './community.dart';
import './account.dart';
import 'Provider/plants.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => Plants()),
  ], child: MyApp()));
  //수정: EditPlant에서 Provider 가져올 수 없다고 해서 수정함
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'singmul-won',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Page(),
        routes: {
          ManagePlant.routeName: (ctx) => ManagePlant(),
          EditPlant.routeName: (ctx) => EditPlant(),
        });
  }
}

class Page extends StatefulWidget {
  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  int selectedIndex = 2;
  final List<Widget> widgetOptions = <Widget>[
    //수정: 임시로 feed()대신 Container()넣어놓음
    //Feed(),
    Container(),
    ManagePlant(),
    Home(),
    Community(),
    Account(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[50],
        selectedItemColor: Colors.green[600],
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_florist), label: 'plant'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'my'),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
