import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class Prefs {
  static Future saveMember(Member user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = user.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('user', jx);
    print("🌽 🌽 🌽 Prefs.user  SAVED: 🌽 ${user.toJson()}");
    return null;
  }
static Future<Member> getMember() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('user');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = new Member.fromJson(jx);
    print("🌽 🌽 🌽 Prefs.getUser 🧩  ${user.toJson()} retrieved");
    return user;
  }

  static void setMemberSeed(String seed) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('seed', seed);
    print('🔵 🔵 🔵 Prefs: seed cached ... 🍎 🍎 ');
  }

  static Future<String> getMemberSeed() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('seed');
    if (b == null) {
      return null;
    } else {
      print('🔵 🔵 🔵 Prefs: seed retrieved: $b 🍏 🍏 ');
      return b;
    }
  }
  static void addStokvelCredential(StellarCredential credential) async {
    final preferences = await SharedPreferences.getInstance();
    var creds = await getStokvelCredentials();
    if (creds == null) {
      creds = StellarCredentials([credential]);
    } else {
      creds.credentials.add(credential);
    }
    await preferences.setString('stokvelseed', jsonEncode(creds));
    print('🔵 🔵 🔵 Prefs: Stellar credential cached ... 🍎 🍎 ');
  }

  static Future<StellarCredentials> getStokvelCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('stokvelseed');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = StellarCredentials.fromJson(mJson);
      print('🔵 🔵 🔵 Prefs: Credentials retrieved, creds: ${creds.credentials.length} 🍏 🍏 ');
      return creds;
    }
  }

  static void setThemeIndex(int index) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('index', index);
    print('🔵 🔵 🔵 Prefs: theme index set to: $index 🍎 🍎 ');
  }

  static Future<int> getThemeIndex() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getInt('index');
    if (b == null) {
      return 0;
    } else {
      print('🔵 🔵 🔵  theme index retrieved: $b 🍏 🍏 ');
      return b;
    }
  }

}

