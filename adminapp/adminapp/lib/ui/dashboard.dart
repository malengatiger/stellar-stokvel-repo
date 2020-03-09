import 'package:adminapp/bloc/admin_bloc.dart';
import 'package:adminapp/ui/welcome.dart';
import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/theme.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/ui/account_card.dart';
import 'package:provider/provider.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/ui/member_scan.dart';
import 'package:stokvelibrary/ui/nav_bar.dart';


class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();


}

class _DashboardState extends State<Dashboard> implements ScannerListener {
  Member _member;

  @override
  initState() {
    super.initState();
    _getMember();
  }

  _getMember() async {
    _member = await Prefs.getMember();
    setState(() {});
  }

  _refresh() async {
    var seed = await Prefs.getMemberSeed();
    await _genericBloc.getAccount(seed);
  }
  GenericBloc _genericBloc;

  _startScanner() async {

    if (_member.stokvels.length == 1) {
      Navigator.push(context, SlideRightRoute(
        widget: Scanner(stokvel: _member.stokvels.first, scannerListener: this, type: SCAN_MEMBER,)
      ));
    }

  }

  @override
  Widget build(BuildContext context) {
    _genericBloc = Provider.of<GenericBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return doNothing();
      },
      child: Scaffold(
        appBar: AppBar(

          leading: Container(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.perm_contact_calendar),
              onPressed: _startScanner,
            ),
            IconButton(
              icon: Icon(Icons.apps),
              onPressed: () {
                themeBloc.changeToRandomTheme();
              },
            ),
            IconButton(icon: Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(context, SlideRightRoute(
                  widget: Welcome(_member),
                ));
              },),
            IconButton(icon: Icon(Icons.refresh),
              onPressed: () {
               _refresh();
              },),
          ],
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text('Administrator', style: Styles.whiteBoldMedium,),
                        SizedBox(
                          width: 80,
                        ),
                        Text('Stokvels'),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          _member == null ? '0' : '${_member.stokvels.length}',
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
        bottomNavigationBar: StokkieNavBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              MemberAccountCard(),
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
  onMemberScan(Member member) {
    print('🤟🤟🤟 Member scanned and updated on Firestore ...now has  🌶 ${member.stokvels.length} stokvels 🌶 ');
    prettyPrint(member.toJson(), '🤟🤟🤟 member scanned and updated, check stokvels in member rec');
    return null;
  }
}
