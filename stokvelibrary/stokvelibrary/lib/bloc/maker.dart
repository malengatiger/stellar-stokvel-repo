import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/data_api.dart';
import 'package:stokvelibrary/bloc/file_util.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:uuid/uuid.dart';

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
        seed: encryptedSeed);

    await FileUtil.addCredential(memberCredential);
    await Prefs.saveMember(member);
    await Prefs.saveCredential(memberCredential);
    await writeCredential(memberCredential);
    await writeMember(member);

    print('🍏 🍏 MEMBER ACCOUNT from Stellar added 🍏 🍏 🍏 🍏 🍏 🍏 ');
    return member;
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
    member.stokvelIds.add(stokvel.stokvelId);

    var stokvelAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    stokvel.accountId = stokvelAccount.accountResponse.accountId;
    prettyPrint(
        stokvelAccount.toJson(), "📌 📌 📌 📌️ Stokvel Account 📌 📌 📌 📌️");

    var memberAccount = await Stellar.createAccount(isDevelopmentStatus: true);
    member.accountId = memberAccount.accountResponse.accountId;
    var uuid = Uuid();
    member.memberId = uuid.v1();
    prettyPrint(memberAccount.toJson(), '🔑 🔑 🔑 Member Account 🔑 🔑 🔑');

    print('🍏 🍏 ACCOUNTS from Stellar seem OK 🍏 🍏 🍏 🍏 🍏 🍏 ');

    Prefs.addStokvelAccountResponseBag(stokvelAccount);
    Prefs.addMemberAccountResponseBag(memberAccount);

    var fortunaKey = CryptKey().genFortuna();
    var cryptKey = CryptKey().genDart(8);

    assert(fortunaKey != null);
    assert(cryptKey != null);

    var encrypted = encrypt(
        seed: stokvelAccount.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var stokvelCredential = StokkieCredential(
        accountId: stokvelAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: encrypted);
    await FileUtil.addCredential(stokvelCredential);

    var encrypted2 = encrypt(
        seed: stokvelAccount.secretSeed,
        fortunaKey: fortunaKey,
        cryptKey: cryptKey);

    var memberCredential = StokkieCredential(
        accountId: memberAccount.accountResponse.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        fortunaKey: fortunaKey,
        cryptKey: cryptKey,
        seed: encrypted2);

    await FileUtil.addMember(member);
    await FileUtil.addStokvel(stokvel);
    await FileUtil.addCredential(memberCredential);
    await Prefs.saveMember(member);
    await Prefs.saveCredential(memberCredential);

    print(
        '🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵  🍎 Trying to write to Firestore without shitting the bed !  🍎  🔵  🔵  🔵  🔵  🔵  🔵  🔵  🔵 ');
    await writeCredential(stokvelCredential);
    await writeMember(member);
    await writeStokvel(stokvel);
  }

  Future createNewStokvelWithExistingMember(
      Member member, Stokvel stokvel) async {
    member.stokvelIds.add(stokvel.stokvelId);

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

  Future<String> getDecryptedCredential() async {
    var cred = await Prefs.getCredential();
    if (cred != null) {
      var seed = makerBloc.decrypt(
          encryptedSeed: cred.seed,
          cryptKey: cred.cryptKey,
          fortunaKey: cred.fortunaKey);
      return seed;
    } else {
      throw Exception('No credential on file');
    }
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
