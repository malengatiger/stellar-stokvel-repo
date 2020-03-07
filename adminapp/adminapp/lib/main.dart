import 'package:adminapp/bloc/admin_bloc.dart';
import 'package:adminapp/ui/dashboard.dart';
import 'package:adminapp/ui/welcome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/slide_right.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  var themeIndex;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminBloc>.value(
          value: AdminBloc(),
        ),

      ],
      child: StreamBuilder<int>(
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
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  void _checkAuth() async {
    
    var isAuthed = await adminBloc.isAuthenticated();
    print('$isAuthed is the result from bloc' );
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
              'Stokkie', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900),
            ),

          ],
        ),
      ),
    );
  }
}
