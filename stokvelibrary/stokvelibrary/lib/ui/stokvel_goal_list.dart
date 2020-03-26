import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
import 'package:stokvelibrary/ui/goal_editor.dart';
import 'package:stokvelibrary/ui/picture_grid.dart';


class StokvelGoalList extends StatefulWidget {
  final bool returnStokvelGoalOnTap;

  const StokvelGoalList({Key key, this.returnStokvelGoalOnTap}) : super(key: key);

  @override
  _StokvelGoalListState createState() => _StokvelGoalListState();
}

class _StokvelGoalListState extends State<StokvelGoalList> {
  var _goals = List<StokvelGoal>();
  var _key = GlobalKey<ScaffoldState>();
  Member _member;

  @override
  void initState() {
    super.initState();

    _getData();
  }
  _getData() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await genericBloc.getCachedMember();
      _goals.clear();
      for (var stokvelId in _member.stokvelIds) {
        var goals = await genericBloc.refreshStokvelGoals(stokvelId);
        _goals.addAll(goals);
      }
      _goals.sort((a,b) => b.targetDate.compareTo(a.targetDate));
    } catch (e) {
      print(e);
      if (mounted) {
        AppSnackBar.showErrorSnackBar(scaffoldKey: _key, message: 'Data refresh failed');
      }
    }

    setState(() {
      isBusy = false;
    });
  }
  bool sortAscending = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _key,
      appBar: AppBar(
        title: Text('Group Goal List', style: Styles.whiteBoldSmall,),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _navigateToEditor),
          IconButton(icon: Icon(Icons.refresh), onPressed: _getData),
        ],
        bottom: PreferredSize(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Group Goals'),
                  SizedBox(width: 12,),
                  Text('${_goals.length}', style: Styles.whiteBoldSmall,),
                  SizedBox(width: 12,),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Sort', style: Styles.blackSmall,),
                  IconButton(icon: Icon(Icons.sort), onPressed: () {
                    if (sortAscending) {
                      setState(() {
                        _goals.sort((a,b) => a.targetDate.compareTo(b.targetDate));
                      });
                    } else {
                      setState(() {
                        _goals.sort((a,b) => b.targetDate.compareTo(a.targetDate));
                      });
                    }
                    sortAscending = !sortAscending;
                  }),
                  SizedBox(width: 60,),
                  Text('My Stokvels'),
                  SizedBox(width: 12,),
                  Text('${_member == null? '0': _member.stokvelIds.length}', style: Styles.blackBoldSmall,),
                  SizedBox(width: 12,),
                ],
              ),
            ],
          ),
        ), preferredSize: Size.fromHeight(100)),
      ),
      body: isBusy? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context,index) {
            var goal = _goals.elementAt(index);
          return GestureDetector(
            onTap: () {
              if (widget.returnStokvelGoalOnTap != null) {
               if (widget.returnStokvelGoalOnTap) {
                 Navigator.pop(context, goal);
               }
              } else {
                Navigator.push(context, SlideRightRoute(
                  widget: GoalDetail(stokvelGoal: goal,),
                ));
              }
            },
            child: Card(
              color: goal.isActive? Colors.white: Colors.grey[200],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(goal.stokvel.name, style: Styles.greyLabelMedium,)),
                    SizedBox(height: 0,),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(goal.name, style: Styles.blackBoldSmall,)),
                    SizedBox(height: 8,),
                    Row(
                      children: <Widget>[
                        Text('Active:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 12,),
                        goal.isActive? Container(
                          height: 8, width: 8,
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle
                          ),
                        ): Container(
                          height: 8, width: 8, color: Colors.pink,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Member Beneficiaries:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 8,),
                        Text('${goal.beneficiaries.length}', style: Styles.blackBoldSmall,)
                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: <Widget>[
                        Text('Images & Video:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 8,),
                        Text('${goal.imageUrls.length}', style: Styles.blackBoldSmall,),
                        SizedBox(width: 20,),
                        goal.imageUrls.isEmpty? Container(): FlatButton(
                          onPressed: () {
                            Navigator.push(context, SlideRightRoute(widget: PictureGrid(stokvelGoal: goal,)));
                          }, child: Text('Show Images', style: Styles.blueBoldSmall,),
                        )
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Text('Contributions:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 8,),
                        Text('${goal.payments.length}', style: Styles.blackBoldSmall,),
                        SizedBox(width: 12,),
                        Text('Total:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 4,),
                        Text('${_getPaymentTotals(goal)}', style: Styles.tealBoldSmall,)
                      ],
                    ),
                    SizedBox(height: 8,),
                    Row(
                      children: <Widget>[
                        Text('Amount To Target:', style: Styles.greyLabelSmall,),
                        SizedBox(width: 8,),
                        Text('${_getAmountToTarget(goal)}', style: Styles.pinkBoldSmall,),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(goal.targetDate == null? '': getFormattedDateShort(goal.targetDate, context), style: Styles.greyLabelSmall,),
                        SizedBox(width: 12,),
                        Text(getFormattedAmount(goal.targetAmount, context),style: Styles.blackBoldSmall,)
                      ],
                    ),
                    SizedBox(height: 12,),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getPaymentTotals(StokvelGoal stokvelGoal) {
    var tot = 0.00;
    stokvelGoal.payments.forEach((p) {
      var amount = double.parse(p.amount);
      tot += amount;
    });
    return getFormattedAmount(tot.toString(), context);
  }
  String _getAmountToTarget(StokvelGoal stokvelGoal) {
    var tot = 0.00;
    stokvelGoal.payments.forEach((p) {
      var amount = double.parse(p.amount);
      tot += amount;
    });
    var toTarget = double.parse(stokvelGoal.targetAmount) - tot;
    return getFormattedAmount(toTarget.toString(), context);
  }
  void _navigateToEditor() async {
    var result = await Navigator.push(context, SlideRightRoute(
      widget: StokvelGoalEditor(),
    ));
    if (result != null) {
      if (result is StokvelGoal) {
        setState(() {
          _goals.insert(0, result);
        });
      }
    }
  }
  void _navigateToUpdateEditor(StokvelGoal goal) {
    Navigator.push(context, SlideRightRoute(
      widget: StokvelGoalEditor(stokvelGoal: goal,),
    ));
  }
}

class GoalDetail extends StatelessWidget {
  final StokvelGoal stokvelGoal;

  const GoalDetail({Key key, this.stokvelGoal}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String _getPaymentTotals(StokvelGoal stokvelGoal) {
      var tot = 0.00;
      stokvelGoal.payments.forEach((p) {
        var amount = double.parse(p.amount);
        tot += amount;
      });
      return getFormattedAmount(tot.toString(), context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Goal Detail', style: Styles.whiteSmall,),
        bottom: PreferredSize(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text('${stokvelGoal.name}', style: Styles.whiteBoldSmall,),
              SizedBox(height: 8,),
              Text('${stokvelGoal.stokvel.name}', style: Styles.whiteSmall,),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Contributions:', style: Styles.whiteSmall,),
                  SizedBox(width: 8,),
                  Text('${stokvelGoal.payments.length}', style: Styles.blackBoldSmall,),
                  SizedBox(width: 12,),
                  Text('Total:', style: Styles.whiteSmall,),
                  SizedBox(width: 8,),
                  Text('${_getPaymentTotals(stokvelGoal)}', style: Styles.blackBoldSmall,),
                  SizedBox(width: 20,),
                ],
              ),
              SizedBox(height: 20,),
            ],
          ),
        ), preferredSize: Size.fromHeight(140)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
            itemCount: stokvelGoal.payments.length,
            itemBuilder: (context, index) {
          var payment = stokvelGoal.payments.elementAt(index);
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${payment.member.name}',
                        style: Styles.greyLabelSmall,
                      ),
                      SizedBox(
                        width: 28,
                      ),
                      Text(
                        '${getFormattedAmount(payment.amount, context)}',
                        style: Styles.blackBoldSmall,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                  Column(
                    children: <Widget>[
//                      Row(
//                        children: <Widget>[
//                          Text('${payment.stokvel.name}', style: Styles.greyLabelSmall,),
//                        ],
//                      ),
//                      SizedBox(width: 20,),
                      Row(
                        children: <Widget>[
                          Icon(Icons.done, color: Colors.teal[700],),
                          SizedBox(width: 12,),
                          Text(getFormattedDateShortWithTime(payment.date, context), style: Styles.greyLabelSmall,),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


