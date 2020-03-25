import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';

import 'goal_editor.dart';

class StokvelGoalList extends StatefulWidget {
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
        var goals = await genericBloc.getStokvelGoals(stokvelId);
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
        title: Text('Stokvel Goal List', style: Styles.whiteBoldSmall,),
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
                  Text('Stokvel Goals'),
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
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(goal.stokvel.name, style: Styles.greyLabelSmall,)),
                  SizedBox(height: 0,),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(goal.name, style: Styles.blackBoldSmall,)),
                  SizedBox(height: 0,),
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
                      Text('Images & Video:', style: Styles.greyLabelSmall,),
                      SizedBox(width: 8,),
                      Text('${goal.imageUrls.length}', style: Styles.blackBoldSmall,)
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Member Beneficiaries:', style: Styles.greyLabelSmall,),
                      SizedBox(width: 8,),
                      Text('${goal.beneficiaries.length}', style: Styles.blackBoldSmall,)
                    ],
                  ),
                  SizedBox(height: 12,),
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
          );
        }),
      ),
    );
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
/*
ListTile(
//              leading: Icon(Icons.monetization_on, color: getRandomColor(),),
              title: Padding(
                padding: const EdgeInsets.only(top:28.0),
                child: Text(goal.name, style: Styles.blackBoldSmall,),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top:16.0, bottom: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('Target:', style: Styles.greyLabelSmall,),
                    SizedBox(width: 12,),
                    Text(goal.targetDate == null? '': getFormattedDateShort(goal.targetDate, context)),
                    SizedBox(width: 12,),
                    Text(getFormattedAmount(goal.targetAmount, context),style: Styles.blackBoldSmall,)
                  ],
                ),
              ),
            ),
 */
