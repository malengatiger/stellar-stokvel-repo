import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/functions.dart';

class MemberAccountCard extends StatefulWidget {
  final double height, width;

  const MemberAccountCard({Key key, this.height, this.width}) : super(key: key);

  @override
  _MemberAccountCardState createState() => _MemberAccountCardState();
}

class _MemberAccountCardState extends State<MemberAccountCard> {
  String _seed;
  AccountResponse _accountResponse;
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    _refreshAccount();
  }

  _refreshAccount() async {
    setState(() {
      isBusy = true;
    });
    try {
      _seed = await makerBloc.getDecryptedCredential();
      _accountResponse = await genericBloc.getAccount(_seed);
      _rows.clear();
      _accountResponse.balances.forEach((a) {
        _rows.add(DataRow(cells: [
          DataCell(a.assetType == 'native'
              ? Text(
                  'XLM',
                  style: Styles.greyLabelSmall,
                )
              : Text(
                  a.assetType,
                  style: Styles.blackBoldSmall,
                )),
          DataCell(Text(
            getFormattedAmount(a.balance, context),
            style: Styles.tealBoldMedium,
          )),
        ]));
      });
      setState(() {
        isBusy = false;
      });
    } catch (e) {
      print(e);
    }
  }

  var _rows = List<DataRow>();
  double _getHeight() {
    if (_accountResponse == null) {
      return 280;
    }
    var height = _accountResponse.balances.length * 180.0;
    height += 100;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    if (_accountResponse == null) {
      _refreshAccount();
    }
    return Container(
      height: widget.height == null ? _getHeight() : widget.height,
      width: widget.width == null ? 400 : widget.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isBusy
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: <Widget>[
                    Text(
                      _accountResponse == null
                          ? ''
                          : _accountResponse.accountId,
                      style: Styles.blackBoldSmall,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DataTable(columns: [
                      DataColumn(
                          label: Text(
                        'Asset',
                        style: Styles.greyLabelSmall,
                      )),
                      DataColumn(
                          label: Text(
                        'Amount',
                        style: Styles.greyLabelSmall,
                      ))
                    ], rows: _rows)
                  ],
                ),
        ),
      ),
    );
  }
}
