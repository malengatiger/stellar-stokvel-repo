import 'package:flutter/material.dart';
import 'package:member/ui/welcome.dart';
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

class _DashboardState extends State<Dashboard> {
  Member _member;
  var _key = GlobalKey<ScaffoldState>();
  @override
  initState() {
    super.initState();
    _getMember();
  }

  _getMember() async {
    _member = await Prefs.getMember();
    genericBloc.configureFCM();
    setState(() {});
  }

  _refresh() async {
    print('🌶  🌶  🌶  🌶  .... Refreshing data ..............');
    var seed = await makerBloc.getDecryptedCredential();
    if (seed != null) {
      try {
        setState(() {
          isBusy = true;
        });
        await genericBloc.getAccount(seed);
        _member = await genericBloc.getMember(_member.memberId);
        setState(() {
          setState(() {
            isBusy = false;
          });
        });
      } catch (e) {
        print(e);
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Data refresh failed');
      }
    }
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
          leading: Container(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera),
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
                          style: Styles.whiteBoldMedium,
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
        backgroundColor: Colors.brown[100],
        bottomNavigationBar: StokkieNavBar(TYPE_MEMBER),
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
}
