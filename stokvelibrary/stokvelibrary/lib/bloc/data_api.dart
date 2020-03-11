import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/LocalDBAPI.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:uuid/uuid.dart';

class DataAPI {
  static var _firestore = Firestore.instance;

  static Future sendInvitation(Invitation invitation) async {
    await _firestore.collection('invitations').add(invitation.toJson());
    print(
        'Invitation for ${invitation.stokvel.name} has been added to Firestore - will launch cloud function ...');
  }

  static Future uploadMemberPhoto({File file, Member member}) async {
    final StorageReference storageReference =
        FirebaseStorage().ref().child('photos');

    final StorageUploadTask uploadTask = storageReference.putFile(file);

    final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
      print(
          'Bytes transferred: ${event.snapshot.bytesTransferred} of ${event.snapshot.totalByteCount}');
      print('StorageUploadTask EVENT: ${event.type}');
    });

    var snapshot = await uploadTask.onComplete;
    streamSubscription.cancel();
    if (uploadTask.isSuccessful) {
      member.url = await snapshot.ref.getDownloadURL();
      updateMember(member);
    } else {
      throw Exception('Photo upload failed');
    }
  }

  static Future updateMember(Member member) async {
    print(
        '🧡 🧡 DataAPI: ... about to query member ${member.name} - id: ${member.memberId}');
    prettyPrint(member.toJson(),
        '🥬 🥬 🥬 Member about to be deleted and added again ...');

    DocumentReference documentReference;
    var querySnapshot = await _firestore
        .collection('members')
        .where('memberId', isEqualTo: member.memberId)
        .limit(1)
        .getDocuments();

    print(
        '🧡 🧡 DataAPI: ... about to update  member, querySnapshot has ... 🍎 ${querySnapshot.documents.length} record');

    if (querySnapshot.documents.length > 0) {
      documentReference = querySnapshot.documents.first.reference;
    } else {
      throw Exception('Member update failed, member not found');
    }
    if (documentReference != null) {
      _firestore.runTransaction((Transaction tx) async {
        var snap = await tx.get(documentReference);
        if (snap.exists) {
          await tx.update(documentReference, member.toJson());
          print('🧡 🧡 DataAPI: ... member updated: ... 🍎 ');
        }
      });
    } else {
      throw Exception('Mmeber to be updated NOT found');
    }
  }

  /// create Stokvel account on Stellar add to Firestore
  static Future createStokvelExistingAdmin(
      {Stokvel stokvel, Member member}) async {
    var uuid = Uuid();
    stokvel.stokvelId = uuid.v1();
    stokvel.date = DateTime.now().toUtc().toIso8601String();
    stokvel.isActive = true;
    member.stokvelIds.add(stokvel.stokvelId);
    stokvel.adminMember = member;

    _firestore.runTransaction((Transaction tx) async {
      var mRes = await _firestore.collection('stokvels').add(stokvel.toJson());
      print('🧡 🧡 DataAPI: ... stokvel added: ... 🍎  path: ${mRes.path}');
      var qs = await _firestore
          .collection('members')
          .where('memberId', isEqualTo: member.memberId)
          .limit(1)
          .getDocuments();
      DocumentReference documentReference;
      qs.documents.forEach((doc) {
        documentReference = doc.reference;
      });
      if (documentReference == null) {
        throw Exception('DocumentRef not found');
      }
      var snap = await tx.get(documentReference);
      if (snap.exists) {
        await tx.update(documentReference, member.toJson());
        print(
            '🧡 🧡 DataAPI: ... member updated: ... 🍎  stokvels: ${member.stokvelIds.length} 🍎 ids: ${member.stokvelIds.length}');
      }
    });
  }

  /// create Stokvel, Admin member accounts on Stellar and add to Firestore
  static Future createStokvelNewAdmin({Stokvel stokvel, Member member}) async {
    print('💊💊💊 DataAPI: setting up records before write...');
    var uuid = Uuid();
    stokvel.stokvelId = uuid.v1();
    member.memberId = uuid.v1();
    stokvel.date = DateTime.now().toUtc().toIso8601String();
    member.date = stokvel.date;
    member.isActive = true;
    stokvel.isActive = true;
    member.stokvelIds = [];
    member.stokvelIds.add(stokvel.stokvelId);
    stokvel.adminMember = member;

    String status = DotEnv().env['status'];

    StokkieCredential cred = await _doStokvel(status, stokvel);

    await _doMember(status, member);

    print(
        '💊💊💊 DataAPI: Stokvel creation BATCH completed; returning stokvel');
    return stokvel;
  }

  static Future _writeBatch(
      Stokvel stokvel, Member member, StokkieCredential cred) async {
    print('💊💊💊 DataAPI: creating Firestore batch write ...');
    try {
      _firestore = Firestore.instance;
      var mBatch = _firestore.batch();
      _firestore.collection('stokvels').add(stokvel.toJson());
      _firestore.collection('members').add(member.toJson());
      _firestore.collection('creds').add(cred.toJson());
      await mBatch.commit();
    } catch (e) {
      print(e);
      print('We fucked, Bro! 🔆 🔆 🔆 truly fucked!');
    }
  }

  static Future _doMember(String status, Member member) async {
    print('💊💊💊 DataAPI: creating Stellar account for the Member  ...');
    var memberAccountResponse = await Stellar.createAccount(
        isDevelopmentStatus: status == 'dev' ? true : false);
    member.accountId = memberAccountResponse.accountResponse.accountId;
    print(
        '💊💊💊 DataAPI: MEMBER accountId 0 has been set ${member.accountId}...');

//    var memberAccountResponse1 = await Stellar.createAccount(
//        isDevelopmentStatus: status == 'dev' ? true : false);
//    member.accountId = memberAccountResponse1.accountResponse.accountId;
//    print('💊💊💊 DataAPI: MEMBER accountId 1 has been set ${member.accountId}...');
//
//    var memberAccountResponse2 = await Stellar.createAccount(
//        isDevelopmentStatus: status == 'dev' ? true : false);
//    member.accountId = memberAccountResponse2.accountResponse.accountId;
//    print('💊💊💊 DataAPI: MEMBER accountId 2 has been set ${member.accountId}...');

    await LocalDBAPI.addMember(member: member);
    print('💊💊💊 DataAPI: 🌎 Member cached on device DATABASE... 🌎');
    await Prefs.saveMember(member);
    print('💊💊💊 DataAPI: 🌎 Member cached on device prefs... 🌎');
    return member;
  }

  static Future<StokkieCredential> _doStokvel(
      String status, Stokvel stokvel) async {
    print('💊💊💊 DataAPI: creating Stellar account for the Stokvel ...');
    var stokvelAccountResponse = await Stellar.createAccount(
        isDevelopmentStatus: status == 'dev' ? true : false);
    stokvel.accountId = stokvelAccountResponse.accountResponse.accountId;
    print(
        '💊💊💊 DataAPI: STOKVEL accountId has been set 🌎 🌎 🌎 ${stokvel.accountId} 🌎 ...');

    //todo - store this credential on Firestore - ENCRYPT seed
    var cred = StokkieCredential(
        accountId: stokvel.accountId,
        date: DateTime.now().toUtc().toIso8601String(),
        seed: stokvelAccountResponse.secretSeed);

    await LocalDBAPI.addCredential(credential: cred);
    print('💊💊💊 DataAPI: 🌎 Stokvel credentials cached on device DB... 🌎');
    return cred;
  }

  static Future<StokvelPayment> addStokvelPayment(
      {@required StokvelPayment payment, @required String seed}) async {
    var res = await Stellar.sendPayment(
        seed: seed,
        destinationAccount: payment.stokvel.accountId,
        amount: payment.amount,
        memo: 'STOKVEL');
    print('Stokvel payment successful on Stellar. Will cache on Firestore');
    payment.stellarHash = res.hash;
    var ref =
        await _firestore.collection('stokvelPayments').add(payment.toJson());
    print('${ref.path} - payment added to Firestore after Stellar transaction');
    return payment;
  }

  static Future addMemberPayment(
      {@required MemberPayment payment, @required String seed}) async {
    var res = await Stellar.sendPayment(
        seed: seed,
        destinationAccount: payment.toMember.accountId,
        amount: payment.amount,
        memo: 'MEMBER');
    print('Member payment successful on Stellar. Will cache on Firestore');
    payment.stellarHash = res.hash;
    var ref =
        await _firestore.collection('memberPayments').add(payment.toJson());
    print('${ref.path} - payment added to Firestore after Stellar transaction');
    return ref;
  }

  static Future addStokvelToMember(
      {@required Stokvel stokvel, @required String memberId}) async {
    var querySnapshot = await _firestore
        .collection('members')
        .where('memberId', isEqualTo: memberId)
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      var member = Member.fromJson(querySnapshot.documents.first.data);
      if (member.stokvelIds == null) {
        member.stokvelIds = List();
      }
      member.stokvelIds.add(stokvel.stokvelId);
      querySnapshot.documents.first.reference.updateData(member.toJson());
      print(
          '🛎 🛎 Member updated on Firestore with added Stokvel: 🥬 ${stokvel.name} '
          'member stokvels: 🥬 ${member.stokvelIds.length}');
      await Prefs.saveMember(member);
      return null;
    } else {
      throw Exception('Member not found');
    }
  }

  static Future addStokvelAdministrator(
      {@required Member member, @required String stokvelId}) async {
    var querySnapshot = await _firestore
        .collection('stokvels')
        .where('stokvelId', isEqualTo: stokvelId)
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      var stokvel = Stokvel.fromJson(querySnapshot.documents.first.data);
      stokvel.adminMember = member;
      stokvel.date = DateTime.now().toUtc().toIso8601String();
      querySnapshot.documents.first.reference.updateData(stokvel.toJson());
    } else {
      throw Exception('Member not found');
    }
  }

  static Future addInvitation(Invitation invite) async {
    var uuid = Uuid();
    invite.invitationId = uuid.v1();
    invite.date = DateTime.now().toUtc().toIso8601String();
    var mRes = await _firestore.collection('invitations').add(invite.toJson());
    print('💊💊💊 DataAPI: Invitation added to Firestore, path: ${mRes.path}');
    return invite;
  }
}
