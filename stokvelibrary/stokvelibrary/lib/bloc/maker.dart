import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/data_api.dart';
import 'package:stokvelibrary/bloc/file_util.dart';
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
    print('$em2 DataAPI: MEMBER accountId has been set ${member.accountId}...');
    Prefs.addMemberAccountResponseBag(memberAccountResponse);
    await FileUtil.addMember(member);

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

    await FileUtil.addCredential(memberCredential);
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
    return member;
  }

  Future<List<Invitation>> getInvitations(String email,
      {bool updateMember = false}) async {
    var invites = await ListAPI.getInvitationsByEmail(email);
    return invites;
  }

  Future<StokkieCredential> createStokvelAccount(Stokvel stokvel) async {
    print('$em1 DataAPI: creating Stellar account for the Stokvel ...');
    var stokvelAccountResponse =
        await Stellar.createAccount(isDevelopmentStatus: isDevelopmentStatus);
    stokvel.accountId = stokvelAccountResponse.accountResponse.accountId;
    print(
        '$em1 DataAPI: STOKVEL accountId has been set 🌎 🌎 🌎 ${stokvel.accountId} 🌎 ...');

    //todo - store this credential on Firestore - ENCRYPT seed
    var cred = StokkieCredential(
        accountId: stokvel.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        seed: stokvelAccountResponse.secretSeed);

    return cred;
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

    await _saveData(member, stokvel, memberCredential, stokvelCredential);
  }

  Future _saveData(
      Member member,
      Stokvel stokvel,
      StokkieCredential memberCredential,
      StokkieCredential stokvelCredential) async {
    await FileUtil.addMember(member);
    await FileUtil.addStokvel(stokvel);
    await FileUtil.addCredential(memberCredential);
    await FileUtil.addCredential(stokvelCredential);
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

    Prefs.addStokvelAccountResponseBag(stokvelAccount);

    await FileUtil.addStokvel(stokvel);
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
        seed: ee);
    await FileUtil.addCredential(stokvelCredential);

    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵   🍎 Trying to write to Firestore without shitting the bed !   🍎  🔵  🔵  🔵  🔵  🔵  🔵  🔵  🔵 ');
    await writeCredential(stokvelCredential);
    await writeStokvel(stokvel);
    await DataAPI.updateMember(member);
    await Prefs.saveMember(member);
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
    print(
        '\n🍏 🍏 🍏 🍏 🍏 $chacha20 Decryption: 🔵 cryptKey: $cryptKey 🔵 encryptedSeed: $encryptedSeed:');
    var lightCrypt = LightCrypt(fortunaKey, chacha20);
    var chaDecrypted = lightCrypt.decrypt(encryptedSeed, cryptKey);
    print('$chacha20:  🍏 chaDecrypted: 🍎  $chaDecrypted 🍏');
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

  void testCached() async {
    print('\n\n\n');
//    var stok2 = await Prefs.getStokvelAccountResponseBag();
//    prettyPrint(stok2.toJson(),
//        '🍏 🍏 STOKVEL account from disk cache 🔵 🔵 🔵 🔵 🔵 🔵 ');
//
//    var mem = await Prefs.getMemberAccountResponseBag();
//    prettyPrint(mem.toJson(),
//        '🍏 🍏 MEMBER account from disk cache 🔵 🔵 🔵 🔵 🔵 🔵 ');
//
//    var stokkies = await FileUtil.getStokvels();
//    stokkies.stokvels.forEach((s) {
//      prettyPrint(s.toJson(), '🔵 🔵 🔵 🔵 STOKVEL 🔵 🔵 🔵 🔵');
//    });
//    print(
//        '🔵 🔵 ${stokkies.stokvels.length} stokvels in the cache file  🔵 🔵 🔵 🔵 ');
//
    var mems = await FileUtil.getMembers();
    mems.members.forEach((s) {
      prettyPrint(s.toJson(), '🤟🏽 🤟🏽 🤟🏽  MEMBER 🤟🏽 🤟🏽 🤟🏽 ');
    });
    print(
        '🤟🏽 🤟🏽 🤟🏽 🤟🏽 🤟🏽 🤟🏽  ${mems.members.length} members in the cache file 🍏 🍏 🍏 🍏 ');
    var creds = await FileUtil.getCredentials();
    creds.credentials.forEach((s) {
      prettyPrint(s.toJson(), '🍎 🍎 🍎 🍎 STOKVEL CREDS 🍎 🍎 🍎 🍎 ');
      try {
        decrypt(
            encryptedSeed: s.seed,
            cryptKey: s.cryptKey,
            fortunaKey: s.fortunaKey);
      } catch (e) {
        print(e);
      }
    });
    print(
        '🍎 🍎 ${creds.credentials.length} creds in the cache file 🍎 🍎 🍎 🍎  ');
  }
}
