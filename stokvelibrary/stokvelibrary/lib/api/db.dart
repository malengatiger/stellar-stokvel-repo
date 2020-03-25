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
   
    try {
      await MobMongo.setAppID({
        'appID': APP_ID,
        'type': MobMongo.LOCAL_DATABASE,
      });
      await _createIndices();
      dbConnected = true;
      print(
          '👌 Connected to MongoDB Mobile. 🥬 DATABASE: $databaseName  🥬 APP_ID: $APP_ID  👌 👌 👌 '
          ' necessary indices created for all models 🧩 🧩 🧩 \n');
      return null;
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
        collection: Constants.STOKVEL_PAYMENTS_RECEIVED,
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

  static Future<List<Member>> getStokvelMembers(String stokvelId) async {
    List<Member> mList = await getMembers();
    List<Member> sList = [];
    mList.forEach((m) {
      m.stokvelIds.forEach((id) {
        if (id == stokvelId) {
          sList.add(m);
        }
      });
    });
    return sList;
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
    await _connectToLocalDB();
    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.MEMBERS,
        query: {
          "eq": {"memberId": memberId}
        });
    List results = await MobMongo.query(carrier);
    List<Member> list = List();
    results.forEach((r) {
      var mm = Member.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  static Future<List<MemberPayment>> getMemberPaymentsMade(String memberId) async {
    await _connectToLocalDB();
    List<MemberPayment> mList = [];

    Carrier carrier =
        Carrier(db: databaseName, collection: Constants.MEMBER_PAYMENTS, query: {
      "eq": {"fromMember.memberId": memberId}
    });
    List result = await MobMongo.query(carrier);
    result.forEach((r) {
      var mp = MemberPayment.fromJson(jsonDecode(r));
      mList.add(mp);
    });
    return mList;
  }
  static Future<List<MemberPayment>> getMemberPaymentsReceived(String memberId) async {
    await _connectToLocalDB();
    List<MemberPayment> mList = [];

    Carrier carrier =
    Carrier(db: databaseName, collection: Constants.MEMBER_PAYMENTS, query: {
      "eq": {"toMember.memberId": memberId}
    });
    List result = await MobMongo.query(carrier);
    result.forEach((r) {
      var mp = MemberPayment.fromJson(jsonDecode(r));
      mList.add(mp);
    });
    return mList;
  }

  static Future<List<StokvelPayment>> getStokvelPayments( String stokvelId) async {
    await _connectToLocalDB();
    List<StokvelPayment> mList = [];

    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS_RECEIVED,
        query: {
          "eq": {"stokvelId": stokvelId}
        });
    List result = await MobMongo.query(carrier);
    result.forEach((r) {
      mList.add(StokvelPayment.fromJson(jsonDecode(r)));
    });
    return mList;
  }
  static Future<List<StokvelGoal>> getStokvelGoals(String stokvelId) async {
    await _connectToLocalDB();
    List<StokvelGoal> mList = [];
    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_GOALS,
        query: {
          "eq": {"stokvel.stokvelId": stokvelId}
        });
    List result = await MobMongo.query(carrier);
    print('getStokvelGoals ..... MobMongo result found ${result.length} goals');
    result.forEach((r) {
      mList.add(StokvelGoal.fromJson(jsonDecode(r)));
    });
    mList.sort((a,b) => b.date.compareTo(a.date));
    print('getStokvelGoals ..... found ${mList.length} goals');
    return mList;
  }


  static Future<AccountResponse> getLatestMemberAccountResponse(
      String accountId) async {
    var responses = await getMemberAccountResponses();
    for (var response in responses) {
      if (response.accountId == accountId) {
        return response;
      }
    }
    return null;
  }

  static Future<List<AccountResponse>> getMemberAccountResponses() async {
    await _connectToLocalDB();
    List<AccountResponse> mList = [];
    List<AccountResponseCache> cacheList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.MEMBER_ACCOUNT_RESPONSES,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      try {
        cacheList.add(AccountResponseCache.fromJson(jsonDecode(r)));
      } catch (e) {
        throw Exception('Fuckup $e');
      }
    });
    if (cacheList.isNotEmpty) {
      cacheList.sort((a, b) => b.date.compareTo(a.date));
    }
    cacheList.forEach((c) {
      mList.add(c.accountResponse);
    });
    return mList;
  }

  static Future<AccountResponse> getLatestStokvelAccountResponse(
      String accountId) async {
    var responses = await getStokvelAccountResponses();
    for (var response in responses) {
      if (response.accountId == accountId) {
        return response;
      }
    }
    return null;
  }

  static Future<List<AccountResponse>> getStokvelAccountResponses() async {
    await _connectToLocalDB();
    List<AccountResponse> mList = [];
    List<AccountResponseCache> cacheList = [];
    Carrier carrier = Carrier(
      db: databaseName,
      collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
    );
    List result = await MobMongo.getAll(carrier);
    result.forEach((r) {
      try {
        cacheList.add(AccountResponseCache.fromJson(jsonDecode(r)));
      } catch (e) {
        throw Exception('🔴 🔴 🔴 🔴 Fuckup 🔴 $e');
      }
    });
    if (cacheList.isNotEmpty) {
      cacheList.sort((a, b) => b.date.compareTo(a.date));
    }
    cacheList.forEach((c) {
      mList.add(c.accountResponse);
    });
    return mList;
  }

  static Future<int> addStokvelGoal({@required StokvelGoal goal}) async {
    await _connectToLocalDB();

    var start = DateTime.now();
    Carrier c = Carrier(db: databaseName, collection: Constants.STOKVEL_GOALS, id: {
      'field': 'stokvelGoalId',
      'value': goal.stokvelGoalId,
    });
    var resDelete = await MobMongo.delete(c);
    print('🦠  Result of stokvelGoal delete: 🍎 $resDelete 🍎 ');

    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_GOALS,
        data: goal.toJson());
    var res = await MobMongo.insert(ca);
    print('🦠  Result of addStokvelGoal insert: 🍎 $res 🍎 ');
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inMilliseconds;
    print(
        '🍎 addStokvelGoal: 🌼 1 added...: ${goal.name} 🔵 🔵  elapsed: $elapsedSecs milliseconds 🔵 🔵 ');
    return 0;
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
    var start = DateTime.now();
    var cache = AccountResponseCache(
        DateTime.now().toUtc().toIso8601String(), accountResponse);
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_ACCOUNT_RESPONSES,
        data: cache.toJson());
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
    var cache = AccountResponseCache(
        DateTime.now().toUtc().toIso8601String(), accountResponse);
    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_ACCOUNT_RESPONSES,
        data: cache.toJson());
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

    //todo - check if payment exists before adding it
    var mp = await getMemberPaymentById(memberPayment.paymentId);
    if (mp != null) {
      return 0;
    }

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
    var mp = await getStokvelPaymentById(stokvelPayment.paymentId);
    if (mp != null) {
      return 0;
    }

    var start = DateTime.now();
    Carrier ca = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS_RECEIVED,
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

  static Future<MemberPayment> getMemberPaymentById(String paymentId) async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.MEMBER_PAYMENTS,
        query: {
          "eq": {"paymentId": paymentId}
        });
    List results = await MobMongo.query(carrier);
    List<MemberPayment> list = List();
    results.forEach((r) {
      var mm = MemberPayment.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }
  static Future<Member> getMemberById(String memberId) async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.MEMBERS,
        query: {
          "eq": {"memberId": memberId}
        });
    List results = await MobMongo.query(carrier);
    List<Member> list = List();
    results.forEach((r) {
      var mm = Member.fromJson(jsonDecode(r));
      list.add(mm);
    });
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  static Future<StokvelPayment> getStokvelPaymentById(String paymentId) async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(
        db: databaseName,
        collection: Constants.STOKVEL_PAYMENTS_RECEIVED,
        query: {
          "eq": {"paymentId": paymentId}
        });
    List results = await MobMongo.query(carrier);
    List<StokvelPayment> list = List();
    results.forEach((r) {
      var mm = StokvelPayment.fromJson(jsonDecode(r));
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
