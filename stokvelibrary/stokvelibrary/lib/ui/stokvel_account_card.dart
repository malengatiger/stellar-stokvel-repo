import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class StokvelAccountCard extends StatefulWidget {
  final String stokvelId;
  final double height, width;

  const StokvelAccountCard({Key key, this.stokvelId, this.height, this.width})
      : super(key: key);

  @override
  _StokvelAccountCardState createState() => _StokvelAccountCardState();
}

class _StokvelAccountCardState extends State<StokvelAccountCard> {
  bool isBusy = false;
  AccountResponse _accountResponse;
  Stokvel _stokvel;
  @override
  void initState() {
    super.initState();
    if (widget.stokvelId == null) {
      throw Exception('Both stokvelId is missing');
    }
    _getAccount();
  }

  _getAccount() async {
    print(
        'StokvelAccountCard:_getAccount: ...................  🔴 about to build data table ...........');
    setState(() {
      isBusy = true;
    });
    try {
      _stokvel = await LocalDB.getStokvelById(widget.stokvelId);
      _accountResponse = await genericBloc.getStokvelAccount(widget.stokvelId);
      print('.................. are we there yet? ...........................');
      if (_accountResponse != null) {
        _buildTable();
      }
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  _buildTable() {
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
    setState(() {});
    return null;
  }

  var _rows = List<DataRow>();
  double _getHeight() {
    if (_accountResponse == null) {
      return 280;
    }
    var height = _accountResponse.balances.length * 180.0;
    height += 120;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    if (_accountResponse != null) {
      _buildTable();
    }
    return Container(
      height: widget.height == null ? _getHeight() : widget.height,
      width: widget.width == null ? 400 : widget.width,
      child: isBusy
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          : StreamBuilder<List<AccountResponse>>(
              stream: genericBloc.memberAccountResponseStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _accountResponse = snapshot.data.last;
                }
                return GestureDetector(
                  onTap: _getAccount,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Stokvel Account',
                            style: Styles.greyLabelMedium,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          _getStokvel(),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40),
                            child: Text(
                              _accountResponse == null
                                  ? ''
                                  : _accountResponse.accountId,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold),
                            ),
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
              }),
    );
  }

  Widget _getStokvel() {
    if (_stokvel != null) {
      return Text(_stokvel.name);
    } else {
      return Text('Stokvel Name Here');
    }
  }
}
