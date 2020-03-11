import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellarplugin/data_models/account_response_bag.dart';
import 'package:stellarplugin/data_models/payment_response.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var _key = GlobalKey<ScaffoldState>();
  var isBusy = false;
  var totalPaymentsReceived = List<PaymentOperationResponse>();
  var paymentsMade0 = List<PaymentOperationResponse>();
  var accountResponses = List<AccountResponseBag>();
  var random = Random(DateTime.now().millisecondsSinceEpoch);
  var fs = Firestore.instance;

  @override
  initState() {
    super.initState();
    _getAuth();
  }

  String _getRandomAmount() {
    var amt = random.nextInt(100);
    if (amt < 10) {
      amt = 12;
    }
    return amt.toString() + "." + random.nextInt(100).toString();
  }

  void _getAuth() async {
    var isAuth = await Auth.checkAuth();
    if (isAuth) {
      await Auth.signInAnon();
    }
  }

  void _writeAccountResponse(AccountResponseBag bag) async {
    var res = await makerBloc.writeAccountResponse(bag);
    print('🥬 🥬 🥬 ${res}');
  }

  void writeStokvel(Stokvel bag) async {
    var res = await makerBloc.writeStokvel(bag);
    print('🥬 🥬 🥬 $res');
  }

  static const NUMBER_OF_ACCOUNTS = 5;
  Future _createAccount() async {
    print('🔆 🔆 🔆 🔆 🔆 🔆 🔆 🔆  _createAccounts starting .....');
    setState(() {
      isBusy = true;
    });
    try {
      for (var mm = 0; mm < NUMBER_OF_ACCOUNTS; mm++) {
        var accountResponse =
            await Stellar.createAccount(isDevelopmentStatus: true);
        accountResponses.add(accountResponse);
        _writeAccountResponse(accountResponse);
        print('_MyAppState:  🥬 _createAccounts: '
            'Account created by Stellar returned: 🍎 Accounts: ${accountResponses.length} 🍎');
        widgets.add(Row(
          children: <Widget>[
            Text('Account created. Balance:'),
            Text(
              "${getFormattedAmount(accountResponse.accountResponse.balances.first.balance, context)} XLM ",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ));
        setState(() {});
        var snackBar = SnackBar(
          content: Text(
            'Account ${accountResponses.length} has been created',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        );
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(snackBar);
      }
      widgets.add(SizedBox(
        height: 8,
      ));
      var snackBar = SnackBar(
        content: Text(
          '${accountResponses.length} accounts have been created',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
      setState(() {
        isBusy = false;
      });
    } on PlatformException catch (e) {
      print('🔴 🔴 🔴 We have a Plugin problem');
      setState(() {
        isBusy = false;
        widgets.add(Text(
          "🔴 We have a problem ... $e",
          style:
              TextStyle(fontWeight: FontWeight.normal, color: Colors.pink[400]),
        ));
      });
    }
  }

  Future _sendPayment() async {
    if (accountResponses.length < 2) {
      print(
          '🔆 🔆 🔆 🔆 Please create at least 2 accounts for this (payment tranx) to work');
      var snackBar = SnackBar(
        content: Text(
          'Please create at least 2 accounts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
      );
      _key.currentState.showSnackBar(snackBar);
      return;
    }
    setState(() {
      isBusy = true;
    });
    for (var acct in accountResponses) {
      for (var i = 0; i < accountResponses.length; i++) {
        if (acct.accountResponse.accountId !=
            accountResponses.elementAt(i).accountResponse.accountId) {
          try {
            await _performSend(acct, i);
          } catch (e) {
            print(e);
          }
        }
      }
    }

    print('\n................................... '
        'Getting all data from transactions after payment transactions to this point: $totalPaymentsMade .... ');
    widgets.add(SizedBox(
      height: 8,
    ));
    widgets.add(Row(
      children: <Widget>[
        Text(
          "Total Payment made :",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "$totalPaymentsMade",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    ));
    widgets.add(SizedBox(
      height: 8,
    ));
    setState(() {
      isBusy = false;
    });
    try {
      await _getAccounts();
      await _getPaymentsReceived();
      await _getPaymentsMade();
    } on PlatformException catch (e) {
      print('🔴 🔴 We have a Plugin problem: 🔴 $e');
    }
  }

  var map = Map<String, List<PaymentOperationResponse>>();
  var totalPaymentsMade = 0;
  Future _performSend(AccountResponseBag acct, int i) async {
    print('\n................................... index = $i - '
        'Sending payment made by ${acct.accountResponse.accountId} ');
    var seed = acct.secretSeed;
    var amount = _getRandomAmount();
    var memo = "Tx ${i + 1} from Flutter";
    var destinationAccount =
        accountResponses.elementAt(i).accountResponse.accountId;
    var response = await Stellar.sendPayment(
        seed: seed,
        destinationAccount: destinationAccount,
        amount: amount,
        memo: memo,
        isDevelopmentStatus: true);
    totalPaymentsMade++;
    print(
        '_MyAppState: _sendPayment: 🥬 🥬 🥬 🥬  Payment executed; json from object: ${response.toJson()}  🍎  🍎 ');
    widgets.add(Row(
      children: <Widget>[
        Text(
          "Payment made :",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "${getFormattedAmount(amount, context)} XLM",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[600]),
        ),
      ],
    ));
    setState(() {});
    var snackBar = SnackBar(
      content: Text(
        'Payment: $amount XLM has been made',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.indigo[700],
    );
    _key.currentState.showSnackBar(snackBar);
  }

  Future _getPaymentsReceived() async {
    if (accountResponses.length < 2) {
      print(
          '🔆 🔆 🔆 🔆 Please create at least 2 accounts for this (_getPaymentsReceived tranx) to work');
      var snackBar = SnackBar(
        content: Text(
          'Please create at least 2 accounts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      var cnt = 0;
      totalPaymentsReceived.clear();
      for (var acct in accountResponses) {
        var paymnts = await Stellar.getPaymentsReceived(seed: acct.secretSeed);
        totalPaymentsReceived.addAll(paymnts);
        print('_MyAppState: _getPaymentsReceived: 🥬 🥬 👺 Payments received, '
            'account #${acct.accountResponse.accountId} : ${paymnts.length}  🍎 🍎 ');
        cnt++;
        widgets.add(Row(
          children: <Widget>[
            Text(
              "Payments received for Account #$cnt",
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "${paymnts.length}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue[600]),
            ),
          ],
        ));
        setState(() {});
        var snackBar = SnackBar(
            content:
                Text('${paymnts.length} Payments received for Account #$cnt'));
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(snackBar);
      }
      widgets.add(SizedBox(
        height: 8,
      ));
      setState(() {
        isBusy = false;
      });
      var snackBar = SnackBar(
        content: Text(
          'Payments Received for all accounts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
    } on PlatformException catch (e) {
      print('We have a Plugin problem: $e');
    }
  }

  Future _getPaymentsMade() async {
    if (accountResponses.length < 2) {
      print(
          '🔆 🔆 🔆 🔆 Please create at least 2 accounts for this (_getPaymentsMade tranx) to work');
      var snackBar = SnackBar(
        content: Text(
          'Please create at least 2 accounts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
      return;
    }
    setState(() {
      isBusy = true;
    });
    try {
      var cnt = 0;
      paymentsMade0.clear();
      for (var acct in accountResponses) {
        var paymnts = await Stellar.getPaymentsMade(seed: acct.secretSeed);
        paymentsMade0.addAll(paymnts);
        cnt++;
        print(
            '\n_MyAppState: _getPaymentsMade: 💙💙 💙💙 💙💙 💙💙   Payments made (account #$cnt): ${paymnts.length}  🍎  🍎 💙💙 💙💙 💙💙 ');
        widgets.add(Row(
          children: <Widget>[
            Text(
              "Payments made by Account #$cnt ",
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "${paymnts.length}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.pink[600]),
            ),
          ],
        ));
        setState(() {});
        var snackBar = SnackBar(
            content: Text('${paymnts.length} Payments Made by Account #$cnt'));
        _key.currentState.removeCurrentSnackBar();
        _key.currentState.showSnackBar(snackBar);
      }
      widgets.add(SizedBox(
        height: 8,
      ));
      setState(() {
        isBusy = false;
      });
      var snackBar = SnackBar(
        content: Text(
          'All Payments Made listed below',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink[700],
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
    } on PlatformException catch (e) {
      print('We have a Plugin problem: $e');
    }
  }

  Future _getAccounts() async {
    print(
        '_MyAppState: _getAccount: 🥬 🥬 🥬 🥬  .... getting Account from Stellar  🍎  🍎 ');
    if (accountResponses.isEmpty) {
      print('You need at least 1 account created for this to work 🔆 🔆 🔆 🔆');
      var snackBar = SnackBar(
        content: Text(
          'You need at least 1 account created for this to work',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
      );
      _key.currentState.removeCurrentSnackBar();
      _key.currentState.showSnackBar(snackBar);
    }
    try {
      setState(() {
        isBusy = true;
      });
      var cnt = 0;
      for (var resp in accountResponses) {
        var acct = await Stellar.getAccount(seed: resp.secretSeed);
        print(
            '_MyAppState: _getAccount: 🥬 🥬 🥬 🥬  Account retrieved: ${acct.accountId}  🍎 '
            'balance: ${getFormattedAmount(acct.balances.first.balance, context)} XLM  ');
        cnt++;
        widgets.add(Row(
          children: <Widget>[
            Text(
              "Account #$cnt retrieved. Balance: ",
              style:
                  TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "${getFormattedAmount(acct.balances.first.balance, context)} XLM ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.teal[700]),
            ),
          ],
        ));
        _key.currentState.removeCurrentSnackBar();
        var snackBar = SnackBar(
            content: Text(
                'Account Retrieved #$cnt Bal: ${getFormattedAmount(acct.balances.first.balance, context)} XLM'));
        _key.currentState.showSnackBar(snackBar);
      }
      widgets.add(SizedBox(
        height: 8,
      ));
      setState(() {
        isBusy = false;
      });
      var snackBar = SnackBar(
          content: Text('${accountResponses.length} Total Accounts Retrieved'));
      _key.currentState.showSnackBar(snackBar);
    } on PlatformException {
      print('We have a Plugin problem');
    }
  }

  var widgets = List<Widget>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Stellar Flutter Plugin Example'),
        backgroundColor: Colors.pink[300],
        actions: <Widget>[],
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Plugin to access Stellar SDK from Flutter apps. Created from official Java SDK',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Stellar API\'s available'),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        '13',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Stellar Accounts'),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        '${accountResponses.length}',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Payments Received:'),
                      SizedBox(
                        width: 24,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (accountResponses.isNotEmpty) {
                            _startAccount1(context);
                          }
                        },
                        child: Text(
                          '${totalPaymentsReceived.length}',
                          style: TextStyle(
                              fontSize: 36,
                              color: Colors.black,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Payments Made:'),
                      SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          _startAccount1(context);
                        },
                        child: Text(
                          '${paymentsMade0.length}',
                          style: TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Tap the totals to see more account details ...',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Payments are random < 100 XLM per payment',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(340)),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 360,
                      child: RaisedButton(
                        elevation: 4,
                        color: Colors.teal[700],
                        onPressed: _createAccount,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 360,
                      child: RaisedButton(
                        elevation: 4,
                        color: Colors.teal[500],
                        onPressed: _getAccounts,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Retrieve Accounts',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 360,
                      child: RaisedButton(
                        elevation: 4,
                        color: Colors.blue[700],
                        onPressed: _sendPayment,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Send Payment',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 360,
                      child: RaisedButton(
                        elevation: 4,
                        color: Colors.pink[700],
                        onPressed: _getPaymentsMade,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Get Payments Made',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: 360,
                      child: RaisedButton(
                        elevation: 4,
                        color: Colors.indigo[700],
                        onPressed: _getPaymentsReceived,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Get Payments Received',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 2,
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: widgets,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _startAccount1(BuildContext context) {
    print('startAccount1 ...............');
//    Navigator.push(
//        context,
//        SlideRightRoute(
//            widget: AccountDetails(
//              accountName: "Account #1",
//              paymentsMade: paymentsMade0,
//              paymentsReceived: totalPaymentsReceived,
//              accountResponse: accountResponses.elementAt(0),
//            )));
  }
}
