import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class ListAPI {
  static var _firestore = Firestore.instance;

  static Future<List<Stokvel>> getStokvelsAdministered(String memberId) async {
    var querySnapshot = await _firestore.collection('stokvels').where('adminMember.memberId',isEqualTo: memberId).getDocuments();
    var mList = List<Stokvel>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Stokvel.fromJson(doc.data));
    });
    return mList;
  }

  static Future<List<Member>> getStokvelMembers(String stokvelId) async {
    var querySnapshot = await _firestore.collection('members').where('stokvels',
        arrayContains: {'stokvelId': stokvelId}).getDocuments();
    var mList = List<Member>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Member.fromJson(doc.data));
    });
    return mList;
  }

  static Future<List<StokvelPayment>> getStokvelPayments(String stokvelId) async {
    var querySnapshot = await _firestore.collection('stokvelPayments').where('stokvelId',
        isEqualTo: stokvelId).limit(200).getDocuments();
    var mList = List<StokvelPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokvelPayment.fromJson(doc.data));
    });
    return mList;
  }
  static Future<List<StokvelPayment>> getMemberPayments(String memberId) async {
    var querySnapshot = await _firestore.collection('memberPayments')
        .orderBy('date',descending: true).where('memberId',
        isEqualTo: memberId).limit(200).getDocuments();
    var mList = List<StokvelPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokvelPayment.fromJson(doc.data));
    });
    return mList;
  }


}
