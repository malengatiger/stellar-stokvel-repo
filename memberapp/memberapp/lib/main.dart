import 'package:flutter/material.dart';
import 'package:member/ui/dashboard.dart';
import 'package:member/ui/welcome.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/slide_right.dart';

import 'bloc/member_bloc.dart';

void main() => runApp(MemberApp());
var themeIndex;

class MemberApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: themeIndex == null ? 0 : themeIndex,
        stream: themeBloc.newThemeStream,
        builder: (context, snapShot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Anchor',
            theme: snapShot.data == null
                ? ThemeUtil.getTheme(themeIndex: themeIndex)
                : ThemeUtil.getTheme(themeIndex: snapShot.data),
            home: MyHomePage(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    var isAuthed = await MemberBloc().isAuthenticated();
    print('🔵 🔵 $isAuthed is the result from bloc');
    if (!isAuthed) {
      Navigator.push(context, SlideRightRoute(widget: Welcome(null)));
      return;
    } else {
      Navigator.push(context, SlideRightRoute(widget: Dashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('ADMIN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Stokkie',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
