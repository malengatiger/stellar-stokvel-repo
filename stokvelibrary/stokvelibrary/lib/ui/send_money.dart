import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/ui/scan/payment_scan.dart';

class SendMoney extends StatefulWidget {
  @override
  _SendMoneyState createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney>
    implements PaymentScannerListener {
  var _key = GlobalKey<ScaffoldState>();
  var _members = List<Member>();
  var _stokvels = List<Stokvel>();
  Member _member;
  Stokvel _stokvel;

  @override
  void initState() {
    super.initState();
    _getStokvels();
  }

  _getStokvels() async {
    _member = await Prefs.getMember();
//    _stokvels = _member.stokvels;
    setState(() {});
  }

  _getStokvelMembers(String stokvelId) async {
    print('🧩 🧩 _getStokvelMembers: 🧩 $stokvelId - ${_stokvel.name}');
    setState(() {
      isBusy = true;
    });
    _members = await genericBloc.getStokvelMembers(stokvelId);
    setState(() {
      isBusy = false;
    });
  }

  bool isBusy = false, isStokvelPayment = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Send Money'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'You can send a payment to the Stokvel that you are a member of and you can send a payment to any of the other members',
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Send to ',
                        style: Styles.whiteMedium,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Switch(
                          value: isStokvelPayment, onChanged: _onSwitchChanged),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        isStokvelPayment ? 'Stokvel' : 'Member',
                        style: Styles.blackBoldLarge,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  isStokvelPayment
                      ? Container()
                      : RaisedButton(
                          color: Theme.of(context).primaryColor,
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Scan to Pay Member',
                              style: Styles.whiteSmall,
                            ),
                          ),
                          onPressed: _startScanToPay,
                        ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(300)),
      ),
      backgroundColor: Colors.brown[100],
      body: isStokvelPayment
          ? ListView.builder(
              itemCount: _stokvels.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      _stokvel = _stokvels.elementAt(index);
                      _displayStokvelPaymentDialog();
                    },
                    child: Card(
                      elevation: 2,
                      color: getRandomPastelColor(),
                      child: ListTile(
                        leading: Icon(
                          Icons.apps,
                          color: getRandomColor(),
                        ),
                        title: Text(
                          _stokvels.elementAt(index).name,
                          style: Styles.blackBoldMedium,
                        ),
                      ),
                    ),
                  ),
                );
              })
          : ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    color: getRandomPastelColor(),
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: getRandomColor(),
                      ),
                      title: Text(
                        _members.elementAt(index).name,
                        style: Styles.blackBoldMedium,
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  void _displayStokvelPaymentDialog() {
    print('🧩 🧩 _displayStokvelPaymentDialog ..... ');
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      isStokvelPayment = value;
    });
    if (!isStokvelPayment && _stokvel != null) {
      _getStokvelMembers(_stokvel.stokvelId);
    } else {
      _displayStokvelPaymentDialog();
    }
  }

  void _startScanToPay() {
    if (isStokvelPayment) {
      Navigator.push(
          context,
          SlideRightRoute(
              widget: PaymentScanner(
            type: SCAN_STOKVEL_PAYMENT,
            scannerListener: this,
            memberId: null,
            stokvelId: _stokvel.stokvelId,
          )));
    } else {
      Navigator.push(
          context,
          SlideRightRoute(
              widget: PaymentScanner(
            type: SCAN_MEMBER_PAYMENT,
            scannerListener: this,
            memberId: _member.memberId,
            stokvelId: null,
          )));
    }
  }

  @override
  onPaymentError(String message) {
    // TODO: implement onPaymentError
    return null;
  }

  @override
  omMemberPayment(MemberPayment memberPayment) {
    // TODO: implement omMemberPayment
    return null;
  }

  @override
  onStokvelPayment(StokvelPayment stokvelPayment) {
    // TODO: implement onStokvelPayment
    return null;
  }
}
