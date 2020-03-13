import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
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
    _getMember();
  }

  _getMember() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await Prefs.getMember();

      if (_member.stokvelIds == null || _member.stokvelIds.isEmpty) {
        _displayNoStokvelDialog();
      } else {
        for (var id in _member.stokvelIds) {
          var stokvel = await ListAPI.getStokvelById(id);
          _stokvels.add(stokvel);
        }
        _buildDropDown();
      }
      if (_member != null) {
        await _getStokvelMembers();
      }
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Data retrieval failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  _displayNoStokvelDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Stokvel Unavailable",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Your account does not belong to any Stokvels yet. You may start your own Stokvel or be invited to one.',
                      style: Styles.blackMedium,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    color: Colors.blue,
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Close',
                        style: Styles.whiteSmall,
                      ),
                    ),
                    onPressed: _close,
                  ),
                ),
              ],
            ));
  }

  _getStokvelMembers() async {
    print('🧩 🧩 .................... _getStokvelMembers: 🧩 ');
    setState(() {
      isBusy = true;
    });
    _members = [];
    for (var stokvelId in _member.stokvelIds) {
      var members = await genericBloc.getStokvelMembers(stokvelId);
      print(
          '🧩 🧩 .................... _getStokvelMembers: 🧩  found: ${members.length}');
      members.forEach((m) {
        if (m.memberId != _member.memberId) {
          _members.add(m);
        }
      });
      _members.sort((a, b) => a.name.compareTo(b.name));
    }
    print('SendMoney:  🔵 members found: ${_members.length}');
    if (_member.stokvelIds.length == 1) {
      _stokvel = await ListAPI.getStokvelById(_member.stokvelIds.first);
      prettyPrint(
          _stokvel.toJson(), "🧡 🧡 🧡  stokvel retrieved from Firestore");
    }

    setState(() {
      isBusy = false;
    });
  }

  _buildDropDown() {
    _stokvels.forEach((s) {
      items.add(DropdownMenuItem(child: Text(s.name)));
    });
  }

  bool isBusy = false, isStokvelPayment = true;

  void _displayStokvelPaymentDialog() {
    print('🧩 🧩 ........ _displayStokvelPaymentDialog ..... ');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Stokvel Unavailable",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 140.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'You are about to make a Stokvel payment of ${amountController.text} to ${_stokvel.name}',
                      style: Styles.blackSmall,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: FlatButton(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Cancel',
                        style: Styles.pinkBoldSmall,
                      ),
                    ),
                    onPressed: _close,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    color: Colors.blue,
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Send Payment',
                        style: Styles.whiteSmall,
                      ),
                    ),
                    onPressed: _sendStokkiePayment,
                  ),
                ),
              ],
            ));
  }

  void _dismissKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _sendStokkiePayment() async {
    Navigator.pop(context);
    _dismissKeyboard();
    double amount = double.parse(amountController.text);
    if (amount == 0) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please enter amount');
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      var me = await Prefs.getMember();
      var res = await genericBloc.sendStokvelPayment(
          member: me, amount: amountController.text, stokvel: _stokvel);
      prettyPrint(res.toJson(), "🍎 Stokvel Payment Result 🍎 ");
      AppSnackBar.showSnackBar(
          scaffoldKey: _key,
          message: 'Stokvel Payment Succeeded',
          textColor: Colors.lightGreen,
          backgroundColor: Colors.black);
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Stokvel Payment failed');
    }

    setState(() {
      isBusy = false;
    });
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      isStokvelPayment = value;
    });
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
            amount: amountController.text,
            stokvelId: _stokvel.stokvelId,
          )));
    } else {
      Navigator.push(
          context,
          SlideRightRoute(
              widget: PaymentScanner(
            type: SCAN_MEMBER_PAYMENT,
            scannerListener: this,
            amount: amountController.text,
            memberId: _member.memberId,
            stokvelId: _stokvel.stokvelId,
          )));
    }
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      if (_member != null) {
        _members = await _getStokvelMembers();
      }
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Data refresh failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  List<DropdownMenuItem<Stokvel>> items = [];
  var amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Send Money'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
        ],
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
                    height: 28,
                  ),
                  isBusy
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 0,
                            ),
                          ],
                        )
                      : Container(),
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
                        style: Styles.blackBoldMedium,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _stokvel == null
                      ? Container()
                      : Text(
                          _stokvel.name,
                          style: Styles.whiteBoldMedium,
                        ),
                  SizedBox(
                    height: 20,
                  ),
//                  DropdownButton(items: items, onChanged: onStokvelChanged),
                  _stokvel == null
                      ? Container()
                      : TextField(
                          style: Styles.blackBoldMedium,
                          controller: amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                  isStokvelPayment
                      ? Container()
                      : Column(
                          children: <Widget>[
                            SizedBox(
                              height: 12,
                            ),
                            RaisedButton(
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
                          ],
                        ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(400)),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isStokvelPayment ? _buildStokvelList() : _buildMemberList(),
    );
  }

  ListView _buildMemberList() {
    if (_members == null) {
      _members = [];
    }
    return ListView.builder(
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
                  style: Styles.blackBoldSmall,
                ),
              ),
            ),
          );
        });
  }

  ListView _buildStokvelList() {
    return ListView.builder(
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
                    style: Styles.blackBoldSmall,
                  ),
                ),
              ),
            ),
          );
        });
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

  void _close() {
    //todo - the user is a Member who has no stokvel ... they should download admin app
    print(
        '🔵 🔵  the user is a Member who has no stokvel ... they should download admin app');
    Navigator.pop(context);
  }

  void onStokvelChanged(Stokvel value) {
    setState(() {
      _stokvel = value;
    });
  }
}
