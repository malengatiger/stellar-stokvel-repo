import 'package:flutter/material.dart';
import 'package:member/ui/dashboard.dart';
import 'package:member/ui/welcome.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';

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
            navigatorKey: navigatorKey,
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
    var cred = await Prefs.getCredential();
    if (cred != null) {
      Navigator.push(context, SlideRightRoute(widget: Dashboard()));
    } else {
      Navigator.push(context, SlideRightRoute(widget: Welcome(null)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stokkie Network'),
      ),
      backgroundColor: Colors.brown[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Stokkie',
              style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
