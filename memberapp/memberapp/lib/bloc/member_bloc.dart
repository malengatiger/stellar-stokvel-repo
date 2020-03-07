import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

class MemberBloc extends ChangeNotifier {
  Member _member;


  MemberBloc() {
    print('🅿️ MemberBloc constructor ... 🅿️ 🅿️ ');
    getMember();
  }

  Future<Member> createMember({Member member, String password}) async {
    _member = await Auth.createMember(member: member, memberPassword: password);
    print('MemberBloc will notify listeners that things are cool! ${_member.name}');
    notifyListeners();
    return _member;
  }
  Future getMember() async {
    _member = await Prefs.getMember();

  }
  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }
}