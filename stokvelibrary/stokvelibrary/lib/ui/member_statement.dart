import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/ui/member_account_card.dart';
import 'package:stokvelibrary/ui/stokvel_account_card.dart';

import '../functions.dart';
import '../snack.dart';

class MemberStatement extends StatefulWidget {
  final String memberId;

  const MemberStatement(this.memberId, {Key key}) : super(key: key);

  @override
  _MemberStatementState createState() => _MemberStatementState();
}

class _MemberStatementState extends State<MemberStatement> {
  Member _member;
  List<MemberPayment> _memberPayments = [];
  AccountResponse _memberAccountResponse;
  List<AccountResponse> _stokvelAccountResponses = [];
  Map<String, List<StokvelPayment>> _stokvelPaymentsMap = Map();
  bool isMemberBusy = false;
  bool isStokvelBusy = false;
  List<Widget> _widgets = [];
  var _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshMember();
  }

  _refreshMember() async {
    setState(() {
      isMemberBusy = true;
    });
    try {
      _member = await genericBloc.getMember(widget.memberId);
      if (_member == null) {
        throw Exception('Member not found');
      }
      _memberAccountResponse =
          await genericBloc.refreshAccount(memberId: _member.memberId);
      _memberPayments =
          await genericBloc.refreshMemberPayments(_member.memberId);
      setState(() {
        isMemberBusy = false;
      });
      _refreshStokvels();
    } catch (e) {
      print(e);
      if (mounted) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Data refresh failed');
      }
    }
  }

  _refreshStokvels() async {
    setState(() {
      isStokvelBusy = true;
    });
    try {
      for (var stokvelId in _member.stokvelIds) {
        var resp = await genericBloc.refreshAccount(stokvelId: stokvelId);
        _stokvelAccountResponses.add(resp);
        var payments = await genericBloc.refreshStokvelPayments(stokvelId);
        _stokvelPaymentsMap[stokvelId] = payments;
      }
    } catch (e) {
      print(e);
      if (mounted) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Data refresh failed');
      }
    }
    setState(() {
      isStokvelBusy = false;
    });
  }

  Widget _getStokvelWidgets() {
    if (_member == null) {
      return Container();
    }
    _widgets.clear();
    _member.stokvelIds.forEach((stokvelId) {
      _widgets.add(StokvelAccountCard(
        stokvelId: stokvelId,
        forceRefresh: true,
      ));
    });
    return Container(
      height: _member == null ? 0.0 : _member.stokvelIds.length * 300.0,
      child: Column(
        children: _widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Member Statement'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  isStokvelBusy = false;
                });
                _refreshMember();
              }),
        ],
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Text(
                  _member == null ? '' : _member.name,
                  style: Styles.whiteBoldMedium,
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
            preferredSize: Size.fromHeight(80)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              isMemberBusy
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : MemberAccountCard(
                      memberId: _member.memberId,
                      forceRefresh: true,
                    ),
              isStokvelBusy
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _getStokvelWidgets()
            ],
          ),
        ),
      ),
    );
  }
}
