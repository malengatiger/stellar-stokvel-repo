import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/functions.dart';

class MemberAccountCard extends StatefulWidget {
  final double height, width;

  const MemberAccountCard({Key key, this.height, this.width}) : super(key: key);

  @override
  _MemberAccountCardState createState() => _MemberAccountCardState();
}

class _MemberAccountCardState extends State<MemberAccountCard> {
  String _seed;
  GenericBloc _genericBloc;
  AccountResponse _accountResponse;
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    _getAccountSeed();
  }

  _getAccountSeed() async {
    setState(() {
      isBusy = true;
    });
    _seed = await Prefs.getMemberSeed();
    _accountResponse = await _genericBloc.getAccount(_seed);

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
        DataCell(Text(getFormattedAmount(a.balance, context), style: Styles.tealBoldMedium,)),
      ]));
    });
    setState(() {
      isBusy = false;
    });
  }

  var _rows = List<DataRow>();
  double _getHeight() {
    if (_accountResponse == null) {
      return 260;
    }
    var height = _accountResponse.balances.length * 160.0;
    height += 100;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    _genericBloc = Provider.of<GenericBloc>(context);
    _accountResponse = _genericBloc.accountResponse;
    return Container(
      height: widget.height == null ? _getHeight() : widget.height,
      width: widget.width == null ? 400 : widget.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isBusy? Center(
            child: CircularProgressIndicator(),
          ):Column(
            children: <Widget>[
              Text(
                _genericBloc.accountResponse == null ? '' : _genericBloc.accountResponse.accountId,
                style: Styles.blackBoldSmall,
              ),
              SizedBox(
                height: 20,
              ),
              DataTable(columns: [
                DataColumn(label: Text('Asset', style: Styles.greyLabelSmall,)),
                DataColumn(label: Text('Amount', style: Styles.greyLabelSmall,))
              ], rows: _rows)
            ],
          ),
        ),
      ),
    );
  }
}
