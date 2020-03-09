import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';

import '../functions.dart';

class MemberQRCode extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return MemberQRCodeState();
  }
}

class MemberQRCodeState extends State<MemberQRCode> {
  Member _member;

  @override
  initState() {
    super.initState();
    _getMember();
  }

  _getMember() async {
    _member = await Prefs.getMember();
    if (_member == null) {
      throw Exception('Member not cached');
    }
    setState(() {

    });
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<bool> doNothing() async {
    return false;
  }

  _confirmCancel() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  print('rethink cancel ... staying put ...');
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
            title: Text('Cancel Invite Request'),
            content: Text('Do you want to cancel this request for invitation?'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    
    String encodedString = '${_member.memberId}@${_member.name}';
    print('String to encode and use to build qrcode: 🍎 $encodedString');
    encodedString = base64.encode(utf8.encode(encodedString));
    return WillPopScope(
      onWillPop: () => doNothing(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Member Invitation'),
            leading: Container(),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _confirmCancel,
              )
            ],
          ),
          body: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 10, top: 20),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(primary: true, children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5),
                      ),
                      Text(
                        'This is an invitation voucher that is used by the Administrator to enable your joining the stokvel',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: QrImage(
                              data: encodedString,
                              size: 260,
                              errorCorrectionLevel: 0,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Stokvel Invitation QR code',
                            style: Styles.blueSmall,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 28.0),
                        child: Text(
                            'Please present this screen to the Stokvel Administrator for the invitation to be confirmed. 🍎 Thanks!',
                            style: Styles.blackBoldSmall),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ]),
                  ),
                ],
              ))),
    );
  }
}
