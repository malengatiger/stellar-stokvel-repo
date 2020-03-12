import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stokvelibrary/bloc/file_util.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class ListAPI {
  static var _firestore = Firestore.instance;

  static Future<List<Stokvel>> getStokvelsAdministered(String memberId) async {
    var querySnapshot = await _firestore
        .collection('stokvels')
        .where('adminMember.memberId', isEqualTo: memberId)
        .getDocuments();
    var mList = List<Stokvel>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Stokvel.fromJson(doc.data));
    });
    return mList;
  }

  static Future<Stokvel> getStokvelById(String stokvelId) async {
    var querySnapshot = await _firestore
        .collection('stokvels')
        .where('stokvelId', isEqualTo: stokvelId)
        .getDocuments();
    var mList = List<Stokvel>();
    var stokvel;
    ;
    querySnapshot.documents.forEach((doc) {
      mList.add(Stokvel.fromJson(doc.data));
    });
    mList.forEach((s) {
      if (s.stokvelId == stokvelId) {
        stokvel = s;
      }
    });
    if (stokvel != null) {
      await FileUtil.addStokvel(stokvel);
    }
    return stokvel;
  }

  static Future<List<Invitation>> getInvitationsByEmail(String email) async {
    var querySnapshot = await _firestore
        .collection('invitations')
        .where('email', isEqualTo: email)
        .getDocuments();
    var mList = List<Invitation>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Invitation.fromJson(doc.data));
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
    print(
        '🔵 🔵 ListAPI: getStokvelMembers found 🔵 ${mList.length} 🔵 members');
    return mList;
  }

  static Future<List<StokvelPayment>> getStokvelPayments(
      String stokvelId) async {
    var querySnapshot = await _firestore
        .collection('stokvelPayments')
        .where('stokvelId', isEqualTo: stokvelId)
        .limit(200)
        .getDocuments();
    var mList = List<StokvelPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokvelPayment.fromJson(doc.data));
    });
    return mList;
  }

  static Future<List<StokvelPayment>> getMemberPayments(String memberId) async {
    var querySnapshot = await _firestore
        .collection('memberPayments')
        .orderBy('date', descending: true)
        .where('memberId', isEqualTo: memberId)
        .limit(200)
        .getDocuments();
    var mList = List<StokvelPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokvelPayment.fromJson(doc.data));
    });
    return mList;
  }

  static Future<Member> getMember(String memberId) async {
    print('ListAPI: 💜 💜 getMember: $memberId');
    var querySnapshot = await _firestore
        .collection('members')
        .where('memberId', isEqualTo: memberId)
        .limit(1)
        .getDocuments();

    print(
        'ListAPI: 💜 💜 getMember: ${querySnapshot.documents.length} members found');
    var mList = List<Member>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Member.fromJson(doc.data));
    });

    if (mList.isNotEmpty) {
      print(
          'ListAPI: 💜 💜 getMember: member found ${mList.first.name}, returnin ....');
      prettyPrint(mList.first.toJson(), 'Member returned from Firestore');
      return mList.first;
    }
    return null;
  }
}
