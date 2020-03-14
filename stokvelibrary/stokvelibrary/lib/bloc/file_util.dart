import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class FileUtil {
  static String appDocPath;
  static String filePath;
  static const String credPath = 'credentials2c.txt',
      stokvelPath = 'stokvelss2c.txt',
      memberPath = 'members2c.txt';

  static addCredential(StokkieCredential credential) async {
    await _prepareDirPath(credPath);
    var credentials = await getCredentials();
    if (credentials == null) {
      credentials = StokkieCredentials([]);
    }
    var tempList = List<StokkieCredential>();
    credentials.credentials.forEach((s) {
      if (s.stokvelId != credential.stokvelId) {
        tempList.add(s);
      }
    });
    tempList.add(credential);
    credentials.credentials = tempList;
    var mJson = jsonEncode(credentials.toJson());
    await _writeFile(mJson);
    print(
        '🌎 StellarCredential just added to file has ${credentials.credentials.length} credentials ...');
  }

  static Future<StokkieCredential> getCredentialByStokvel(
      String stokvelId) async {
    StokkieCredentials creds = await getCredentials();
    StokkieCredential credential;
    creds.credentials.forEach((c) {
      if (stokvelId == c.stokvelId) {
        credential = c;
      }
    });
    print(
        '🌎 🌎 🌎 getCredentials: Cache file has 🍎 ${creds.credentials.length} 🍎 StellarCredentials ...');
    return credential;
  }

  static Future<StokkieCredentials> getCredentials() async {
    await _prepareDirPath(credPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 No StellarCredentials file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var creds = StokkieCredentials.fromJson(mJson);
    print(
        '🌎 🌎 🌎 getCredentials: Cache file has 🍎 ${creds.credentials.length} 🍎 StellarCredentials ...');
    return creds;
  }

  static addStokvel(Stokvel stokvel) async {
    await _prepareDirPath(stokvelPath);
    var stokvels = await getStokvels();
    if (stokvels == null) {
      stokvels = Stokvels([]);
    }
    var tempList = List<Stokvel>();
    stokvels.stokvels.forEach((s) {
      if (s.stokvelId != stokvel.stokvelId) {
        tempList.add(s);
      }
    });
    tempList.add(stokvel);
    stokvels.stokvels = tempList;
    var mJson = jsonEncode(stokvels.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addStokvel: Stokvel just added to file; now has ${stokvels.stokvels.length} stokvels ...');
  }

  static Future<Stokvel> getStokvelById(String stokvelId) async {
    Stokvels mList = await getStokvels();
    Stokvel found;
    mList.stokvels.forEach((k) {
      if ((stokvelId == k.stokvelId)) {
        found = k;
      }
    });
    return found;
  }

  static Future<Stokvels> getStokvels() async {
    await _prepareDirPath(stokvelPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 ............. No Stokvel file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var stokvels = Stokvels.fromJson(mJson);
    print(
        ' 🌎 getStokvels: Cache file has 🍎 ${stokvels.stokvels.length} Stokvels ...');
    return stokvels;
  }

  static addMember(Member member) async {
    await _prepareDirPath(memberPath);
    var members = await getMembers();
    if (members == null) {
      members = Members([]);
    }
    var tempList = List<Member>();
    members.members.forEach((s) {
      if (s.memberId != member.memberId) {
        tempList.add(s);
      }
    });
    tempList.add(member);
    members.members = tempList;
    var mJson = jsonEncode(members.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addMember: Stokvel just added to file; now has ${members.members.length} members ...');
  }

  static Future<Members> getMembers() async {
    await _prepareDirPath(memberPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 ............. No Members file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var members = Members.fromJson(mJson);
    print(
        ' 🌎 getMembers: Cache file has 🍎 ${members.members.length} Members ...');
    return members;
  }

  static addMemberPayment(MemberPayment memberPayment) async {
    await _prepareDirPath(memberPath);
    var members = await getMemberPayments();
    if (members == null) {
      members = MemberPayments([]);
    }
    members.memberPayments.add(memberPayment);
    var mJson = jsonEncode(members.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addMemberPayment: memberPayment just added to file; now has ${members.memberPayments.length} members ...');
  }

  static Future<MemberPayments> getMemberPayments() async {
    await _prepareDirPath(memberPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 ............. No MemberPayments file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var payments = MemberPayments.fromJson(mJson);
    print(
        ' 🌎 getMemberPayments: Cache file has 🍎 ${payments.memberPayments.length} MemberPayments ...');
    return payments;
  }

  static addStokvelPayment(StokvelPayment skotvelPayment) async {
    await _prepareDirPath(memberPath);
    var payments = await getStokvelPayments();
    if (payments == null) {
      payments = StokvelPayments([]);
    }
    payments.stokvelPayments.add(skotvelPayment);
    var mJson = jsonEncode(payments.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addStokvelPayment: StokvelPayment just added to file; now has ${payments.stokvelPayments.length} payments ...');
  }

  static Future<StokvelPayments> getStokvelPayments() async {
    await _prepareDirPath(memberPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 ............. No SkotvelPayments file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var payments = StokvelPayments.fromJson(mJson);
    print(
        ' 🌎 getSkotvelPayments: Cache file has 🍎 ${payments.stokvelPayments.length} StokvelPayments ...');
    return payments;
  }

  static Future _prepareDirPath(String path) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir == null) {
      throw Exception('📌 📌 📌 📌️ Unable to get app file directory');
    }
    appDocPath = appDocDir.path;
    filePath = "$appDocPath/$path";
//    print(' 🌎 ..... File path: $filePath');
    return filePath;
  }

  static Future _writeFile(String content) async {
    File file = File(filePath);
    var mFile = await file.writeAsString(content);
    var length = await mFile.length();
//    print('File ${file.path} is now 🍎 $length bytes long');
  }

  static Future<String> _readFile() async {
    File file = File(filePath);
    var exists = await file.exists();
    if (!exists) {
      return null;
    }
    return await file.readAsString();
  }
}
