import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
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
    print('🔵 🔵 🔵 Prefs: adding Stellar credential ...');
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
    print('🔵 🔵 🔵 Prefs: getting Stellar credentials cached ...');
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('stokvelseed');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = StellarCredentials.fromJson(mJson);
      print(
          '🔵 🔵 🔵 Prefs: Credentials retrieved, creds: ${creds.credentials.length} 🍏 🍏 ');
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

  static void addStokvelAccountResponseBag(AccountResponseBag bag) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('stokvelaccount', jsonEncode(bag.toJson()));
    print(
        '🔵 🔵 🔵 Prefs: Stellar Stokvel AccountResponseBag cached ... 🍎 🍎 ');
  }

  static Future<AccountResponseBag> getStokvelAccountResponseBag() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('stokvelaccount');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = AccountResponseBag.fromJson(mJson);
      print('🔵 🔵 🔵 Prefs: Stokvel AccountResponseBag retrieved, 🍏 🍏 ');
      return creds;
    }
  }

  static void addMemberAccountResponseBag(AccountResponseBag bag) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('memberaccount', jsonEncode(bag.toJson()));
    print(
        '🔵 🔵 🔵 Prefs: Stellar Member AccountResponseBag cached ... 🍎 🍎 ');
  }

  static Future<AccountResponseBag> getMemberAccountResponseBag() async {
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('memberaccount');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = AccountResponseBag.fromJson(mJson);
      print('🔵 🔵 🔵 Prefs: Member AccountResponseBag retrieved, 🍏 🍏 ');
      return creds;
    }
  }
}
