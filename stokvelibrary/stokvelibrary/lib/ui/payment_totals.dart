import 'package:flutter/material.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class MemberPaymentsTotals extends StatefulWidget {
  final String memberId;

  const MemberPaymentsTotals({Key key, this.memberId}) : super(key: key);
  @override
  _MemberPaymentsTotalsState createState() => _MemberPaymentsTotalsState();
}

class _MemberPaymentsTotalsState extends State<MemberPaymentsTotals> {
  var _memberPayments = List<MemberPayment>();
  bool isBusy = false;
  Member _member;
  @override
  void initState() {
    super.initState();
    if (widget.memberId == null) {
      throw Exception('Missing memberId');
    }
    _refresh();
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await genericBloc.getMember(widget.memberId);
      _memberPayments =
          await genericBloc.refreshMemberPaymentsMade(widget.memberId);
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
        : GestureDetector(
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
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
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
                        _memberPayments == null ? '0' : _getMemberTotals(),
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
  }

  String _getMemberTotals() {
    var tot = 0.00;
    _memberPayments.forEach((p) {
      tot += double.parse(p.amount);
    });
    return getFormattedAmount(tot.toString(), context);
  }
}

class StokvelPaymentsTotals extends StatefulWidget {
  final String stokvelId;

  const StokvelPaymentsTotals({Key key, this.stokvelId}) : super(key: key);
  @override
  _StokvelPaymentsTotalsState createState() => _StokvelPaymentsTotalsState();
}

class _StokvelPaymentsTotalsState extends State<StokvelPaymentsTotals> {
  var _stokvelPayments = List<StokvelPayment>();
  bool isBusy = false;
  Stokvel _stokvel;
  @override
  void initState() {
    super.initState();
    if (widget.stokvelId == null) {
      throw Exception('Missing stokvelId');
    }
    _refresh();
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      _stokvel = await genericBloc.getStokvelById(widget.stokvelId);
      if (_stokvel == null) {
        throw Exception('Group not found ');
      }
      _stokvelPayments =
          await genericBloc.refreshStokvelPayments(widget.stokvelId);
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
        : GestureDetector(
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
                          _stokvel == null ? 'Stokvel' : _stokvel.name,
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
                          style: Styles.blackBoldMedium,
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
  }

  String _getStokvelTotals() {
    var tot = 0.00;
    _stokvelPayments.forEach((p) {
      tot += double.parse(p.amount);
    });
    return getFormattedAmount(tot.toString(), context);
  }
}
