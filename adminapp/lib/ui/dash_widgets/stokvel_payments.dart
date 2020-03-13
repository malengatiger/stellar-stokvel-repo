import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class StokvelPaymentsCard extends StatefulWidget {
  @override
  _StokvelPaymentsCardState createState() => _StokvelPaymentsCardState();
}

class _StokvelPaymentsCardState extends State<StokvelPaymentsCard> {
  List<StokvelPayment> _payments = [];
  Member _member;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  _refresh() async {
    _member = await Prefs.getMember();
    _payments = await genericBloc.getStokvelPayments(_member.memberId);
    print(
        'StokvelPaymentsCard: 🦠 🦠 🦠 Stokvel payments: ${_payments.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 160,
      child: StreamBuilder<List<StokvelPayment>>(
          stream: genericBloc.stokvelPaymentStream,
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
