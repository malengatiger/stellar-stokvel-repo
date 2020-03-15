import 'package:flutter/material.dart';
import 'package:member/ui/welcome.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
import 'package:stokvelibrary/ui/account_card.dart';
import 'package:stokvelibrary/ui/member_qrcode.dart';
import 'package:stokvelibrary/ui/nav_bar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> implements MemberDrawerListener {
  Member _member;
  var _key = GlobalKey<ScaffoldState>();
  AccountResponse _accountResponse;
  @override
  initState() {
    super.initState();
    _listen();
    _getMember();
  }

  void _listen() async {
    print(' 🌽 🌽 🌽 Start listening to FCM payment messages via stream');
    genericBloc.memberPaymentStream.listen((List<MemberPayment> payments) {
      print(
          '🔵 🔵 🔵 Dashboard: Receiving memberPayment from stream ... ${payments.length}');
      if (mounted) {
        var mPayment = payments.last;
        AppSnackBar.showSnackBar(
            scaffoldKey: _key,
            message:
                'Member Payment processed ${getFormattedAmount(mPayment.amount, context)}',
            textColor: Colors.lightGreen,
            backgroundColor: Colors.black);
      }
    });
    genericBloc.stokvelPaymentStream.listen((List<StokvelPayment> payments) {
      print(
          '🔵 🔵 🔵 Dashboard: Receiving stokvelPayment from stream ... ${payments.length}');
      if (mounted) {
        var mPayment = payments.last;
        AppSnackBar.showSnackBar(
            scaffoldKey: _key,
            message:
                'Stokvel Payment processed: ${getFormattedAmount(mPayment.amount, context)}',
            textColor: Colors.lightGreen,
            backgroundColor: Colors.black);
      }
    });
  }

  _getMember() async {
    _member = await Prefs.getMember();
    await _refresh();
    genericBloc.configureFCM();
    setState(() {});
  }

  _refresh() async {
    print('🌶  🌶  🌶  🌶  .... Refreshing data ..............');
    var seed = await makerBloc.getDecryptedSeedFromCache();
    if (seed != null) {
      try {
        setState(() {
          isBusy = true;
        });
        _accountResponse = await genericBloc.getAccount(seed);
        _member = await genericBloc.getMember(_member.memberId);
        print(
            '🌶  🌶  🌶  🌶  .... genericBloc.getMember .....memberId: ${_member.memberId}');
      } catch (e) {
        print(e);
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Data refresh failed');
      }
    } else {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Seed not found');
    }
    setState(() {
      isBusy = false;
    });
  }

  _startQRcode() {
    print('starting qr code ....');
    Navigator.push(
        context,
        SlideRightRoute(
          widget: MemberQRCode(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return doNothing();
      },
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              print('💛️ 💛️ .... open drawer ....');
              _key.currentState.openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person),
              onPressed: _startQRcode,
            ),
            IconButton(
              icon: Icon(Icons.apps),
              onPressed: () {
                themeBloc.changeToRandomTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                    context,
                    SlideRightRoute(
                      widget: Welcome(_member),
                    ));
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refresh();
              },
            ),
          ],
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Member',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Text('My Stokvels'),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          _member == null
                              ? '0'
                              : '${_member.stokvelIds.length}',
                          style: Styles.blackBoldLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(80)),
        ),
        drawer: MemberDrawer(
          listener: this,
        ),
        backgroundColor: Colors.brown[100],
        bottomNavigationBar: StokkieNavBar(TYPE_MEMBER),
        body: isBusy
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: _member == null
                    ? Container()
                    : ListView(
                        children: <Widget>[
                          MemberAccountCard(
                            memberId: _member.memberId,
                          ),
                        ],
                      ),
              ),
      ),
    );
  }

  Future<bool> doNothing() async {
    return false;
  }

  @override
  onInvitationsRequested() {
    // TODO: implement onInvitationsRequested
    return null;
  }

  @override
  onMemberStatementRequested() {
    // TODO: implement onMemberStatementRequested
    return null;
  }

  @override
  onMembershipScannerRequested() {
    // TODO: implement onMembershipScannerRequested
    return null;
  }

  @override
  onQRCodeRequested() {
    // TODO: implement onQRCodeRequested
    return null;
  }

  @override
  onRandomThemeRequested() {
    // TODO: implement onRandomThemeRequested
    return null;
  }

  @override
  onRefreshRequested() {
    // TODO: implement onRefreshRequested
    return null;
  }

  @override
  onStokvelStatementRequested() {
    // TODO: implement onStokvelStatementRequested
    return null;
  }

  @override
  onWelcomeRequested() {
    // TODO: implement onWelcomeRequested
    return null;
  }
}

class MemberDrawer extends StatelessWidget {
  final MemberDrawerListener listener;

  const MemberDrawer({Key key, this.listener}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/download3.jpeg"),
                    fit: BoxFit.cover)),
            child: Container(),
          ),
          SizedBox(
            height: 40,
          ),
          GestureDetector(
            onTap: () {
              listener.onStokvelStatementRequested();
            },
            child: ListTile(
              title: Text("Stokvel Statements"),
              leading: Icon(
                Icons.format_list_bulleted,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onMemberStatementRequested();
            },
            child: ListTile(
              title: Text("Member Statements"),
              leading: Icon(
                Icons.format_list_bulleted,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onQRCodeRequested();
            },
            child: ListTile(
              title: Text("Display QR code"),
              leading: Icon(
                Icons.person,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onMembershipScannerRequested();
            },
            child: ListTile(
              title: Text("Scan New Member"),
              leading: Icon(
                Icons.camera,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onWelcomeRequested();
            },
            child: ListTile(
              title: Text("Information"),
              leading: Icon(
                Icons.info_outline,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onRandomThemeRequested();
            },
            child: ListTile(
              title: Text("Change Color Scheme"),
              leading: Icon(
                Icons.apps,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class MemberDrawerListener {
  onQRCodeRequested();
  onMembershipScannerRequested();
  onRandomThemeRequested();
  onWelcomeRequested();
  onRefreshRequested();
  onInvitationsRequested();
  onMemberStatementRequested();
  onStokvelStatementRequested();
}
