import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/snack.dart';

class MemberAccountCard extends StatefulWidget {
  final String stokvelId, memberId;
  final double height, width;
  final bool forceRefresh;

  const MemberAccountCard(
      {Key key,
      this.stokvelId,
      this.memberId,
      this.height,
      this.width,
      this.forceRefresh})
      : super(key: key);

  @override
  _MemberAccountCardState createState() => _MemberAccountCardState();
}

class _MemberAccountCardState extends State<MemberAccountCard> {
  bool isBusy = false;
  AccountResponse _accountResponse;
  Member _member;

  @override
  void initState() {
    super.initState();
    if (widget.memberId == null) {
      throw Exception('memberId is missing');
    }
    if (widget.forceRefresh) {
      refresh();
    } else {
      _getAccount();
    }
  }

  _getAccount() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await LocalDB.getMember(widget.memberId);
      _accountResponse = await genericBloc.getMemberAccount(widget.memberId);
      if (_accountResponse != null) {
        _buildTable();
      } else {
        print('Account response not found... we have a problem!');
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

  refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await genericBloc.refreshMember(widget.memberId);
      _accountResponse =
          await genericBloc.refreshAccount(memberId: widget.memberId);
      if (_accountResponse != null) {
        _buildTable();
      } else {
        print('Account response not found... we have a problem!');
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
    if (_accountResponse == null) {
      throw Exception('Account Response is null');
    }
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
    setState(() {});
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
                  onTap: refresh,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Member Account',
                            style: Styles.greyLabelMedium,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          _getMember(),
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
                          _buildTable()
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  Widget _getMember() {
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
