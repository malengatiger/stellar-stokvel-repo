import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:stokvelibrary/bloc/file_util.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/snack.dart';

class MemberScanner extends StatefulWidget {
  final String stokvelId;
  final ScannerListener scannerListener;

  const MemberScanner({
    Key key,
    @required this.scannerListener,
    @required this.stokvelId,
  }) : super(key: key);

  @override
  _MemberScannerState createState() => _MemberScannerState();
}

class _MemberScannerState extends State<MemberScanner> {
  var barcode = "";
  var newNumber;
  Stokvel _stokvel;
  Member _member;

  @override
  initState() {
    super.initState();
    assert(widget.stokvelId != null);
    _getStokkie();
  }

  void _getStokkie() async {
    if (widget.stokvelId != null) {
      _member = await Prefs.getMember();
    } else {
      _stokvel = await FileUtil.getStokvelById(widget.stokvelId);
    }
    setState(() {});
  }

  var _key = GlobalKey<ScaffoldState>();
  bool isBusy = false, isStokvelPayment = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Member Scan'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(200),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Text(
                  'You can scan QR codes on new and existing members cellphones to invite people to your Stokvel or to process payments between members and the Stokvel',
                  style: Styles.whiteSmall,
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera),
        label: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text("Start Member Scan"),
        ),
        elevation: 16,
        onPressed: _startScan,
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: isScanned
          ? _buildImage()
          : Center(
              child: Text(
                '${_stokvel == null ? '' : _stokvel.name}',
                style: Styles.blackBoldMedium,
              ),
            ),
    );
  }

  bool isScanned = false;
  Future _startScan() async {
    try {
      var barcode = await scanner.scan();
      print('👌👌👌 barcode: $barcode 👌👌👌');
      setState(() => this.barcode = barcode);

      var decoded = base64.decode(barcode);
      String stringTitle = utf8.decode(decoded);
      print(
          '👌👌👌 stringTitle: $stringTitle 👌👌👌 will print decoded object; ');
      var parts = stringTitle.split('@');
      print(parts);

      var member = await genericBloc.getMember(parts[0]);
      if (member != null) {
        if (member.stokvelIds == null) {
          member.stokvelIds = [];
        }
        //check if stokvel already exists
        var isFound = false;
        member.stokvelIds.forEach((m) {
          if (m == widget.stokvelId) {
            isFound = true;
          }
        });
        if (isFound) {
          print(
              '🌶🌶🌶🌶 Scanned member is already good. 🌶 No need to be scanned again!🌶 ');
          AppSnackBar.showErrorSnackBar(
              scaffoldKey: _key,
              message: '🌶 Member is already in the Stokvel');
          widget.scannerListener.onMemberAlreadyInStokvel(member);
          return;
        } else {
          setState(() {
            isBusy = true;
          });
          member.stokvelIds.add(widget.stokvelId);
          await genericBloc.updateMember(member);
          setState(() {
            isBusy = false;
          });
          AppSnackBar.showSnackBar(
              scaffoldKey: _key,
              message: 'Member welcomed to Stokvel',
              textColor: Colors.lightGreen,
              backgroundColor: Colors.black);
          widget.scannerListener.onMemberScan(member);
        }
      }
    } on PlatformException catch (e) {
      print(e);
      cameraError(e);
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      print(e);
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void cameraError(PlatformException e) {
    if (e.code == scanner.CameraAccessDenied) {
      setState(() {
        this.barcode = '✨✨✨ The user did not grant the camera permission! ✨✨✨';
      });
    } else {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  Widget _buildImage() {
    return SizedBox(
      height: 500.0,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 64),
          child: Container(
            child: Column(
              children: <Widget>[
                Text(
                  "Scanned!",
                  style: new TextStyle(
                      fontSize: 45.0, fontWeight: FontWeight.bold),
                ),
                Container(
                    child:
                        Icon(Icons.beenhere, size: 200, color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract class ScannerListener {
  onMemberScan(Member member);
  onMemberAlreadyInStokvel(Member member);
}
