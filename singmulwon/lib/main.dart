// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:flutter_singmulwon_app/Community/screens/boast_home_screen.dart';
import 'package:flutter_singmulwon_app/Community/screens/boast_result_screen.dart';
import 'package:flutter_singmulwon_app/Feed/feed_test.dart';
import 'package:flutter_singmulwon_app/Feed/my_feed_test.dart';
import 'package:flutter_singmulwon_app/core/color_schemes.g.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Community/screens/community_detail_screen.dart';
import 'Community/screens/community_home_screen.dart';
import 'Community/screens/community_write_screen.dart';

import 'Feed/feed_create_test.dart';
import 'Feed/feed_detail_test.dart';
import 'Feed/image_test.dart';
import 'Feed/image_upload.dart';
import 'Plant/edit_plant.dart';
import 'Plant/insert_plant.dart';
import 'Plant/manage_plant.dart';
import 'Provider/feeds.dart';
import 'Login/signin.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Community/provider/Users.dart';
void main() async{
  await dotenv.load(fileName:"assets/.env");

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => Feeds(),),
    ChangeNotifierProvider(create: (context)=> Users(),),
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
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: "NotoSans",
        ),
        home: Login(),
        routes: {
          ManagePlant.routeName: (ctx) => ManagePlant(),
          EditPlant.routeName: (ctx) => EditPlant(),
          InsertPlant.routeName: (ctx) => InsertPlant(),
          FeedCreate.routeName: (ctx) => FeedCreate(),
          FeedPage.routeName: (ctx) => FeedPage(),
          HomePage.routeName: (ctx) => HomePage('test1'),
          MyFeedPage.routeName: (ctx) => MyFeedPage(userId: "test1", currentUserId: "test1"),
          FeedDetail.routeName: (ctx) => FeedDetail(),
          CommunityHomeScreen.routeName: (ctx) => CommunityHomeScreen(),
          CommunityDetailScreen.routeName: (ctx) => CommunityDetailScreen(),
          CommunityWriteScreen.routeName: (ctx) => CommunityWriteScreen(),
          BoastHomeScreen.routeName: (ctx) => BoastHomeScreen(),
          BoastResultScreen.routeName: (ctx) =>BoastResultScreen()
        });
  }
}

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLogin = false;
  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = (prefs.get('isLogin') ?? false);

    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isLogin ? _signInWidget() : HomePage('?');
  }

  Widget _signInWidget() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[SignIn()],
        ),
      ),
    );
  }
}
