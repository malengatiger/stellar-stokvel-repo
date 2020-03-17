import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/data_api.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:uuid/uuid.dart';

MakerBloc makerBloc = MakerBloc();

bool isDevelopmentStatus = true;

class MakerBloc {
  Firestore fs = Firestore.instance;
  FirebaseMessaging auth = FirebaseMessaging();

  MakerBloc() {
    _getStatus();
  }

  void _getStatus() async {
    await DotEnv().load('.env');
    String status = DotEnv().env['status'];
    if (status == 'dev') {
      isDevelopmentStatus = true;
    } else {
      isDevelopmentStatus = false;
    }
    print(
        ' 🌎 🌎 🌎 Status of the app is ${isDevelopmentStatus ? 'DEVELOPMENT' : 'PRODUCTION'}  🌎 🌎 🌎');
  }

  Future writeAccountResponse(AccountResponseBag bag) async {
    var res = await fs.collection('accounts').add(bag.toJson());
    print('🔵 🔵 account added to Firestore, 🍎 path ${res.path}');
    return res;
  }

  Future<String> writeStokvel(Stokvel bag) async {
    var res = await fs.collection('stokvels').add(bag.toJson());
    print('🔵 🔵 stokvel added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<String> writeMember(Member bag) async {
    var res = await fs.collection('members').add(bag.toJson());
    print('🔵 🔵 member added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<String> writeStokvelPayment(StokvelPayment payment) async {
    var res = await fs.collection('stokvelPayments').add(payment.toJson());
    print('🔵 🔵 StokvelPayment added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<String> writeMemberPayment(MemberPayment payment) async {
    var res = await fs.collection('memberPayments').add(payment.toJson());
    print('🔵 🔵 MemberPayment added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<String> writeCredential(StokkieCredential cred) async {
    var res = await fs.collection('creds').add(cred.toJson());
    print('🔵 🔵 cred added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<Member> createMemberAccount(Member member) async {
    print('$em2 DataAPI: creating Stellar account for the Member  ...');
    var memberAccountResponse =
        await Stellar.createAccount(isDevelopmentStatus: isDevelopmentStatus);
    member.accountId = memberAccountResponse.accountResponse.accountId;
    var uuid = Uuid();
    member.memberId = uuid.v1();
    var token = await auth.getToken();
    member.fcmToken = token;

    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);
    assert(fortunaKey != null);
    assert(cryptKey != null);

    var encryptedSeed = encrypt(
        seed: memberAccountResponse.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var memberCredential = StokkieCredential(
        accountId: memberAccountResponse.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: encryptedSeed,
        stokvelId: null,
        memberId: member.memberId);

    await _saveMemberData(memberCredential, member, memberAccountResponse);
    return member;
  }

  Future _saveMemberData(StokkieCredential memberCredential, Member member,
      AccountResponseBag memberAccountResponse) async {
    await LocalDB.addCredential(credential: memberCredential);
    await LocalDB.addMember(member: member);
    await LocalDB.addMemberAccountResponse(
        accountResponse: memberAccountResponse.accountResponse);
    Prefs.addMemberAccountResponseBag(memberAccountResponse);
    await Prefs.saveCredential(memberCredential);
    await writeCredential(memberCredential);
    var invites = await getInvitations(member.email);
    invites.forEach((i) {
      member.stokvelIds.add(i.stokvel.stokvelId);
      print(
          '🍏 🍏 MEMBER ACCOUNT: added stokvel to account: ${i.stokvel.name}');
    });
    await writeMember(member);
    await Prefs.saveMember(member);
    print('🍏 🍏 MEMBER ACCOUNT from Stellar added. 🍏 🍏 🍏 Yebo! 🍏 🍏 🍏 ');
  }

  Future<List<Invitation>> getInvitations(String email,
      {bool updateMember = false}) async {
    var invites = await ListAPI.getInvitationsByEmail(email);
    return invites;
  }

  Future<int> createStokvelAccount(Stokvel stokvel) async {
    print('$em1 DataAPI: creating Stellar account for the Stokvel ...');
    var stokvelAccountResponse =
        await Stellar.createAccount(isDevelopmentStatus: isDevelopmentStatus);
    stokvel.accountId = stokvelAccountResponse.accountResponse.accountId;
    print(
        '$em1 DataAPI: STOKVEL accountId has been set 🌎 🌎 🌎 ${stokvel.accountId} 🌎 ...');

    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);
    assert(fortunaKey != null);
    assert(cryptKey != null);

    var encryptedStokkieSeed = encrypt(
        seed: stokvelAccountResponse.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var stokvelCredential = StokkieCredential(
        accountId: stokvelAccountResponse.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: encryptedStokkieSeed,
        stokvelId: stokvel.stokvelId,
        memberId: null);

    await LocalDB.addStokvel(stokvel: stokvel);
    await LocalDB.addCredential(credential: stokvelCredential);
    await LocalDB.addStokvelAccountResponse(
        accountResponse: stokvelAccountResponse.accountResponse);
    await writeStokvel(stokvel);
    await writeCredential(stokvelCredential);
    return 0;
  }

  static const String em1 = '🔆', em2 = '🔵 🔵 🔵';
  static const chacha20 = "ChaCha20/12";
  Future createNewStokvelAndAdmin(Member member, Stokvel stokvel) async {
    var stokvelAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    stokvel.accountId = stokvelAccount.accountResponse.accountId;
    prettyPrint(
        stokvelAccount.toJson(), "📌 📌 📌 📌️ Stokvel Account 📌 📌 📌 📌️");

    var memberAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    member.accountId = memberAccount.accountResponse.accountId;
    member.stokvelIds.add(stokvel.stokvelId);
    stokvel.adminMember = member;

    var token = await auth.getToken();
    member.fcmToken = token;
    prettyPrint(memberAccount.toJson(),
        '🔑 🔑 🔑 Member Account from Stellar 🔑 🔑 🔑');
    print('🍏 🍏 ACCOUNTS from Stellar seem OK 🍏 🍏 🍏 🍏 🍏 🍏 ');
    print(
        '🍏 🍏 compare seeds: stokvelAccount: ${stokvelAccount.secretSeed}  🔴  memberAccount: ${memberAccount.secretSeed} 🍏 🍏 🍏 🍏 🍏 🍏 ');

    Prefs.addStokvelAccountResponseBag(stokvelAccount);
    Prefs.addMemberAccountResponseBag(memberAccount);

    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);
    assert(fortunaKey != null);
    assert(cryptKey != null);

    var encryptedStokkieSeed = encrypt(
        seed: stokvelAccount.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var stokvelCredential = StokkieCredential(
        accountId: stokvelAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: encryptedStokkieSeed,
        stokvelId: stokvel.stokvelId,
        memberId: null);
    //
    var fortunaKey2 = CryptKey().genFortuna();
    var cryptKey2 = CryptKey().genDart(8);
    var encryptedMemberSeed = encrypt(
        seed: memberAccount.secretSeed,
        fortunaKey: fortunaKey2,
        cryptKey: cryptKey2);

    var memberCredential = StokkieCredential(
        accountId: memberAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey2,
        cryptKey: cryptKey2,
        seed: encryptedMemberSeed,
        stokvelId: null,
        memberId: member.memberId);

    await _saveStokvelAndMemberData(
        member, stokvel, memberCredential, stokvelCredential, stokvelAccount);
  }

  Future _saveStokvelAndMemberData(
      Member member,
      Stokvel stokvel,
      StokkieCredential memberCredential,
      StokkieCredential stokvelCredential,
      AccountResponseBag bag) async {
    await LocalDB.addMember(member: member);
    await LocalDB.addStokvel(stokvel: stokvel);
    await LocalDB.addCredential(credential: memberCredential);
    await LocalDB.addCredential(credential: stokvelCredential);
    await LocalDB.addStokvelAccountResponse(
        accountResponse: bag.accountResponse);
    prettyPrint(member.toJson(),
        '🌽 🌽 🌽 Member about to be cached in Prefs ...🌽 🌽 🌽 check for stokvelIds ...');
    await Prefs.saveMember(member);
    await Prefs.saveCredential(memberCredential);

    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵  🍎 Trying to write to Firestore without shitting the bed !  🍎  🔵  🔵  🔵  🔵  🔵  🔵  🔵  🔵 ');
    await writeCredential(stokvelCredential);
    await writeCredential(memberCredential);
    await writeMember(member);
    await writeStokvel(stokvel);
  }

  Future createNewStokvelWithExistingMember(
      Member member, Stokvel stokvel) async {
    member.stokvelIds.add(stokvel.stokvelId);
    var token = await auth.getToken();
    member.fcmToken = token;

    var stokvelAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    stokvel.accountId = stokvelAccount.accountResponse.accountId;
    prettyPrint(
        stokvelAccount.toJson(), "📌 📌 📌 📌️ Stokvel Account 📌 📌 📌 📌️");

    print('🍏 🍏 STOKVEL ACCOUNT from Stellar seems OK 🍏 🍏 🍏 🍏 🍏 🍏 ');

    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);
    assert(fortunaKey != null);
    assert(cryptKey != null);

    var ee = encrypt(
        seed: stokvelAccount.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var stokvelCredential = StokkieCredential(
        accountId: stokvelAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        stokvelId: stokvel.stokvelId,
        memberId: null,
        seed: ee);

    await _saveStokvelData(stokvelCredential, stokvel, stokvelAccount, member);
  }

  Future _saveStokvelData(StokkieCredential stokvelCredential, Stokvel stokvel,
      AccountResponseBag bag, Member member) async {
    await LocalDB.addCredential(credential: stokvelCredential);
    await LocalDB.addStokvel(stokvel: stokvel);
    await LocalDB.addStokvelAccountResponse(
        accountResponse: bag.accountResponse);
    await LocalDB.addMember(member: member);
    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵   🍎 Trying to write to Firestore without shitting the bed !   🍎  🔵  🔵  🔵  🔵  🔵  🔵  🔵  🔵 ');
    await writeCredential(stokvelCredential);
    await writeStokvel(stokvel);
    await DataAPI.updateMember(member);
    await Prefs.saveMember(member);
    Prefs.addStokvelAccountResponseBag(bag);
  }

  String encrypt({@required String seed, String fortunaKey, String cryptKey}) {
    assert(seed != null);
    assert(fortunaKey != null);
    assert(cryptKey != null);
    print(
        '\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 $chacha20 Encryption: 🔵 🔵 seed: $seed: fortunaKey: $fortunaKey 🔵 🔵  cryptKey: $cryptKey');
    var lightCrypt = LightCrypt(fortunaKey, chacha20);
    var chaEncrypted = lightCrypt.encrypt(seed, cryptKey);
    print(
        '$chacha20: 🔵 cryptKey: $cryptKey 🔵 encryptedSeed: 🍎  $chaEncrypted 🍎 ');
    decrypt(
        encryptedSeed: chaEncrypted,
        cryptKey: cryptKey,
        fortunaKey: fortunaKey);
    return chaEncrypted;
  }

  String decrypt({String encryptedSeed, String cryptKey, String fortunaKey}) {
    assert(encryptedSeed != null);
    assert(fortunaKey != null);
    assert(cryptKey != null);

    var lightCrypt = LightCrypt(fortunaKey, chacha20);
    var chaDecrypted = lightCrypt.decrypt(encryptedSeed, cryptKey);
    return chaDecrypted;
  }

  Future<String> getDecryptedSeedFromCache() async {
    var cred = await Prefs.getCredential();
    if (cred != null) {
      prettyPrint(cred.toJson(),
          'getDecryptedSeedFromCache: .............. CRED retrieved from cache');
      var seed = decrypt(
          encryptedSeed: cred.seed,
          cryptKey: cred.cryptKey,
          fortunaKey: cred.fortunaKey);
      print(
          'decrypted seed from cache, this should be the member seed: 🍎 $seed 🍎 ');
      return seed;
    } else {
      throw Exception('No credential on file');
    }
  }

  String getDecryptedSeed(StokkieCredential cred) {
    assert(cred != null);
    var seed = decrypt(
        encryptedSeed: cred.seed,
        cryptKey: cred.cryptKey,
        fortunaKey: cred.fortunaKey);

    return seed;
  }
}
