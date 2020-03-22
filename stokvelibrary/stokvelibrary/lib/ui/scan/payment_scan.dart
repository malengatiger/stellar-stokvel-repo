import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/snack.dart';

const SCAN_MEMBER_PAYMENT = 'memberPayment',
    SCAN_STOKVEL_PAYMENT = 'stokvelPayment';

class PaymentScanner extends StatefulWidget {
  final String type, amount;
  final String stokvelId, memberId;
  final PaymentScannerListener scannerListener;

  const PaymentScanner(
      {Key key,
      @required this.type,
      @required this.scannerListener,
      this.memberId,
      this.amount,
      @required this.stokvelId})
      : super(key: key);

  @override
  _PaymentScannerState createState() => _PaymentScannerState();
}

class _PaymentScannerState extends State<PaymentScanner> {
  var barcode = "";
  var newNumber;
  Stokvel _stokvel;
  bool isBusy = false, isStokvelPayment = true;
  var amountController = TextEditingController();
  Member _member;
  @override
  initState() {
    super.initState();
    assert(widget.type != null);
    _listen();
    if (widget.amount != null) {
      amountController.text = widget.amount;
    } else {
      amountController.text = '0.00';
    }
    _setPaymentType();
    _getStokkie();
  }

  void _listen() async {
    genericBloc.memberPaymentStream.listen((List<MemberPayment> payments) {
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
          '🔵 🔵 🔵 Receiving stokvelPayment from stream ... ${payments.length}');
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

  void _setPaymentType() {
    switch (widget.type) {
      case SCAN_MEMBER_PAYMENT:
        isStokvelPayment = false;
        break;
      case SCAN_STOKVEL_PAYMENT:
        isStokvelPayment = true;
        break;
    }
  }

  String _getMessage() {
    switch (widget.type) {
      case SCAN_MEMBER_PAYMENT:
        return 'This payment will be sent to a Member directly';
        break;
      case SCAN_STOKVEL_PAYMENT:
        return 'This payment will be sent to the Stokvel directly';
        break;
    }
    return '';
  }

  void _getStokkie() async {
    _stokvel = await LocalDB.getStokvelById(widget.stokvelId);
    setState(() {});
  }

  var _key = GlobalKey<ScaffoldState>();
  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Member Payment Scan'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(300),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  _getMessage(),
                  style: Styles.whiteSmall,
                ),
                SizedBox(
                  height: 16,
                ),
                _member == null
                    ? Text(
                        _member == null ? 'Member to Pay' : _member.name,
                        style: Styles.whiteBoldMedium,
                      )
                    : Text(
                        _member.name,
                        style: Styles.whiteBoldMedium,
                      ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  style: Styles.blackBoldLarge,
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter Amount',
                    border: OutlineInputBorder(),
                  ),
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
      backgroundColor: Colors.brown[100],
      body: isScanned
          ? Column(
              children: <Widget>[],
            )
          : Center(
              child: Text(
                '${_stokvel == null ? '' : _stokvel.name}',
                style: Styles.greyLabelMedium,
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
          '👌👌👌 stringTitle: $stringTitle 👌👌👌 will print decoded object; widget.type : ${widget.type}');
      var parts = stringTitle.split('@');
      print(parts);

      if (widget.type == SCAN_MEMBER_PAYMENT) {
        try {
          print(
              '🍎 will 🍎 process a MEMBER 🍎 payment here ...................');
          _member = await genericBloc.getMember(parts[0]);
          setState(() {});
          var me = await Prefs.getMember();
          await genericBloc.sendMemberToMemberPayment(
            fromMember: me,
            toMember: _member,
            amount: amountController.text,
          );
          setState(() {});
        } catch (e) {
          print(e);
          AppSnackBar.showErrorSnackBar(
              scaffoldKey: _key, message: 'Unable to scan');
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

abstract class PaymentScannerListener {
  onStokvelPayment(StokvelPayment stokvelPayment);
  omMemberPayment(MemberPayment memberPayment);
  onPaymentError(String message);
}
