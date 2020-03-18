import 'package:flutter/material.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class PaymentsTotals extends StatefulWidget {
  final String stokvelId, memberId;

  const PaymentsTotals({Key key, this.stokvelId, this.memberId})
      : super(key: key);
  @override
  _PaymentsTotalsState createState() => _PaymentsTotalsState();
}

class _PaymentsTotalsState extends State<PaymentsTotals> {
  var _memberPayments = List<MemberPayment>();
  var _stokvelPayments = List<StokvelPayment>();
  bool isBusy = false;
  Stokvel _stokvel;
  Member _member;
  @override
  void initState() {
    super.initState();
    print(
        '🔴 🔴 🔴 🔴 🔴 PaymentsTotals: initState 🔴 stokvelId: ${widget.stokvelId} 🔴 memberId: ${widget.memberId}');
    if (widget.stokvelId == null && widget.memberId == null) {
      throw Exception('Missing stokvelId or memberId');
    }
    _refresh();
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });

    try {
      if (widget.stokvelId != null) {
        _stokvel = await LocalDB.getStokvelById(widget.stokvelId);
        if (_stokvel == null) {
          throw Exception('Stokvel not found when need for payment query');
        }
        _stokvelPayments =
            await genericBloc.getStokvelPayments(widget.stokvelId);
      }
      if (widget.memberId != null) {
        _member = await LocalDB.getMember(widget.memberId);
        _memberPayments = await genericBloc.getMemberPayments(widget.memberId);
      }
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? Center(
            child: CircularProgressIndicator(),
          )
        : widget.stokvelId == null
            ? Container(
                child: StreamBuilder<List<MemberPayment>>(
                    stream: genericBloc.memberPaymentStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(
                            '......... we have snapshot data here _memberPayments....');
                        _memberPayments = snapshot.data;
                      } else {
                        print(
                            '......... we have NO _memberPayments snapshot data here ....');
                        _memberPayments = [];
                      }
                      return GestureDetector(
                        onTap: _refresh,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    _member == null ? 'Member' : _member.name,
                                    style: Styles.greyLabelSmall,
                                  ),
                                  SizedBox(
                                    width: 48,
                                  ),
                                  Text(
                                    '${_memberPayments.length}',
                                    style: Styles.blackBoldMedium,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    'Total',
                                    style: Styles.greyLabelSmall,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    _memberPayments == null
                                        ? '0'
                                        : _getMemberTotals(),
                                    style: Styles.tealBoldMedium,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        )),
                      );
                    }),
              )
            : Container(
                child: StreamBuilder<List<StokvelPayment>>(
                    stream: genericBloc.stokvelPaymentStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print('......... we have snapshot data here ....');
                        _stokvelPayments = snapshot.data;
                      } else {
                        print('......... we have NO snapshot data here ....');
                        _stokvelPayments = [];
                      }
                      return GestureDetector(
                        onTap: _refresh,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _stokvel == null
                                          ? 'Stokvel'
                                          : _stokvel.name,
                                      style: Styles.blackBoldSmall,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(''),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      '${_stokvelPayments.length}',
                                      style: Styles.blueBoldMedium,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      'Total',
                                      style: Styles.greyLabelSmall,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Text(
                                      _getStokvelTotals(),
                                      style: Styles.blueBoldMedium,
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
  }

  String _getStokvelTotals() {
    var tot = 0.00;
    _stokvelPayments.forEach((p) {
      tot += double.parse(p.amount);
    });
    return getFormattedAmount(tot.toString(), context);
  }

  String _getMemberTotals() {
    var tot = 0.00;
    _memberPayments.forEach((p) {
      tot += double.parse(p.amount);
    });
    return getFormattedAmount(tot.toString(), context);
  }
}
