import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _firestore = Firestore.instance;

  static Future checkAuth() async {
    if (_auth.currentUser() != null) {
      return true;
    }
    return false;
  }

  static Future<Member> createMember(Member member) async {
    await DotEnv().load('.env');
    String email = DotEnv().env['email'];
    String password = DotEnv().env['password'];
    String status = DotEnv().env['status'];
    print('🔷🔷🔷🔷 $email used for original auth bootup.');
    var authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (authResult.user != null) {
      var res = await _auth.createUserWithEmailAndPassword(
          email: member.email, password: 'needsChangingToday');
      if (res.user != null) {
        member.memberId = res.user.uid;
        await _auth.signOut();
        await _auth.signInWithEmailAndPassword(email: member.email, password: 'needsChangingToday');
        
        print('🔷🔷🔷🔷 Creating Stellar account for the Member ...');
        var mRes = await Stellar.createAccount(isDevelopmentStatus: status == "dev"? true: false );
        member.accountId = mRes.accountResponse.accountId;
        Prefs.setMemberSeed(mRes.secretSeed);
        
        print('🔷🔷🔷🔷 Caching Member to Firestore ...');
        await _firestore.collection('members').add(member.toJson());
        await Prefs.saveMember(member);
        return member;
      } else {
        throw Exception('Member create failed');
      }
    } else {
      throw Exception('Firebase Admin user not found');
    }
    return null;
  }
  
}
