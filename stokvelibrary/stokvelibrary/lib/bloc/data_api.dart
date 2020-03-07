import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:uuid/uuid.dart';

class DataAPI {
  static var _firestore = Firestore.instance;

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
    var querySnapshot = await _firestore
        .collection('members')
        .where('memberId', isEqualTo: member.memberId)
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.first.reference.updateData(member.toJson());
      print('💊💊💊 DataAPI: Member updated, stokvels: ${member.stokvels.length}');
    } else {
      throw Exception('Member update failed, member not found');
    }
  }

  static Future createStokvel(Stokvel stokvel) async {
    var uuid = Uuid();
    stokvel.stokvelId = uuid.v1();
    stokvel.date = DateTime.now().toUtc().toIso8601String();
    stokvel.isActive = true;
    String status = DotEnv().env['status'];

    print('💊💊💊 DataAPI: creating Stellar account for the Stokvel ...');
    var res = await Stellar.createAccount(isDevelopmentStatus: status == 'dev'? true: false );
    stokvel.accountId = res.accountResponse.accountId;
    Prefs.addStokvelCredential(StellarCredential(accountId: stokvel.accountId,
        date: DateTime.now().toUtc().toIso8601String(), seed: res.secretSeed));

    var mRes = await _firestore.collection('stokvels').add(stokvel.toJson());
    print('💊💊💊 DataAPI: Stokvel added to Firestore, path: ${mRes.path}');
    return stokvel;
  }

  static Future<StokvelPayment>  addStokvelPayment(
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
      if (member.stokvels == null) {
        member.stokvels = List();
      }
      member.stokvels.add(stokvel);
      querySnapshot.documents.first.reference.updateData(member.toJson());
      print('🛎 🛎 Member updated on Firestore with added Stokvel: 🥬 ${stokvel.name} '
          'member stokvels: 🥬 ${member.stokvels.length}');
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
}
