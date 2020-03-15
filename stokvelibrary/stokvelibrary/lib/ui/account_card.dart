import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class MemberAccountCard extends StatefulWidget {
  final String stokvelId, memberId;
  final double height, width;

  const MemberAccountCard(
      {Key key, this.stokvelId, this.memberId, this.height, this.width})
      : super(key: key);

  @override
  _MemberAccountCardState createState() => _MemberAccountCardState();
}

class _MemberAccountCardState extends State<MemberAccountCard> {
  bool isBusy = false;
  AccountResponse _accountResponse;
  Member _member;
  Stokvel _stokvel;
  @override
  void initState() {
    super.initState();
    print(
        '...................  🔴 MemberAccountCard: initStatem getting account .. '
        '🍏 stokvelId: ${widget.stokvelId} memberId: ${widget.memberId}  🔴  🔴 ');
    _getAccount();
  }

  _getAccount() async {
    print(
        '...................  🔴 Getting account for either stokvel or member');
    setState(() {
      isBusy = true;
    });
    try {
      if (widget.stokvelId == null && widget.memberId == null) {
        print('StokvelId and memberId is null, ignoring data refresh');
      }
      if (widget.stokvelId != null) {
        var cred = await ListAPI.getStokvelCredential(widget.stokvelId);
        _stokvel = await ListAPI.getStokvelById(widget.stokvelId);
        var seed = makerBloc.getDecryptedSeed(cred);
        _accountResponse = await genericBloc.getAccount(seed);
      }
      if (widget.memberId != null) {
        var cred = await ListAPI.getMemberCredential(widget.memberId);
        var seed = makerBloc.getDecryptedSeed(cred);
        _accountResponse = await genericBloc.getAccount(seed);
        _member = await Prefs.getMember();
        if (_member.memberId != cred.memberId) {
          _member = null;
        }
      }
      print('...................  🔴 about to build data table ...........');
      if (_accountResponse != null) {
        _buildTable();
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isBusy = false;
    });
  }

  _buildTable() async {
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
//
//  void _refresh() async {
//    setState(() {
//      isBusy = true;
//    });
//    try {
//      var cred = await Prefs.getCredential();
//      var seed = makerBloc.getDecryptedSeed(cred);
//      _accountResponse = await genericBloc.getAccount(seed);
//      _buildTable();
//    } catch (e) {
//      print(e);
//      Toast.show('Data refresh failed', context,
//          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
//    }
//    setState(() {
//      isBusy = false;
//    });
//  }

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
              stream: genericBloc.accountResponseStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _accountResponse = snapshot.data.last;
                }
                return GestureDetector(
                  onTap: _getAccount,
                  child: Card(
//              color: getRandomPastelColor(),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.memberId == null
                                ? 'Stokvel Account'
                                : 'Member Account',
                            style: Styles.greyLabelMedium,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          _getMemberOrStokvel(),
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

  Widget _getMemberOrStokvel() {
    if (widget.stokvelId != null) {
      if (_stokvel != null) {
        return Text(_stokvel.name);
      } else {
        return Text('Stokvel Name Here');
      }
    }
    if (widget.memberId != null) {
      if (_member != null) {
        return Text(_member.name);
      } else {
        return Text('Member Name Here');
      }
    }
    return Text('');
  }
}
