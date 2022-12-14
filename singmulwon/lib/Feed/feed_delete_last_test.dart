import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'my_feed_test.dart';
import 'feed_test.dart';

final _textController = new TextEditingController();

Future fetchFeed(String userId, String feedId) async {
  var url =
      'http://13.209.68.93/ubuntu/flutter/feed/feed_delete.php?userId=' +
          userId +
          '&feedId=' +
          feedId;
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    //만약 서버가 ok응답을 반환하면, json을 파싱합니다
    print('응답했다');
    var tmp = json.decode(utf8.decode(response.bodyBytes));
    print(tmp);
    return tmp;
  } else {
    //만약 응답이 ok가 아니면 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

// void main() => runApp(MaterialApp(
//   home: FeedDeleteResgister(),
//   initialRoute: '/',
//   routes: {
//     // When we navigate to the "/" route, build the FirstScreen Widget
//     // "/" Route로 이동하면, FirstScreen 위젯을 생성합니다.
//     '/myfeed': (context) => MyFeedPage(),
//     // "/second" route로 이동하면, SecondScreen 위젯을 생성합니다.
//     '/feed': (context) => FeedPage(),
//   },
// )
// );

class FeedDeleteResgister extends StatefulWidget {
  final String userId;
  final String feedId;

  const FeedDeleteResgister(
      {Key key, @required this.userId, @required this.feedId})
      : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState(userId, feedId);
}

class _FeedPageState extends State<FeedDeleteResgister> {
  String userId;
  String feedId;

  _FeedPageState(this.userId, this.feedId);

  @override
  void initState() {
    super.initState();
    fetchFeed(userId, feedId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('피드 삭제'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: Text("피드 삭제 완료!"),
          ),
          TextButton(
            child: Text("돌아가기"),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyFeedPage(userId: userId, currentUserId: userId))),
          )
        ],
      ),
    );
  }
}
