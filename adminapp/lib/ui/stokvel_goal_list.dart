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
      _member.stokvelIds.forEach((stokvelId) {
        //todo - get goals ....
      });
    } catch (e) {
      if (mounted) {
        AppSnackBar.showErrorSnackBar(scaffoldKey: _key, message: 'Data refresh failed');
      }
    }

    setState(() {
      isBusy = false;
    });
  }
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
                  Text('My Stokvels'),
                  SizedBox(width: 12,),
                  Text('${_member == null? '0': _member.stokvelIds.length}', style: Styles.whiteBoldMedium,),
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
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context,index) {
            var goal = _goals.elementAt(index);
          return Card(
            child: ListTile(
              leading: Icon(Icons.description, color: getRandomColor(),),
              title: Text(goal.name),
              subtitle: Text(goal.description == null? '': goal.description),
            ),
          );
        }),
      ),
    );
  }

  void _navigateToEditor() {
    Navigator.push(context, SlideRightRoute(
      widget: StokvelGoalEditor(),
    ));
  }
  void _navigateToUpdateEditor(StokvelGoal goal) {
    Navigator.push(context, SlideRightRoute(
      widget: StokvelGoalEditor(stokvelGoal: goal,),
    ));
  }
}
