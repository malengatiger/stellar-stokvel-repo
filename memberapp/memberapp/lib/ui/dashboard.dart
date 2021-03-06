import 'package:flutter/material.dart';
import 'package:member/ui/welcome.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/ui/dash_util.dart';
import 'package:stokvelibrary/ui/member_qrcode.dart';
import 'package:stokvelibrary/ui/member_statement.dart';
import 'package:stokvelibrary/ui/members_list.dart';
import 'package:stokvelibrary/ui/nav_bar.dart';
import 'package:stokvelibrary/ui/scan/member_scan.dart';
import 'package:stokvelibrary/ui/stokvel_goal_list.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> implements MemberDrawerListener {
  Member _member;
  var _key = GlobalKey<ScaffoldState>();
  AccountResponse _accountResponse;
  List<Widget> _widgets = [];
  @override
  initState() {
    super.initState();
    _getMember();
  }

  _getMember() async {
    _member = await Prefs.getMember();
    _member = await genericBloc.getMember(_member.memberId);
    _getDashboardWidgets(true);
    setState(() {});
  }

  _startQRcode() async {
    await Navigator.push(
        context,
        SlideRightRoute(
          widget: MemberQRCode(),
        ));
    setState(() {
      isBusy = true;
    });
    _member = await genericBloc.refreshMember(_member.memberId);
    await genericBloc.refreshStokvels();
    if (_member.stokvelIds.isNotEmpty) {
      await genericBloc.configureFCM();
    }
    _getDashboardWidgets(true);
    setState(() {
      isBusy = false;
    });
  }

  void _getDashboardWidgets(bool forceRefresh) {
    _widgets = getDashboardWidgets(_member, forceRefresh);
    setState(() {});
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
                _getDashboardWidgets(true);
              },
            ),
          ],
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset('assets/logo_white.png', height: 36, width: 36,),
                        SizedBox(width: 12,),
                        Text('The Stokkie Network',style: Styles.whiteBoldSmall,),
                      ],
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Member',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
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
                          style: Styles.blackBoldMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(100)),
        ),
        drawer: MemberDrawer(
          listener: this,
        ),
        bottomNavigationBar: StokkieNavBar(_member == null? null: _member.memberId, TYPE_ADMIN),
        body: isBusy
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: _member == null
                    ? Container()
                    : ListView(
                        children: _widgets,
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
  onMembershipScannerRequested() {

  }

  @override
  onQRCodeRequested() {
    Navigator.pop(context);
    Navigator.push(context, SlideRightRoute(
      widget: MemberQRCode(),
    ));
  }

  @override
  onRandomThemeRequested() {
    themeBloc.changeToRandomTheme();
    Navigator.pop(context);
  }

  @override
  onStatementRequested() {
    Navigator.pop(context);
    Navigator.push(context, SlideRightRoute(
      widget: MemberStatement(_member.memberId),
    ));
  }

  @override
  onWelcomeRequested() {
    Navigator.pop(context);
    Navigator.push(context, SlideRightRoute(
      widget: Welcome(_member),
    ));
  }
  @override
  onStokvelMembersRequested() {
    Navigator.pop(context);
    Navigator.push(context, SlideRightRoute(
      widget: MembersList(memberId: _member.memberId,),
    ));
  }

  @override
  onStokvelGoalsRequested() {
    Navigator.pop(context);
    Navigator.push(context, SlideRightRoute(
      widget: StokvelGoalList(),
    ));
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
                    image: AssetImage("assets/logo.png"),
                    fit: BoxFit.fitHeight)),
            child: Container(),
          ),
          SizedBox(
            height: 40,
          ),
          GestureDetector(
            onTap: () {
              listener.onStokvelGoalsRequested();
            },
            child: ListTile(
              title: Text("Stokvel Goals"),
              leading: Icon(
                Icons.people,
                color: Colors.grey[600],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              listener.onStokvelMembersRequested();
            },
            child: ListTile(
              title: Text("Stokvel Members"),
              leading: Icon(
                Icons.people,
                color: Colors.grey[600],
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              listener.onStatementRequested();
            },
            child: ListTile(
              title: Text("Statements"),
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
  onInvitationsRequested();
  onStatementRequested();
  onStokvelMembersRequested();
  onStokvelGoalsRequested();
}
