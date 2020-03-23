import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class StokvelAccountCard extends StatefulWidget {
  final String stokvelId;
  final double height, width;
  final bool forceRefresh;

  const StokvelAccountCard(
      {Key key, this.stokvelId, this.height, this.width, this.forceRefresh})
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
    if (widget.forceRefresh) {
      _refresh(widget.forceRefresh);
    } else {
      _getAccount();
    }
  }

  _getAccount() async {
    setState(() {
      isBusy = true;
    });
    try {
      _stokvel = await LocalDB.getStokvelById(widget.stokvelId);
      _accountResponse = await genericBloc.getStokvelAccount(widget.stokvelId);
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

  _refresh(bool forceRefresh) async {
    setState(() {
      isBusy = true;
    });
    try {
      _stokvel = await LocalDB.getStokvelById(widget.stokvelId);
      if (_stokvel == null) {
        _stokvel = await ListAPI.getStokvelById(widget.stokvelId);
      }
      if (forceRefresh) {
        _accountResponse =
        await genericBloc.refreshAccount(stokvelId: widget.stokvelId);
      } else {
        _accountResponse = await genericBloc.getStokvelAccount(_stokvel.stokvelId);
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

  Widget _buildTable() {
    _rows.clear();
    _rows.add(Text('${getFormattedDateShortWithTime(DateTime.now().toIso8601String(), context)}'));
    _rows.add(SizedBox(height: 12,));
    _accountResponse.balances.forEach((balance) {
      _rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Balance', style: Styles.greyLabelSmall,),
          SizedBox(width: 20,),
          Text('${getFormattedAmount(balance.balance, context)}', style: Styles.blackBoldMedium,),
          SizedBox(width: 20,),
          Text(balance.assetType == 'native'? 'XLM': balance.assetType, style: Styles.greyLabelMedium,),
        ],
      ));
    });
    return Container(
      height: _accountResponse.balances.length * 80.0,
      child: Column(
        children: _rows,
      ),
    );
  }

  var _rows = List<Widget>();
  double _getHeight() {
    if (_accountResponse == null) {
      return 280;
    }
    var height = _accountResponse.balances.length * 140.0;
    height += 120;
    return height;
  }

  @override
  Widget build(BuildContext context) {

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
              stream: genericBloc.stokvelAccountResponseStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _accountResponse = snapshot.data.last;
                }
                return GestureDetector(
                  onTap: () {
                    _refresh(true);
                  },
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
                          _buildTable(),
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
