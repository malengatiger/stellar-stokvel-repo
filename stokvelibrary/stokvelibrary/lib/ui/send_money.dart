import 'package:flutter/material.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
import 'package:stokvelibrary/ui/scan/payment_scan.dart';
import 'package:stokvelibrary/ui/stokvel_goal_list.dart';
import 'package:toast/toast.dart';

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
      _member = await genericBloc.refreshMember(_member.memberId);
      prettyPrint(_member.toJson(),
          '🔵 🔵 🔵 MEMBER doin the paying; check stokvelIds 🔵 🔵 🔵 ');
      if (_member.stokvelIds == null || _member.stokvelIds.isEmpty) {
        _member = await LocalDB.getMember(_member.memberId);
      }
      if (_member.stokvelIds == null || _member.stokvelIds.isEmpty) {
        _displayNoStokvelDialog();
      } else {
        for (var id in _member.stokvelIds) {
          var stokvel = await LocalDB.getStokvelById(id);
          _stokvels.add(stokvel);
        }
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
              title: new Text("Group Unavailable",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Your account does not belong to any Stokvels yet. You may start your own Group or be invited to one.',
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
          'SendMoney: _getStokvelMembers: 🔵 🔵 🔵 ........: 🧩  found: ${members.length}');
      members.forEach((m) {
        if (m.memberId != _member.memberId) {
          _members.add(m);
        }
      });
      _members.sort((a, b) => a.name.compareTo(b.name));
    }
    print(
        'SendMoney: 🔵 🔵 🔵 all stokvel members found: 🔵 ${_members.length}');
    if (_member.stokvelIds.length == 1) {
      _stokvel = await ListAPI.getStokvelById(_member.stokvelIds.first);
      prettyPrint(_stokvel.toJson(),
          "🧡 🧡 🧡  stokvel retrieved from Firestore, only one stokvel for this member");
    }

    setState(() {
      isBusy = false;
    });
  }

  bool isBusy = false, isStokvelPayment = true;

  void _displayStokvelPaymentDialog() {
    print('🧩 🧩 ........ _displayStokvelPaymentDialog ..... ');
    if (amountController.text.isEmpty) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please enter amount');
      return;
    }
    _dismissKeyboard();
    double amount = double.parse(amountController.text);
    if (amount == 0) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please enter amount');
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Group Payment", style: Styles.blackBoldMedium),
              content: Container(
                height: 140.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'You are about to make a Group payment of ${amountController.text} to ${_stokvel.name}. Do you want to select the Goal you are contributing to?',
                      style: Styles.blackSmall,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Container(
                  height: 80, width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Select Group Goal',
                          style: Styles.whiteSmall,
                        ),
                      ),
                      onPressed: () {
                        _navigateToGoals();
                      },
                    ),
                  ),
                ),
                Container(
                  height: 80, width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Just Send Payment',
                          style: Styles.whiteSmall,
                        ),
                      ),
                      onPressed: () {
                        _sendStokkiePayment(null);
                      },
                    ),
                  ),
                ),
              ],
            ));
  }

  void _displayMemberPaymentDialog(Member member) {
    print('🧩 🧩 ........ _displayMemberPaymentDialog ..... ');
    _dismissKeyboard();
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Member Payment", style: Styles.blackBoldMedium),
              content: Container(
                height: 140.0,
                child: Column(
                  children: <Widget>[
                    Text(
                      'You are about to make a Member payment of ${amountController.text} to ${member.name}',
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
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                    onPressed: _close,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Send Payment',
                        style: Styles.whiteSmall,
                      ),
                    ),
                    onPressed: () {
                      _sendMemberPayment(member);
                    },
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

  void _sendStokkiePayment(StokvelGoal goal) async {
    Navigator.pop(context);
    _dismissKeyboard();
    if (amountController.text.isEmpty) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please enter amount');
      return;
    }
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
      var me = await genericBloc.getCachedMember();
      var res = await genericBloc.sendStokvelPayment(
          member: me, amount: amountController.text, stokvel: _stokvel);
      prettyPrint(res.toJson(), "🍎 Group Payment Result 🍎 ");

      if (goal != null) {
        await genericBloc.addStokvelGoalPayment(goal.stokvelGoalId, res);
      }

      Toast.show('Group Payment Succeeded', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      Navigator.pop(context, res);
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Group Payment failed');
    }

    setState(() {
      isBusy = false;
    });
  }

  void _sendMemberPayment(Member member) async {
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
      var res = await genericBloc.sendMemberToMemberPayment(
          fromMember: me, amount: amountController.text, toMember: member);
      prettyPrint(res.toJson(), "🍎 Member Payment Result 🍎 ");
      Toast.show('Member Payment Succeeded', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context, res);
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Member Payment failed');
    }

    setState(() {
      isBusy = false;
    });
  }

  void _onSwitchChanged(bool value) async {
    if (value == false) {
      _members.clear();
      for (var stokvelId in _member.stokvelIds) {
        var members = await genericBloc.getStokvelMembers(stokvelId);
        members.forEach((m) {
          if (m.memberId == _member.memberId) {
            print('ignore this member: ${m.name} ');
          } else {
            _members.add(m);
          }
        });
      }
      _members.sort((a, b) => a.name.compareTo(b.name));
    }
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
            memberId: _member == null? null:_member.memberId,
            stokvelId: _stokvel == null? null: _stokvel.stokvelId,
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

  void _navigateToGoals() async {
    var result = await Navigator.push(context, SlideRightRoute(
        widget: StokvelGoalList(returnStokvelGoalOnTap: true,)
    ));
    if (result != null) {
      if (result is StokvelGoal) {
          _sendStokkiePayment(result);
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Send Money', style: Styles.whiteSmall,),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
        ],
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Image.asset('assets/logo_white.png', height: 36, width: 36,),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'You can send a payment to the Group that you are a member of and you can send a payment to any of the other members',
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 12,
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
                        style: Styles.whiteSmall,
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
                        isStokvelPayment ? 'Group' : 'Member',
                        style: Styles.blackBoldMedium,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                   TextField(
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
                              onPressed: () {
                                _dismissKeyboard();
                                _startScanToPay();
                              },
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(isStokvelPayment? getStokvelSize(): getMemberSize())),
      ),
//      backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isStokvelPayment ? _buildStokvelList() : _buildMemberList(),
    );
  }

  double getMemberSize() {
    var pixelRatio =MediaQuery.of(context).devicePixelRatio;
    print('👽 👽 👽 👽 pixelRatio: $pixelRatio  🍑 ');
    if (pixelRatio > 2) {
      return 360.0;
    } else {
      return 320;
    }

  }
  double getStokvelSize() {
    var pixelRatio =MediaQuery.of(context).devicePixelRatio;
    print('👽 👽 👽 👽 pixelRatio: $pixelRatio  🍑 ');
    if (pixelRatio > 2) {
      return 320.0;
    } else {
      return 280;
    }

  }

  ListView _buildMemberList() {
    if (_members == null) {
      _members = [];
    }
    return ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _displayMemberPaymentDialog(_members.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(left:12.0, right: 12, top: 4),
              child: Card(
                elevation: 2,
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
            ),
          );
        });
  }

  ListView _buildStokvelList() {
    return ListView.builder(
        itemCount: _stokvels.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _stokvel = _stokvels.elementAt(index);
              _displayStokvelPaymentDialog();
            },
            child: Padding(
              padding: const EdgeInsets.only(left:16.0, right: 16, top: 8),
              child: Card(
                elevation: 2,
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
