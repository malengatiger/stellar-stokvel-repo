import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

import 'auth.dart';
import 'data_api.dart';
import 'list_api.dart';

class GenericBloc extends ChangeNotifier {
  List<Member> _members = List();
  List<Stokvel> _stokvels = List();
  AccountResponse _accountResponse;
  Firestore fs = Firestore.instance;

  Future<AccountResponse> getAccount(String seed) async {
    _accountResponse = await Stellar.getAccount(seed: seed);
    notifyListeners();
    return _accountResponse;
  }

  Future<List<Member>> getStokvelMembers(String stokvelId) async {
    var shot = await fs.collection('members')
        .where('stokvels', arrayContains: {'stokvelId': stokvelId}).getDocuments();
    _members.clear();
    shot.documents.forEach((doc) {
      _members.add(Member.fromJson(doc.data));
    });
    _members.sort((a,b) => a.name.compareTo(b.name));
    notifyListeners();
    return _members;
  }
  Future<List<Stokvel>> getStokvels({int limit = 1000}) async {
    var shot = await fs.collection('members')
        .limit(limit).getDocuments();
    _stokvels.clear();
    shot.documents.forEach((doc) {
      _stokvels.add(Stokvel.fromJson(doc.data));
    });
        notifyListeners();
    return _stokvels;
  }
  var _stokvelMembers = List<Member>();
  var _stokvelPayments = List<StokvelPayment>();
  var _membersPayments = List<MemberPayment>();

  Member _member;

  GenericBloc() {
    print('🅿️ GenericBloc constructor ... 🅿️ 🅿️ ');
    getCachedMember();
  }

  Future getCachedMember() async {
    _member = await Prefs.getMember();
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }

  Future<Member> createMember({Member member, String password}) async {
    _member = await Auth.createMember(member: member, memberPassword: password);
    print('AdminBloc will notify listeners that things are cool! ${_member.name}');
    notifyListeners();
    return _member;
  }

  Future <Stokvel> createStokvel(Stokvel stokvel) async {
    _member = await Prefs.getMember();
    if (_member == null) {
      throw Exception('Admin Member not found');
    }
    var stokvelResult = await DataAPI.createStokvel(stokvel);
    _stokvels.add(stokvelResult);
    await DataAPI.addStokvelToMember(stokvel: stokvel, memberId: _member.memberId);
    notifyListeners();
    return stokvelResult;
  }

  Future<Member> updateMember(Member member) async {
    return await DataAPI.updateMember(member);
  }

  Future<StokvelPayment> sendStokvelPayment({Member member, String amount, Stokvel stokvel}) async {
    var seed = await Prefs.getMemberSeed();
    if (seed == null) {
      throw Exception('Seed not found');
    }
    var payment = StokvelPayment(
      member: member,amount: amount, date: DateTime.now().toUtc().toIso8601String(), seed: seed, stokvel: stokvel,
    );
    var res = await DataAPI.addStokvelPayment(payment: payment, seed: seed);
    _stokvelPayments.add(res);
    notifyListeners();
    return res;
  }

  Future<StokvelPayment> sendMemberToMemberPayment({Member fromMember,Member toMember, String amount}) async {
    var seed = await Prefs.getMemberSeed();
    if (seed == null) {
      throw Exception('Seed not found');
    }
    var payment = MemberPayment(fromMember: fromMember, toMember: toMember, amount: amount, date: DateTime.now().toUtc().toIso8601String());
    var res = await DataAPI.addMemberPayment(payment: payment, seed: seed);
    _membersPayments.add(res);
    notifyListeners();
    return res;
  }

  Future inviteMember(String email) async {

  }
  Future getStokvelPayments(String stokvelId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    var _stokvelPaymnts = await ListAPI.getStokvelPayments(stokvelId);
    var filtered = List<StokvelPayment> ();
    _stokvelPayments.forEach((m) {
      if (m.stokvel.stokvelId != stokvelId) {
        filtered.add(m);
      }
    });
    filtered.addAll(_stokvelPaymnts);
    _stokvelPayments = filtered;
    notifyListeners();
  }

}
