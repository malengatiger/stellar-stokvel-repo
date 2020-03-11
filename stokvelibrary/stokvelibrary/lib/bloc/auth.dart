import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:uuid/uuid.dart';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore fs = Firestore.instance;

  static Future<bool> checkAuth() async {
    var user = await _auth.currentUser();
    if (user != null) {
      print(('🔶 🔶 🔶 User is already authenticated: ${user.displayName}'));
      return true;
    } else {
      print(('🔑 🔑 🔑 🅿️ User is not authenticated yet 🅿️ '));
      return false;
    }
  }

  static Future<bool> signInAnon() async {
    var user = await _auth.signInAnonymously();
    if (user != null) {
      print(('🔶 🔶 🔶 User signed In Anonymously: ${user.toString()}'));
      return true;
    } else {
      print(('🔑 🔑 🔑 🅿️ User is not authenticated yet 🅿️ '));
      return false;
    }
  }

  //todo - CACHE encrypted seed and store in Firestore - in case user loses phone
  static Future<Member> createMember(
      {Member member, String memberPassword}) async {
    print('🔷🔷🔷🔷 Auth: createMember starting ..... ');
    await DotEnv().load('.env');
    String email = DotEnv().env['email'];
    String password = DotEnv().env['password'];
    String status = DotEnv().env['status'];
    print(
        '🔷🔷🔷🔷 Auth: $email - to be used for original auth bootup..... $password');
    var authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    print(
        '🔷🔷🔷🔷 Auth: signInWithEmailAndPassword for superAdmin to start shit up!..... name: ${authResult.user.email}');
    if (authResult.user != null) {
      var res = await _auth.createUserWithEmailAndPassword(
          email: member.email, password: memberPassword);
      if (res.user != null) {
        print(
            '🔷🔷🔷🔷 User has been created on Firebase auth: ${res.user.email}');
        member.memberId = res.user.uid;
        await _auth.signOut();
        await _auth.signInWithEmailAndPassword(
            email: member.email, password: memberPassword);
        var mm = await makerBloc.createMemberAccount(member);
        return mm;
      } else {
        throw Exception('Member create failed');
      }
    } else {
      throw Exception('Firebase Admin user not found');
    }
  }

  static Future<Member> _createStellarAccount(
      String status, Member member) async {
    print(
        '🔷🔷🔷🔷 ....... Creating Stellar account for the Member: ${member.name}...');
    var mm = await makerBloc.createMemberAccount(member);
    return mm;
  }

  static final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  static Future<Member> startGoogleSignUp() async {
    print('$emoji ........... Starting startGoogleSignUp ... 🔵 ...........');
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    print('Auth: $emoji GoogleSignInAuthentication done, name: 🍏 '
        '${googleSignInAccount.displayName} - ${googleSignInAccount.email}');

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    print('Auth: $emoji credential obtained: 🍏 ${credential.providerId}');
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    print(
        'Auth: authResult obtained: 🍏 ${authResult.user.displayName} - ${authResult.user.email}');
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print('$emoji Google SignIn returned with the following: 🔵 ');
    print(user);
    var uuid = Uuid();
    var member = Member(
        memberId: uuid.v4(),
        email: user.email,
        name: user.displayName,
        isActive: true,
        date: DateTime.now().toUtc().toIso8601String(),
        url: user.photoUrl);
    await DotEnv().load('.env');
    String status = DotEnv().env['status'];
    return await _createStellarAccount(status, member);
  }

  static const emoji = '🔵 🔵 🔵 ';
}
