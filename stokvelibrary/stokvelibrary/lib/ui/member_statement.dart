import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

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
  List<MemberPayment> _memberPaymentsMade = [];
  List<MemberPayment> _memberPaymentsReceived = [];
  List<MemberPayment> _memberPaymentsCombined = [];
  List<AccountResponse> _stokvelAccountResponses = [];
  Map<String, List<StokvelPayment>> _stokvelPaymentsMap = Map();
  bool isMemberBusy = false;
  bool isStokvelBusy = false;
  var _key = GlobalKey<ScaffoldState>();
  static const LIMIT = 5;

  @override
  void initState() {
    super.initState();
    refreshMember();
  }

  refreshMember() async {
    setState(() {
      isMemberBusy = true;
    });
    try {
      _member = await genericBloc.getMember(widget.memberId);
      if (_member == null) {
        throw Exception('Member not found');
      }

      _memberPaymentsMade =
          await genericBloc.refreshMemberPaymentsMade(_member.memberId);
      _memberPaymentsReceived =
          await genericBloc.refreshMemberPaymentsReceived(_member.memberId);
      _memberPaymentsCombined.addAll(_memberPaymentsMade);
      _memberPaymentsCombined.addAll(_memberPaymentsReceived);
      _memberPaymentsCombined.sort((a, b) => b.date.compareTo(a.date));
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


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                title: Text('Statements', style: Styles.whiteSmall,),
                leading: Container(),
                actions: <Widget>[
                  IconButton(icon: Icon(Icons.close), onPressed: () {
                    Navigator.pop(context);
                  }),
                ],
                bottom: PreferredSize(child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(_member == null? '': _member.name, style: Styles.whiteBoldMedium,),
                    ),
                    SizedBox(height: 8,),
                    TabBar(
                      tabs: <Widget>[
                        Tab(icon: Icon(Icons.people), text: "Member Payments",),
                        Tab(icon: Icon(Icons.business_center), text: "Group Payments",)
                      ],
                    ),
                    SizedBox(height: 8,)
                  ],
                ), preferredSize: Size.fromHeight(120)),
              ),
              body: Stack(
                children: <Widget>[
                  TabBarView(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MemberPaymentsWidget(
                          member: _member,
                          memberPaymentsCombined: _memberPaymentsCombined,
                          context: context),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StokvelPaymentsWidget(
                          stokvelPaymentsMap: _stokvelPaymentsMap, context: context),
                    ),
                  ]),
                ],
              ))),
    );
  }
}

class StokvelPaymentsWidget extends StatelessWidget implements PaymentWidget {
  const StokvelPaymentsWidget({
    Key key,
    @required Map<String, List<StokvelPayment>> stokvelPaymentsMap,
    @required this.context,
  })  : _stokvelPaymentsMap = stokvelPaymentsMap,
        super(key: key);

  final Map<String, List<StokvelPayment>> _stokvelPaymentsMap;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    var combined = List<StokvelPayment>();
    _stokvelPaymentsMap.values.toList().forEach((m) {
      m.forEach((r) {
        combined.add(r);
      });
    });
    combined.sort((a,b) => b.date.compareTo(a.date));
    return Stack(
      children: <Widget>[
    ListView.builder(
    itemCount: combined.length,
        itemBuilder: (context, index) {
          var payment = combined.elementAt(index);
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${payment.member.name}',
                        style: Styles.greyLabelSmall,
                      ),
                      SizedBox(
                        width: 28,
                      ),
                      Text(
                        '${getFormattedAmount(payment.amount, context)}',
                        style: Styles.blackBoldSmall,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('${payment.stokvel.name}', style: Styles.greyLabelSmall,),
                        ],
                      ),
                      SizedBox(width: 20,),
                      Row(
                        children: <Widget>[
                          Text(getFormattedDateShortWithTime(payment.date, context), style: Styles.greyLabelSmall,),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        Positioned(child: Card(
          color: Theme.of(context).primaryColor,
          elevation: 24,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Text('${combined.length}', style: Styles.whiteBoldSmall,),
              ],
            ),
          ),
        ), left: 2, top: 2,),
      ],
    );
  }
}

class MemberPaymentsWidget extends StatelessWidget implements PaymentWidget {
  const MemberPaymentsWidget({
    Key key,
    @required Member member,
    @required List<MemberPayment> memberPaymentsCombined,
    @required this.context,
  })  : _member = member,
        _memberPaymentsCombined = memberPaymentsCombined,
        super(key: key);

  final Member _member;
  final List<MemberPayment> _memberPaymentsCombined;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemCount: _memberPaymentsCombined.length,
            itemBuilder: (context, index) {
              var payment = _memberPaymentsCombined.elementAt(index);
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Wrap(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Text(
                            payment.fromMember.name,
                            style: Styles.blackBoldSmall,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(' paid to'),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            payment.toMember.name,
                            style: Styles.greyLabelSmall,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            getFormattedDateShortWithTime(
                                payment.date, context),
                            style: Styles.greyLabelSmall,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '${getFormattedAmount(payment.amount, context)}',
                            style:
                            payment.fromMember.memberId == _member.memberId
                                ? Styles.pinkBoldSmall
                                : Styles.tealBoldSmall,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      SizedBox(height: 8,)
                    ],
                  ),
                ),
              );
            }),
        Positioned(child: Card(
          color: Theme.of(context).primaryColor,
          elevation: 24,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text('${_memberPaymentsCombined.length}', style: Styles.whiteBoldSmall,),
              ],
            ),
          ),
        ), left: 2, top: 2,),
      ],
    );
  }
}

abstract class PaymentWidget {}
