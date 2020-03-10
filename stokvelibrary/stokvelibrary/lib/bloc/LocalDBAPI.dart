import 'package:flutter/cupertino.dart';
import 'package:mobmongo/carrier.dart';
import 'package:mobmongo/mobmongo.dart';
import 'package:flutter/services.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

import '../functions.dart';

class LocalDBAPI {
  static const APP_ID = 'arAppID';
  static bool dbConnected = false;
  static int cnt = 0;

  static String databaseName = 'stokkie001';

  static Future setDatabaseName({@required String name}) async {
    print(
        '\n\n\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 setDatabaseName: $name MongoDB Mobile .. . 🔵 🔵 🔵 🔵 🔵 🔵 🔵 ');
    if (name == null) {
      throw Exception('The database name cannot be null');
    }
    databaseName = name;
  }

  static Future setAppID() async {
    print('\n\n🍎 🍎 🍎  setting MongoDB Mobile appID  🍎 🍎 🍎  🍎 🍎 🍎 ');
    try {
      var res = await MobMongo.setAppID({
        'appID': APP_ID,
        'type': MobMongo.LOCAL_DATABASE,
      });
      print(res);
    } on PlatformException catch (f) {
      print('👿👿👿👿👿👿👿👿 PlatformException 🍎 🍎 🍎 - $f');
      throw Exception(f.message);
    }
  }

  static Future _connectToLocalDB() async {
    if (databaseName == null) {
      throw Exception(
          'Please set the database name using setDatabaseName(String name)');
    }
    if (dbConnected) {
      return null;
    }
    print(
        '\n\n\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 Connecting to MongoDB Mobile .. . 🔵 🔵 🔵 🔵 🔵 🔵 🔵 ');
    try {
      var res = await MobMongo.setAppID({
        'appID': APP_ID,
        'type': MobMongo.LOCAL_DATABASE,
      });
      await _createIndices();

      dbConnected = true;
      print(
          '👌 Connected to MongoDB Mobile. 🥬 DATABASE: $databaseName  🥬 APP_ID: $APP_ID  👌 👌 👌 '
          ' necessary indices created for routes and landmarks 🧩 🧩 🧩 \n\n\n');
    } on PlatformException catch (e) {
      print('👿👿👿👿👿👿👿👿👿👿 ${e.message}  👿👿👿👿');
      throw Exception(e);
    }
  }

  static Future _createIndices() async {
    var carr1 = Carrier(
        db: databaseName, collection: 'stokvels', index: {"stokvelId": 1});
    await MobMongo.createIndex(carr1);
    var carr3 = Carrier(
        db: databaseName, collection: 'members', index: {"memberId": 1});

    await MobMongo.createIndex(carr3);

    print(
        'LocalDBAPI: 🧩 🧩 🧩  🧩 🧩 🧩 ALL local indices built! - 👌 👌 👌 \n\n');
  }

  static Future getCreds() async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
      db: databaseName,
      collection: 'creds',
    );
    var result = await MobMongo.getAll(carrier);
    return result;
  }

  static Future getMembers() async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
      db: databaseName,
      collection: 'members',
    );
    var result = await MobMongo.getAll(carrier);
    return result;
  }

  static Future getStokvels() async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
      db: databaseName,
      collection: 'stokvels',
    );
    var result = await MobMongo.getAll(carrier);
    return result;
  }

  static Future<int> addStokvel({@required Stokvel stokvel}) async {
    await _connectToLocalDB();
    prettyPrint(stokvel.toJson(), "STOKVEL TO BE ADDED TO local DB");

    var start = DateTime.now();

    Carrier ca =
        Carrier(db: databaseName, collection: 'stokvels', data: stokvel.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of stokvel insert: 🍎 $res 🍎 ');

    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokvel: 🌼 1 added...: ${stokvel.name} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return cnt;
  }

  static Future<int> addCredential(
      {@required StellarCredential credential}) async {
    await _connectToLocalDB();
    prettyPrint(credential.toJson(), "STOKVEL CREDENTIAL TO BE ADDED TO local DB");

    var start = DateTime.now();

    Carrier ca =
        Carrier(db: databaseName, collection: 'creds', data: credential.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of cred insert: 🍎 $res 🍎 ');

    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addCredential: 🌼 1 added...: ${credential.accountId} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return cnt;
  }

  static Future<int> addMember({@required Member member}) async {
    await _connectToLocalDB();
    prettyPrint(member.toJson(), "MEMBER TO BE ADDED TO local DB");

    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: 'members', id: {
      'field': 'memberId',
      'value': member.memberId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of member delete: 🍎 $resDelete 🍎 ');

    Carrier ca =
        Carrier(db: databaseName, collection: 'members', data: c.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of member insert: 🍎 $res 🍎 ');

    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addMember: 🌼 1 added...: ${member.name} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return cnt;
  }
}
