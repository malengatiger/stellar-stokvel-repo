import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class Prefs {
  static Future saveMember(Member member) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = member.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('member', jx);
    print("🌽 🌽 🌽 Prefs.saveMember  SAVED: 🌽 ${member.toJson()}");
    return null;
  }

  static Future<Member> getMember() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('member');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var member = new Member.fromJson(jx);
    print("🌽 🌽 🌽 Prefs.getMember 🧩  ${member.toJson()} retrieved");
    return member;
  }

  static Future saveCredential(StokkieCredential credential) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = credential.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('credential', jx);
    print("🌽 🌽 🌽 Prefs.StokkieCredential  SAVED: 🌽");
    return null;
  }

  static Future<StokkieCredential> getCredential() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('credential');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var cred = new StokkieCredential.fromJson(jx);
    print(
        "🌽 🌽 🌽 Prefs.StokkieCredential 🧩 credential retrieved: ${cred.accountId}");
    return cred;
  }

  static void addStokvelCredential(StokkieCredential credential) async {
    print('🔵 🔵 🔵 Prefs: adding Stellar credential ...');
    final preferences = await SharedPreferences.getInstance();
    var creds = await getStokvelCredentials();
    if (creds == null) {
      creds = StokkieCredentials([credential]);
    } else {
      creds.credentials.add(credential);
    }
    await preferences.setString('stokvelseed', jsonEncode(creds));
    print('🔵 🔵 🔵 Prefs: Stellar credential cached ... 🍎 🍎 ');
  }

  static Future<StokkieCredentials> getStokvelCredentials() async {
    print('🔵 🔵 🔵 Prefs: getting Stellar credentials cached ...');
    final preferences = await SharedPreferences.getInstance();
    var b = preferences.getString('stokvelseed');
    if (b == null) {
      return null;
    } else {
      var mJson = jsonDecode(b);
      var creds = StokkieCredentials.fromJson(mJson);
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
