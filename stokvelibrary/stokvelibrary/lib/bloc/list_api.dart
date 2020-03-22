import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

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

  static Future<List<Stokvel>> getStokvels() async {
    var querySnapshot = await _firestore.collection('stokvels').getDocuments();
    var mList = List<Stokvel>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Stokvel.fromJson(doc.data));
    });
    mList.sort((a, b) => a.name.compareTo(b.name));
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
      await LocalDB.addStokvel(stokvel: stokvel);
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
    var querySnapshot = await _firestore
        .collection('members')
        .where('stokvelIds', arrayContains: stokvelId)
        .getDocuments();
    var mList = List<Member>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Member.fromJson(doc.data));
    });

    return mList;
  }

  static Future<String> getStokvelSeed(String stokvelId) async {
    var cred = await getStokvelCredential(stokvelId);
    return makerBloc.getDecryptedSeed(cred);
  }

  static Future<StokkieCredential> getStokvelCredential(
      String stokvelId) async {
    var querySnapshot = await _firestore
        .collection('creds')
        .where('stokvelId', isEqualTo: stokvelId)
        .limit(1)
        .getDocuments();
    var mList = List<StokkieCredential>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokkieCredential.fromJson(doc.data));
    });
    print(
        '🔵 🔵 ListAPI: getStokvelCredential found on Firestore 🔵 ${mList.length} 🔵 creds');
    if (mList.isNotEmpty) {
      return mList.elementAt(0);
    }
    return null;
  }

  static Future<StokkieCredential> getMemberCredential(String memberId) async {
    var querySnapshot = await _firestore
        .collection('creds')
        .where('memberId', isEqualTo: memberId)
        .limit(1)
        .getDocuments();
    var mList = List<StokkieCredential>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokkieCredential.fromJson(doc.data));
    });
    print(
        '🔵 🔵 ListAPI: getMemberCredential found on Firestore 🔵 ${mList.length} 🔵 creds');
    if (mList.isNotEmpty) {
      return mList.elementAt(0);
    }
    return null;
  }

  static Future<List<StokvelPayment>> getStokvelPayments(
      String stokvelId) async {
    var querySnapshot = await _firestore
        .collection('stokvelPayments')
        .where('stokvel.stokvelId', isEqualTo: stokvelId)
        .limit(PAYMENT_LIST_LIMIT)
        .getDocuments();
    var mList = List<StokvelPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(StokvelPayment.fromJson(doc.data));
    });

    return mList;
  }

  static Future<List<MemberPayment>> getMemberPayments(String memberId) async {
    var querySnapshot = await _firestore
        .collection('memberPayments')
        .orderBy('date', descending: true)
        .where('fromMember.memberId', isEqualTo: memberId)
        .limit(PAYMENT_LIST_LIMIT)
        .getDocuments();
    var mList = List<MemberPayment>();
    querySnapshot.documents.forEach((doc) {
      mList.add(MemberPayment.fromJson(doc.data));
    });
    return mList;
  }

  static Future<Member> getMember(String memberId) async {
    var querySnapshot = await _firestore
        .collection('members')
        .where('memberId', isEqualTo: memberId)
        .limit(1)
        .getDocuments();

    var mList = List<Member>();
    querySnapshot.documents.forEach((doc) {
      mList.add(Member.fromJson(doc.data));
    });

    if (mList.isNotEmpty) {
      return mList.first;
    }
    return null;
  }
}

const int PAYMENT_LIST_LIMIT = 1000;
