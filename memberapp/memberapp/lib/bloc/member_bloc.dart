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

  Future getMember() async {
    _member = await Prefs.getMember();
    notifyListeners();

  }
  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }
}