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

  static addCredential(StellarCredential credential) async {
    await _prepareDirPath(credPath);
    var credentials = await getCredentials();
    if (credentials == null) {
      credentials = StellarCredentials([]);
    }
    credentials.credentials.add(credential);
    var mJson = jsonEncode(credentials.toJson());
    await _writeFile(mJson);
    print(
        '🌎 StellarCredential just added to file has ${credentials.credentials.length} credentials ...');

    //todo check file
    await getCredentials();
  }

  static Future<StellarCredentials> getCredentials() async {
    await _prepareDirPath(credPath);
    var string = await _readFile();
    if (string == null) {
      print('🔆 No StellarCredentials file found');
      return null;
    }
    var mJson = jsonDecode(string);
    var creds = StellarCredentials.fromJson(mJson);
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
    stokvels.stokvels.add(stokvel);
    var mJson = jsonEncode(stokvels.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addStokvel: Stokvel just added to file; now has ${stokvels.stokvels.length} stokvels ...');

    //todo check file
    await getStokvels();
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
    members.members.add(member);
    var mJson = jsonEncode(members.toJson());
    await _writeFile(mJson);
    print(
        '🌎 addMember: Stokvel just added to file; now has ${members.members.length} members ...');

    //todo check file
    await getMembers();
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

  static Future _prepareDirPath(String path) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir == null) {
      throw Exception('📌 📌 📌 📌️ Unable to get app file directory');
    }
    appDocPath = appDocDir.path;
    filePath = "$appDocPath/$path";
    print(' 🌎 ..... File path: $filePath');
    return filePath;
  }

  static Future _writeFile(String content) async {
    File file = File(filePath);
    var mFile = await file.writeAsString(content);
    var length = await mFile.length();
    print('File ${file.path} is now 🍎 $length bytes long');
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
