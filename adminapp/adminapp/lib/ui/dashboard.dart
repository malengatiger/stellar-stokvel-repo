import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return doNothing();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_member == null ? '' : _member.name,
          style: Styles.whiteBoldSmall,),
          leading: Container(),
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
              preferredSize: Size.fromHeight(60)),
        ),
      ),
    );
  }

  Future<bool> doNothing() async {
    return false;
  }
}
