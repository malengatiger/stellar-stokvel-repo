import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class MemberPaymentsCard extends StatefulWidget {
  @override
  _MemberPaymentsCardState createState() => _MemberPaymentsCardState();
}

class _MemberPaymentsCardState extends State<MemberPaymentsCard> {
  List<MemberPayment> _payments = [];
  Member _member;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  _refresh() async {
    _member = await Prefs.getMember();
    _payments = await genericBloc.getMemberPaymentsMade(_member.memberId);
    print('MemberPaymentsCard: 🦠 🦠 🦠 Member payments: ${_payments.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 160,
      child: StreamBuilder<List<MemberPayment>>(
          stream: genericBloc.memberPaymentMadeStream,
          builder: (context, snapshot) {
            var cnt = snapshot.hasData ? snapshot.data.length : 0;
            var tot = 0.00;
            if (snapshot.hasData) {
              snapshot.data.forEach((m) {
                tot += double.parse(m.amount);
              });
            }
            return Card(
              child: Column(
                children: <Widget>[
                  Text('Payments'),
                  SizedBox(
                    height: 12,
                  ),
                  Text('$cnt'),
                  Text('Total Amount'),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    getFormattedAmount(tot.toString(), context),
                    style: Styles.blackBoldLarge,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
