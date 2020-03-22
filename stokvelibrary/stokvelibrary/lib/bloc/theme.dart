import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stokvelibrary/bloc/prefs.dart';

final ThemeBloc themeBloc = ThemeBloc();

class ThemeBloc {
  ThemeBloc() {
    initialize();
  }

  final StreamController<int> _themeController = StreamController.broadcast();
  final _rand = Random(DateTime.now().millisecondsSinceEpoch);

  get changeToTheme0 => _themeController.sink.add(0);

  get changeToTheme1 => _themeController.sink.add(1);

  get changeToTheme2 => _themeController.sink.add(2);

  int _themeIndex = 0;

  int get themeIndex => _themeIndex;

  initialize() async {
    _themeIndex = await Prefs.getThemeIndex();
    print(
        '📌 📌 📌 📌️ ThemeBloc: initialize:: adding index to stream ....theme index: $themeIndex');
    _themeController.sink.add(_themeIndex);
  }

  changeToTheme(int index) {
    print('✈️✈️ changeToTheme: adding index to stream ....');
    _themeController.sink.add(index);
  }

  changeToRandomTheme() {
    _themeIndex = _rand.nextInt(ThemeUtil.getThemeCount() - 1);
    _themeController.sink.add(_themeIndex);
    print('✈️✈️ ......... changeToRandomTheme: themeIndex: $_themeIndex');
    Prefs.setThemeIndex(_themeIndex);
  }

  closeStream() {
    _themeController.close();
  }

  get newThemeStream => _themeController.stream;
}

class ThemeUtil {
  static List<ThemeData> _themes = List();

  static int index;

  static ThemeData getTheme({int themeIndex}) {
    print('🌈 🌈 .......... getting theme with index: 🌈 $index');
    if (_themes.isEmpty) {
      _setThemes();
    }
    if (themeIndex == null) {
      if (index == null) {
        index = 0;
      } else {
        index++;
        if (index == _themes.length) {
          index = 0;
        }
      }
    } else {
      index = themeIndex;
    }
    return _themes.elementAt(index);
  }

  static int getThemeCount() {
    _setThemes();
    return _themes.length;
  }

  static var _rand = Random(DateTime.now().millisecondsSinceEpoch);

  static ThemeData getRandomTheme() {
    if (_themes.isEmpty) _setThemes();
    var index = _rand.nextInt(_themes.length - 1);
    return _themes.elementAt(index);
  }

  static ThemeData getThemeByIndex(int index) {
    if (index >= _themes.length || index < 0) index = 0;
    return _themes.elementAt(index);
  }

  static void _setThemes() {
    _themes.clear();

    _themes.add(ThemeData(
      fontFamily: GoogleFonts.pTSans().toString(),
      primaryColor: Colors.indigo.shade400,
      accentColor: Colors.pink,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.indigo[50],
      appBarTheme: AppBarTheme(
          color: Colors.indigo.shade300, brightness: Brightness.dark),
      textTheme: GoogleFonts.pTSansTextTheme(),
      buttonColor: Colors.blue,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.pink.shade300,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.pink[50],
      scaffoldBackgroundColor: Colors.pink[50],
      textTheme: GoogleFonts.ralewayTextTheme(),
      appBarTheme: AppBarTheme(color: Colors.pink[300]),
      buttonColor: Colors.indigo,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.josefinSans().toString(),
      primaryColor: Colors.teal,
      accentColor: Colors.purple,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.teal[50],
      textTheme: GoogleFonts.josefinSansTextTheme(),
      appBarTheme: AppBarTheme(color: Colors.teal.shade300),
      buttonColor: Colors.pink,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.brown,
      accentColor: Colors.yellow.shade900,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      textTheme: GoogleFonts.ralewayTextTheme(),
      scaffoldBackgroundColor: Colors.brown[50],
      appBarTheme: AppBarTheme(color: Colors.brown.shade300),
      buttonColor: Colors.blue,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.pink.shade300,
      accentColor: Colors.yellow.shade900,
      cardColor: Colors.white,
      backgroundColor: Colors.pink.shade100,
      scaffoldBackgroundColor: Colors.pink[50],
      appBarTheme: AppBarTheme(color: Colors.pink.shade400),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.blue,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.brown,
      accentColor: Colors.yellow.shade900,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.brown[50],
      appBarTheme: AppBarTheme(color: Colors.brown.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.blue,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.lime.shade800,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.lime[50],
      appBarTheme: AppBarTheme(color: Colors.lime.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.brown,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.blue.shade600,
      accentColor: Colors.red,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.blue[50],
      textTheme: GoogleFonts.ralewayTextTheme(),
      appBarTheme: AppBarTheme(color: Colors.blue.shade300),
      buttonColor: Colors.blue,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.blueGrey,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.blueGrey[50],
      appBarTheme: AppBarTheme(color: Colors.blueGrey.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.pink,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.purple.shade300,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.purple[50],
      appBarTheme: AppBarTheme(color: Colors.purple.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.pink,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.amber.shade900,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.amber[50],
      appBarTheme: AppBarTheme(color: Colors.amber.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.pink,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.deepOrange,
      accentColor: Colors.brown,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.deepOrange[50],
      appBarTheme: AppBarTheme(color: Colors.deepOrange.shade300),
      textTheme: GoogleFonts.ralewayTextTheme(),
      buttonColor: Colors.deepOrange,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    _themes.add(ThemeData(
      fontFamily: GoogleFonts.raleway().toString(),
      primaryColor: Colors.orange,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      scaffoldBackgroundColor: Colors.orange[50],
      textTheme: GoogleFonts.ralewayTextTheme(),
      appBarTheme: AppBarTheme(color: Colors.orange.shade300),
      buttonColor: Colors.pink,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        })));
    final darkTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      fontFamily: GoogleFonts.raleway().toString(),
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF212121),
      accentColor: Colors.white,
      scaffoldBackgroundColor: Colors.purple[100],
      textTheme: GoogleFonts.ralewayTextTheme(),
      accentIconTheme: IconThemeData(color: Colors.black),
      dividerColor: Colors.black12,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        }));

    _themes.add(darkTheme);

    final lightTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.white,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.raleway().toString(),
      backgroundColor: const Color(0xFFE5E5E5),
      accentColor: Colors.black,
      scaffoldBackgroundColor: Colors.pink[50],
      textTheme: GoogleFonts.ralewayTextTheme(),
      accentIconTheme: IconThemeData(color: Colors.white),
      dividerColor: Colors.white54,
    ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder()
        }));
    _themes.add(lightTheme);
  }
}
