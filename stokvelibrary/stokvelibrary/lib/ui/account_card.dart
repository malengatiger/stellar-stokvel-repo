import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/functions.dart';

class MemberAccountCard extends StatefulWidget {
  final AccountResponse accountResponse;
  final double height, width;

  const MemberAccountCard(
      {Key key, this.accountResponse, this.height, this.width})
      : super(key: key);

  @override
  _MemberAccountCardState createState() => _MemberAccountCardState();
}

class _MemberAccountCardState extends State<MemberAccountCard> {
  bool isBusy = false;
  String _seed;
  AccountResponse _accountResponse;
  @override
  void initState() {
    super.initState();
    _accountResponse = widget.accountResponse;
    _refreshAccount();
  }

  _refreshAccount() async {
    print(
        ' 🔵 🔵 🔵 🔵 _MemberAccountCardState 🔵 🔵 🔵 🔵 🔵 refresh account ...... 🔵 🔵 🔵');
    setState(() {
      isBusy = true;
    });
    try {
      _seed = await makerBloc.getDecryptedSeedFromCache();
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
    } catch (e) {
      print(e);
    }
    setState(() {
      isBusy = false;
    });
  }

  var _rows = List<DataRow>();
  double _getHeight() {
    if (widget.accountResponse == null) {
      return 280;
    }
    var height = widget.accountResponse.balances.length * 180.0;
    height += 100;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height == null ? _getHeight() : widget.height,
      width: widget.width == null ? 400 : widget.width,
      child: StreamBuilder<List<AccountResponse>>(
          stream: genericBloc.accountResponseStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(
                  'data received in 👌🏾👌🏾👌🏾 memberAccountCard build snapshot ...... 👌🏾👌🏾👌🏾');
              _accountResponse = snapshot.data.last;
            }
            return Card(
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
            );
          }),
    );
  }
}
