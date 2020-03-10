import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/file_util.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

MakerBloc makerBloc = MakerBloc();

bool isDevelopmentStatus = true;

class MakerBloc {
  Firestore fs = Firestore.instance;

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

  Future<String> writeCredential(StellarCredential cred) async {
    var res = await fs.collection('creds').add(cred.toJson());
    print('🔵 🔵 cred added to Firestore, 🍎 path ${res.path}');
    return res.path;
  }

  Future<Member> createMemberAccount(Member member) async {
    print('$em2 DataAPI: creating Stellar account for the Member  ...');
    var memberAccountResponse =
        await Stellar.createAccount(isDevelopmentStatus: isDevelopmentStatus);
    member.accountId = memberAccountResponse.accountResponse.accountId;
    print(
        '$em2 DataAPI: MEMBER accountId 0 has been set ${member.accountId}...');
    return member;
  }

  Future<StellarCredential> createStokvelAccount(Stokvel stokvel) async {
    print('$em1 DataAPI: creating Stellar account for the Stokvel ...');
    var stokvelAccountResponse =
        await Stellar.createAccount(isDevelopmentStatus: isDevelopmentStatus);
    stokvel.accountId = stokvelAccountResponse.accountResponse.accountId;
    print(
        '$em1 DataAPI: STOKVEL accountId has been set 🌎 🌎 🌎 ${stokvel.accountId} 🌎 ...');

    //todo - store this credential on Firestore - ENCRYPT seed
    var cred = StellarCredential(
        accountId: stokvel.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        seed: stokvelAccountResponse.secretSeed);

    return cred;
  }

  static const String em1 = '🔆', em2 = '🔵 🔵 🔵';
  static const chacha20 = "ChaCha20/12";
  Future createNewStokvelAndAdmin(Member member, Stokvel stokvel) async {
    member.stokvelIds.add(stokvel.stokvelId);

    var stokvelAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    stokvel.accountId = stokvelAccount.accountResponse.accountId;
    prettyPrint(
        stokvelAccount.toJson(), "📌 📌 📌 📌️ Stokvel Account 📌 📌 📌 📌️");

    var memberAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    member.accountId = memberAccount.accountResponse.accountId;
    prettyPrint(memberAccount.toJson(), '🔑 🔑 🔑 Member Account 🔑 🔑 🔑');

    print('🍏 🍏 ACCOUNTS from Stellar seem OK 🍏 🍏 🍏 🍏 🍏 🍏 ');

    Prefs.addStokvelAccountResponseBag(stokvelAccount);
    Prefs.addMemberAccountResponseBag(memberAccount);

    await FileUtil.addMember(member);
    await FileUtil.addStokvel(stokvel);
    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);
    var cred = StellarCredential(
        accountId: stokvelAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: makerBloc.encrypt(
            seed: stokvelAccount.secretSeed,
            fortunaKey: fortunaKey,
            cryptKey: cryptKey));
    await FileUtil.addCredential(cred);

    makerBloc.testCached();
    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵   🍎 Trying to write to Firestore without shitting the bed !   🍎  🔵  🔵  🔵  🔵  🔵  🔵  🔵  🔵 ');
    await writeCredential(cred);
    await writeMember(member);
    await writeStokvel(stokvel);
  }

  String encrypt({@required String seed, String fortunaKey, String cryptKey}) {
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
    print(
        '\n🍏 🍏 🍏 🍏 🍏 $chacha20 Decryption: 🔵 cryptKey: $cryptKey 🔵 encryptedSeed: $encryptedSeed:');
    var lightCrypt = LightCrypt(fortunaKey, chacha20);
    var chaDecrypted = lightCrypt.decrypt(encryptedSeed, cryptKey);
    print('$chacha20:  🍏 chaDecrypted: 🍎  $chaDecrypted 🍏');
    return chaDecrypted;
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
