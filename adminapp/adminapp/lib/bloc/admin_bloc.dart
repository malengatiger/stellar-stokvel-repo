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
      getCachedMember();
  }

  Future getCachedMember() async {
    _adminMember = await Prefs.getMember();
    notifyListeners();
  }
  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }

  Future <Stokvel> createStokvel(Stokvel stokvel) async {
    _adminMember = await Prefs.getMember();
    if (_adminMember == null) {
      throw Exception('Admin Member not found');
    }
    var stokvelResult = await DataAPI.createStokvel(stokvel);
    _stokvels.add(stokvelResult);
    await DataAPI.addStokvelToMember(stokvel: stokvel, memberId: _adminMember.memberId);
    notifyListeners();
    return stokvelResult;
  }

  Future inviteMember(String email) async {

  }

}