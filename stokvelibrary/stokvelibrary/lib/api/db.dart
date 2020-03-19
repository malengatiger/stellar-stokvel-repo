import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobmongo/carrier.dart';
import 'package:mobmongo/mobmongo.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/constants.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class LocalDB {
  static const APP_ID = 'arAppID';
  static bool dbConnected = false;
  static int cnt = 0;

  static String databaseName = 'stokkie001';

  static Future _connectToLocalDB() async {
    if (dbConnected) {
      return null;
    }
    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 Connecting to MongoDB Mobile ... 🔵 🔵 🔵 🔵 🔵 🔵 🔵 ');
    try {
      await MobMongo.setAppID({
        'appID': APP_ID,
        'type': MobMongo.LOCAL_DATABASE,
      });
      await _createIndices();
      dbConnected = true;
      print(
          '👌 Connected to MongoDB Mobile. 🥬 DATABASE: $databaseName  🥬 APP_ID: $APP_ID  👌 👌 👌 '
          ' necessary indices created for routes and landmarks 🧩 🧩 🧩 \n');
    } on PlatformException catch (e) {
      print('👿👿👿👿👿👿👿👿👿👿 ${e.message}  👿👿👿👿');
      throw Exception(e);
    }
  }

  static Future _createIndices() async {
    var carr1 = Carrier(
        db: databaseName,
        collection: Constants.STOKVELS,
        index: {"stokvelId": 1});
    await MobMongo.createIndex(carr1);

    var carr3 = Carrier(
        db: databaseName,
        collection: Constants.MEMBERS,
        index: {"memberId": 1});
    await MobMongo.createIndex(carr3);

    var carr4 = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS,
        index: {"stokvel.stokvelId": 1});
    await MobMongo.createIndex(carr4);

    var carr5 = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        index: {"fromMember.memberId": 1});
    await MobMongo.createIndex(carr5);

    var carr5a = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        index: {"toMember.memberId": 1});
    await MobMongo.createIndex(carr5a);

    var carr6 = Carrier(
        db: databaseName, collection: Constants.CREDS, index: {"stokvelId": 1});
    await MobMongo.createIndex(carr6);

    var carr7 = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_ACCOUNT_RESPONSES,
        index: {"accountId": 1});
    await MobMongo.createIndex(carr7);

    var carr8 = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
        index: {"accountId": 1});
    await MobMongo.createIndex(carr8);

    print(
        'LocalDB: 🧩 🧩 🧩  🧩 🧩 🧩 ALL local database indices built! - 👌 👌 👌 \n\n');
  }

  static Future<List<Stokvel>> getStokvels() async {
    await _connectToLocalDB();
    List<Stokvel> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.STOKVELS,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      mList.add(Stokvel.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<List<Member>> getMembers() async {
    await _connectToLocalDB();
    List<Member> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.MEMBERS,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      mList.add(Member.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<Member> getMember(String memberId) async {
    List<Member> mList = await getMembers();
    Member member;
    mList.forEach((m) {
      if (m.memberId == memberId) {
        member = m;
      }
    });
    if (member == null) {
      member = await ListAPI.getMember(memberId);
      if (member != null) {
        await addMember(member: member);
      }
    }
    return member;
  }

  static Future<List<MemberPayment>> getMemberPayments(String memberId) async {
    await _connectToLocalDB();
    List<MemberPayment> mList = [];

    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.CREDS, query: {
      "eq": {"memberId": memberId}
    });
    List result = await MobMongo.query(carrier);
    result.forEach((r) {
      mList.add(MemberPayment.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<List<StokvelPayment>> getStokvelPayments(
      String stokvelId) async {
    await _connectToLocalDB();
    List<StokvelPayment> mList = [];

    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS,
        query: {
          "eq": {"stokvelId": stokvelId}
        });
    List result = await MobMongo.query(carrier);
    result.forEach((r) {
      mList.add(StokvelPayment.fromJson(jsonDecode(r)));
    });
    return mList;
  }

  static Future<List<AccountResponse>> getMemberAccountResponses() async {
    await _connectToLocalDB();
    List<AccountResponse> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.MEMBER_ACCOUNT_RESPONSES,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      try {
        mList.add(AccountResponse.fromJson(jsonDecode(r)));
      } catch (e) {
        print(e);
        print(
            'LocalDB: 🐸🐸🐸 getMemberAccountResponses: ......... 🐸the fuckup is here somewhere ....');
        throw Exception('Fuckup $e');
      }
    });
    return mList;
  }

  static Future<List<AccountResponse>> getStokvelAccountResponses() async {
    await _connectToLocalDB();
    List<AccountResponse> mList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      try {
        mList.add(AccountResponse.fromJson(jsonDecode(r)));
      } catch (e) {
        print(
            '=================================== heita, look below  =============================');
        print(e);
        print(
            'LocalDB: 🦠 🦠 🦠 getStokvelAccountResponses: .........  🦠 the fuckup is here somewhere .... 🦠 🦠 🦠');
        throw Exception('🔴 🔴 🔴 🔴 Fuckup 🔴 $e');
      }
    });
    return mList;
  }

  static Future<int> addStokvel({@required Stokvel stokvel}) async {
    await _connectToLocalDB();
    prettyPrint(stokvel.toJson(),
        ",,,,,,,,,,,,,,,,,,,,,,, STOKVEL TO BE ADDED TO local DB, check name etc.");

    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: Constants.STOKVELS, id: {
      'field': 'stokvelId',
      'value': stokvel.stokvelId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of stokvel delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVELS,
        data: stokvel.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of addStokvel insert: 🍎 $res 🍎 ');
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokvel: 🌼 1 added...: ${stokvel.name} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addMember({@required Member member}) async {
    await _connectToLocalDB();
    prettyPrint(member.toJson(), "MEMBER TO BE ADDED TO local DB");
    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: Constants.MEMBERS, id: {
      'field': 'memberId',
      'value': member.memberId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of member delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName, collection: Constants.MEMBERS, data: member.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addMember: 🌼 1 added...: ${member.name} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addStokvelAccountResponse(
      {@required AccountResponse accountResponse}) async {
    await _connectToLocalDB();
    prettyPrint(accountResponse.toJson(),
        "Stokvel AccountResponse TO BE ADDED TO local DB");
    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
        data: accountResponse.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokvelAccountResponse: 🌼 1 added...: ${accountResponse.accountId} 🔵 '
        '🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addMemberAccountResponse(
      {@required AccountResponse accountResponse}) async {
    await _connectToLocalDB();
    prettyPrint(accountResponse.toJson(),
        "Member AccountResponse TO BE ADDED TO local DB");
    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_ACCOUNT_RESPONSES,
        data: accountResponse.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addMemberAccountResponse: 🌼 1 added...: ${accountResponse.accountId} 🔵 '
        '🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addMemberPayment(
      {@required MemberPayment memberPayment}) async {
    await _connectToLocalDB();
    prettyPrint(
        memberPayment.toJson(), "MemberPayment TO BE ADDED TO local DB");
    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        data: memberPayment.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addMemberPayment: 🌼 1 added...: ${memberPayment.fromMember.name} 🔵 '
        'amount: ${memberPayment.amount} 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addStokvelPayment(
      {@required StokvelPayment stokvelPayment}) async {
    await _connectToLocalDB();
    prettyPrint(
        stokvelPayment.toJson(), "StokvelPayment TO BE ADDED TO local DB");

    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS,
        data: stokvelPayment.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokvelPayment: 🌼 1 added...: ${stokvelPayment.stokvel.name} 🔵 amount: ${stokvelPayment.amount}🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<int> addCredential(
      {@required StokkieCredential credential}) async {
    await _connectToLocalDB();
    prettyPrint(
        credential.toJson(), "StokkieCredential TO BE ADDED TO local DB");
    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.CREDS,
        data: credential.toJson());
    await MobMongo.insert(ca);
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokkieCredential: 🌼 1 added...: ${credential.accountId} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
  }

  static Future<Stokvel> getStokvelById(String stokvelId) async {
    await _connectToLocalDB();
    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.STOKVELS, query: {
      "eq": {"stokvelId": stokvelId}
    });
    List results = await MobMongo.query(carrier);
    List<Stokvel> list = List();
    results.forEach((r) {
      var mm = Stokvel.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }

    return list.first;
  }

  static Future<StokkieCredential> getMemberCredential(String memberId) async {
    await _connectToLocalDB();
    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.CREDS, query: {
      "eq": {"memberId": memberId}
    });
    List results = await MobMongo.query(carrier);
    List<StokkieCredential> list = List();
    results.forEach((r) {
      var mm = StokkieCredential.fromJson(json.decode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }

    print('🔵 🔵 🔵 🔵 🔵 🔵 🔵 getMemberCredential: 🦠 ${list.length}');
    return list.first;
  }

  static Future<StokkieCredential> getStokvelCredential(
      String stokvelId) async {
    await _connectToLocalDB();
    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.CREDS, query: {
      "eq": {"stokvelId": stokvelId}
    });
    List results = await MobMongo.query(carrier);
    List<StokkieCredential> list = List();
    results.forEach((r) {
      var mm = StokkieCredential.fromJson(json.decode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }

    print('🔵 🔵 🔵 🔵 🔵 🔵 🔵 getStokvelCredential: 🦠 ${list.length}');
    return list.first;
  }
}
