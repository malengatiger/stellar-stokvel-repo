//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at https://mozilla.org/MPL/2.0/.

// © 2019 Aditya Kishore

import 'package:steel_crypt/steel_crypt.dart';

var rsaCrypt = RsaCrypt();
const chacha20 = "ChaCha20/12";

void main() {
  var fortunaKey = CryptKey().genFortuna();
  print('fortunaKey Fortuna: $fortunaKey');

  LightCrypt lightCrypt = LightCrypt(fortunaKey, chacha20);
  String cryptKey = CryptKey().genDart(8);
  String chaEncrypted = lightCrypt.encrypt(
      'SDLR6UOEU4GLUQG4BC5GWABMDFUHTZXVVLE2QV4RE256FCUA5Q7VTQGJ', cryptKey);
  print('$chacha20: cryptKey: $cryptKey encryptedSeed: 🍎  $chaEncrypted 🍎 ');

  //decrypt here
  var chaDecrypted = lightCrypt.decrypt(chaEncrypted, cryptKey);
  print('$chacha20: 🍏 chaDecrypted: 🍎  $chaDecrypted 🍏');

//  var seed = 'SDLR6UOEU4GLUQG4BC5GWABMDFUHTZXVVLE2QV4RE256FCUA5Q7VTQGJ';
//  print('\n🔵 🔵 🔵 🔵 RSA Asymmetric Encryption 🔵 🔵 🔵 🔵 seed: $seed\n');
//
//  var encryptedSeed = rsaCrypt.encrypt(
//      'SDLR6UOEU4GLUQG4BC5GWABMDFUHTZXVVLE2QV4RE256FCUA5Q7VTQGJ',
//      rsaCrypt.randPubKey); //encrypt
//  print('RSA Asymmetric: encryptedSeed: 🍎  $encryptedSeed');
//
//  var decrypted = rsaCrypt.decrypt(encryptedSeed, rsaCrypt.randPrivKey);
//  print('\n🍎 RSA Asymmetric: decryptedSeed: 🍎  $decrypted  🍎 '); //decrypt
//
//  print(
//      '\n-------------------------- 🔵 END 🔵  -------------------------------------------');
//  var enc =
//      _encrypt('SDLR6UOEU4GLUQG4BC5GWABMDFUHTZXVVLE2QV4RE256FCUA5Q7VTQGJ');
//  _decrypt(enc);
}

String _encrypt(String seed) {
  print(
      '\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 RSA Asymmetric encryption 🔵 🔵 seed: $seed:');
  var key = rsaCrypt.randPubKey;
  var encryptedSeed = rsaCrypt.encrypt(seed, key); //encrypt
  print('RSA Asymmetric: encryptedSeed: 🍎  $encryptedSeed ');
  return encryptedSeed;
}

String _decrypt(String encryptedSeed) {
  print(
      '\n🍏 🍏 🍏 🍏 🍏 🔵 🔵 RSA Asymmetric Decryption 🔵 🔵 encryptedSeed: $encryptedSeed:');
  var decrypted = rsaCrypt.decrypt(encryptedSeed, rsaCrypt.randPrivKey);
  print(
      '🍏 🍏 🍏 RSA Asymmetric: decryptedSeed: 🍎  $decrypted  🍎 '); //decrypt
  return decrypted;
}
