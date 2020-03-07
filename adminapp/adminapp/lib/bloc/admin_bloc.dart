import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/data_api.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

final AdminBloc adminBloc = AdminBloc();
class AdminBloc extends ChangeNotifier {

  var _stokvels = List<Stokvel>();
  var _stokvelMembers = List<Member>();
  var _stokvelPayments = List<StokvelPayment>();
  var _membersPayments = List<MemberPayment>();

  Member _adminMember;


  AdminBloc() {
      print('🅿️ AdminBloc constructor ... 🅿️ 🅿️ ');
      getAdmin();
  }

  Future getAdmin() async {
    _adminMember = await Prefs.getMember();

  }
  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }
  Future<Member> createMember({Member member, String password}) async {
    _adminMember = await Auth.createMember(member: member, memberPassword: password);
    print('AdminBloc will notify listeners that things are cool! ${_adminMember.name}');
    notifyListeners();
    return _adminMember;
  }
  Future <Stokvel> createStokvel(Stokvel stokvel) async {
    _adminMember = await Prefs.getMember();
    if (_adminMember == null) {
      throw Exception('Admin Memeber not found');
    }
    var stokvelResult = await DataAPI.createStokvel(stokvel);
    _stokvels.add(stokvelResult);
    await DataAPI.addStokvelToMember(stokvel: stokvel, memberId: _adminMember.memberId);
    notifyListeners();
    return stokvelResult;
  }

  Future<Member> updateMember(Member member) async {
    return await DataAPI.updateMember(member);
  }

  Future<List<Stokvel>> getStokvels() async {
    if (_adminMember == null) {
      _adminMember = await getAdmin();
    }
    _stokvels = await ListAPI.getStokvelsAdministered(_adminMember.memberId);
    notifyListeners();
    return _stokvels;
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
  Future<StokvelPayment> sendMemberPayment({Member fromMember,Member toMember, String amount}) async {
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
    if (_adminMember == null) {
      _adminMember = await getAdmin();
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