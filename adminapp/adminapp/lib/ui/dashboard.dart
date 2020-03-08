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


class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

  AdminBloc _adminBloc;
  GenericBloc _genericBloc;

  @override
  Widget build(BuildContext context) {
    final AdminBloc bloc = Provider.of<AdminBloc>(context);
    _adminBloc = bloc;
    final GenericBloc gBloc = Provider.of<GenericBloc>(context);
    _genericBloc = gBloc;
    return WillPopScope(
      onWillPop: () {
        return doNothing();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_member == null ? '' : _member.name,
          style: Styles.whiteBoldSmall,),
          leading: Container(),
          actions: <Widget>[
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
          ],
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text('Registered Stokvels'),
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
