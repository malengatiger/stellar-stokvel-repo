import 'package:adminapp/ui/welcome.dart';
import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
import 'package:stokvelibrary/ui/account_card.dart';
import 'package:stokvelibrary/ui/member_qrcode.dart';
import 'package:stokvelibrary/ui/members_list.dart';
import 'package:stokvelibrary/ui/nav_bar.dart';
import 'package:stokvelibrary/ui/payment_totals.dart';
import 'package:stokvelibrary/ui/scan/member_scan.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    implements ScannerListener, StokkieDrawerListener {
  Member _member;
  var _key = GlobalKey<ScaffoldState>();
  bool isBusy = false;
  List<Widget> _widgets = [];
  AccountResponse memberResponse;
  List<AccountResponse> stokvelResponses = List();
  List<Member> _members = List();

  @override
  initState() {
    super.initState();
    _listen();
    _getMember();
  }

  void _listen() async {
    print(
        ' 🌽 🌽 🌽 Dashboard: Start listening to FCM payment messages via stream');
    genericBloc.memberPaymentStream.listen((List<MemberPayment> payments) {
      print(
          '🔵 🔵 🔵 Dashboard: Receiving memberPayment from stream ... 🐸 payments in stream: ${payments.length} 🐸');
      //_refreshAccount();
      if (mounted) {
        AppSnackBar.showSnackBar(
            scaffoldKey: _key,
            message: 'Member Payments processed: ${payments.length}',
            textColor: Colors.lightGreen,
            backgroundColor: Colors.black);
      }
    });
    genericBloc.stokvelPaymentStream.listen((List<StokvelPayment> payments) {
      print(
          '🔵 🔵 🔵 Dashboard: Receiving stokvelPayment from stream ... 🐸 payments in stream: ${payments.length} 🐸');
      //_refreshAccount();
      if (mounted) {
        AppSnackBar.showSnackBar(
            scaffoldKey: _key,
            message: 'Stokvel Payments processed: ${payments.length}',
            textColor: Colors.lightBlue,
            backgroundColor: Colors.black);
      }
    });
  }

  _getMember() async {
    _member = await Prefs.getMember();
    _getDashboardWidgets();
    genericBloc.configureFCM();
    setState(() {});
    for (var id in _member.stokvelIds) {
      var members = await ListAPI.getStokvelMembers(id);
      _members.addAll(members);
    }
    print(
        '🍏 🍏 🍏 🍏 Stokvel members, for ever stokvel this member belongs to; 🔴  found on Firestore: ${_members.length}');
  }

  _refreshAccount() async {
    print(
        '🔵 🔵 🔵 Dashboard: _refresh Account from 🍏 Stellar 🍏 ...................');
    var cred = await Prefs.getCredential();
    var seed = makerBloc.getDecryptedSeed(cred);
    memberResponse = await genericBloc.getAccount(seed);
//    await genericBloc.getMemberPayments(_member.memberId);
//    for (var id in _member.stokvelIds) {
//      var ps = await genericBloc.getStokvelPayments(id);
//    }
  }

  _startScanner() async {
    if (_member.stokvelIds.length == 1) {
      Navigator.push(
          context,
          SlideRightRoute(
              widget: MemberScanner(
            stokvelId: _member.stokvelIds.first,
            scannerListener: this,
          )));
    }
  }

  _startQRCode() async {
    Navigator.push(context, SlideRightRoute(widget: MemberQRCode()));
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
          elevation: 0,
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
              onPressed: _startQRCode,
            ),
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: _startScanner,
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
                _startWelcome(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refreshAccount();
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
                        isBusy
                            ? Container(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  backgroundColor: Colors.black,
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          'Administrator',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 40,
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
        backgroundColor: Colors.brown[100],
        bottomNavigationBar: StokkieNavBar(TYPE_ADMIN),
        drawer: StokkieDrawer(
          listener: this,
        ),
        body: isBusy
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: Colors.black,
                ),
              )
            : _member == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: _widgets,
                    ),
                  ),
      ),
    );
  }

  void _getDashboardWidgets() {
    //add account cards
    print(
        '.................  🔴 .... getting dashboard widgets .........................');
    prettyPrint(_member.toJson(), 'MEMBER');
    _widgets.clear();
    _widgets.add(MemberAccountCard(
      memberId: _member.memberId,
    ));
    _widgets.add(SizedBox(
      height: 8,
    ));

    _member.stokvelIds.forEach((stokvelId) {
      _widgets.add(MemberAccountCard(
        stokvelId: stokvelId,
      ));
    });
    _widgets.add(SizedBox(
      height: 8,
    ));
    _widgets.add(Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        'Member Payments',
        style: Styles.greyLabelSmall,
      ),
    ));
    _widgets.add(SizedBox(
      height: 8,
    ));
    _widgets.add(PaymentsTotals(
      memberId: _member.memberId,
    ));
    _widgets.add(SizedBox(
      height: 8,
    ));
    _widgets.add(Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        'Stokvel Payments',
        style: Styles.greyLabelSmall,
      ),
    ));
    _widgets.add(SizedBox(
      height: 8,
    ));
    _member.stokvelIds.forEach((id) {
      _widgets.add(PaymentsTotals(
        stokvelId: id,
      ));
    });
    _widgets.add(SizedBox(
      height: 20,
    ));
    _widgets.add(Text(
      'Stokvel Members',
      style: Styles.greyLabelSmall,
    ));
    _widgets.add(SizedBox(
      height: 8,
    ));

    _widgets.add(MembersList(memberId: _member.memberId));
    _widgets.add(SizedBox(
      height: 20,
    ));
    print(
        '...................  🔴 _getDashboardWidgets: ${_widgets.length} widgets added to dashboard, did refresh happen ????');
    setState(() {});
  }

  void _startWelcome(BuildContext context) {
    Navigator.push(
        context,
        SlideRightRoute(
          widget: Welcome(_member),
        ));
  }

  Future<bool> doNothing() async {
    return false;
  }

  @override
  onMemberScan(Member member) {
    print(
        '🤟🤟🤟 Dashboard: Member scanned and updated on Firestore ...now has  🌶 ${member.stokvelIds.length} stokvels 🌶 ');
    prettyPrint(member.toJson(),
        '🤟🤟🤟 member scanned and updated, check stokvels in member rec');
    _refreshAccount();
  }

  @override
  onMemberAlreadyInStokvel(Member member) {
    print('💦 💦 💦 Dashboard: Member scanned is already a member. they have '
        '🌶 ${member.stokvelIds.length} stokvels 🌶 💦 💦 💦 ');
    prettyPrint(member.toJson(), '💦 💦 💦 member, check data ...');
  }

//drawer

  @override
  onMemberStatementRequested() {
    // TODO: implement onMemberStatementRequested
    return null;
  }

  @override
  onMembershipScannerRequested() {
    _startScanner();
  }

  @override
  onQRCodeRequested() {
    _startQRCode();
  }

  @override
  onRandomThemeRequested() {
    themeBloc.changeToRandomTheme();
  }

  @override
  onRefreshRequested() {
    _refreshAccount();
  }

  @override
  onStokvelAccountRefreshRequested() {
    // TODO: implement onStokvelAccountRefreshRequested
    return null;
  }

  @override
  onStokvelStatementRequested() {
    // TODO: implement onStokvelStatementRequested
    return null;
  }

  @override
  onWelcomeRequested() {
    _startWelcome(context);
  }
}

class StokkieDrawer extends StatelessWidget {
  final StokkieDrawerListener listener;

  const StokkieDrawer({Key key, this.listener}) : super(key: key);
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

abstract class StokkieDrawerListener {
  onQRCodeRequested();
  onMembershipScannerRequested();
  onRandomThemeRequested();
  onWelcomeRequested();
  onRefreshRequested();
  onStokvelAccountRefreshRequested();
  onMemberStatementRequested();
  onStokvelStatementRequested();
}
