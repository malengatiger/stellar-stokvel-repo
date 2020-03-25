import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';
import 'package:stokvelibrary/ui/members_list.dart';

class StokvelGoalEditor extends StatefulWidget {
  final StokvelGoal stokvelGoal;

  const StokvelGoalEditor({Key key, this.stokvelGoal}) : super(key: key);
  @override
  _StokvelGoalEditorState createState() => _StokvelGoalEditorState();
}

class _StokvelGoalEditorState extends State<StokvelGoalEditor> {
  var _key = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var _nameEditor = TextEditingController();
  var _amountEditor = TextEditingController();
  var _beneficiaries = List<Member>();
  var _stokvels = List<Stokvel>();
  var _urls = List<String>();
  Member _member;
  Stokvel _stokvel;
  var _memberItems = List<DropdownMenuItem<Member>>();
  var _stokvelItems = List<DropdownMenuItem<Stokvel>>();
  @override
  void initState() {
    super.initState();
    if (widget.stokvelGoal != null) {
      _nameEditor.text = widget.stokvelGoal.name;
      _amountEditor.text = widget.stokvelGoal.targetAmount;
      _targetDate = DateTime.parse(widget.stokvelGoal.targetDate);
      _beneficiaries = widget.stokvelGoal.beneficiaries;
    }
    _getData();
  }

  void _getData() async {
    _member = await genericBloc.getCachedMember();
    var isDevelopment = await genericBloc.isDevelopmentStatus();
    if (isDevelopment) {
      _nameEditor.text =
          'Funding Goal ' + getFormattedDateHour(DateTime.now().toIso8601String());
      _amountEditor.text = '6900.00';
      _targetDate = DateTime.parse('2021-12-31');

    }
    for (var stokvelId in _member.stokvelIds) {
      var stokvel = await genericBloc.getStokvelById(stokvelId);
      if (stokvel != null) {
        setState(() {
          _stokvels.add(stokvel);
        });
      }
      if (_stokvels.isEmpty) {
        throw Exception('No stokvel found on file');
      }
      if (_member.stokvelIds.length == 1) {
        _stokvel = stokvel;
      }
      _buildStokvelItems();
    }
    setState(() {});
  }

  void _buildStokvelItems() {
    _stokvels.forEach((s) {
      _stokvelItems.add(DropdownMenuItem<Stokvel>(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Text(s.name),
          ],
        ),
      ));
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          'Stokvel Goal Editor',
          style: Styles.whiteBoldSmall,
        ),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Create a Stokvel Goal. Goals are used to describe the reason for the collection of funds. ',
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('My Stokvels'),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        '${_stokvels.length}',
                        style: Styles.blackBoldSmall,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      RaisedButton(
                          elevation: 8,
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Pick Images or Video',
                              style: Styles.whiteSmall,
                            ),
                          ),
                          onPressed: _pickOrTakeImage),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Images and Video'),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        '${_urls.length}',
                        style: Styles.whiteBoldSmall,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(240)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 2,
              child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 0,
                      ),
                      SizedBox(
                        height: 0,
                      ),
                      TextFormField(
                        controller: _nameEditor,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Goal Name',
                          hintText: 'Enter Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Goal Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _amountEditor,
                        style: Styles.blackBoldMedium,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Amount',
                          hintText: 'Enter Target Amount',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Target Amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                          onTap: _displayDatePicker,
                          child: Text(
                            _targetDate == null
                                ? 'Select Target Date'
                                : getFormattedDateShort(
                                    _targetDate.toIso8601String(), context),
                            style: Styles.blueBoldSmall,
                          )),
                      SizedBox(
                        height: 24,
                      ),
                      FlatButton(
                        onPressed: _navigateToMembers,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Add Beneficiary Member(s)',
                              style: Styles.blueBoldSmall,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Added:',
                              style: Styles.greyLabelSmall,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${_beneficiaries.length}',
                              style: Styles.blackBoldSmall,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        height: 24,
                      ),
                    ]),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: _benWidgets,
              ),
            ),
            _beneficiaries.isEmpty
                ? Container()
                : _targetDate == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 28.0, right: 28, top: 20, bottom: 20),
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          elevation: 8,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              if (widget.stokvelGoal == null) {
                                _submitNewGoal();
                              } else {
                                _submitUpdate();
                              }
                            } else {
                              debugPrint('🍎 🍎 Form validation says No Way!');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              widget.stokvelGoal == null
                                  ? 'Save Stokvel Goal'
                                  : 'Update Stokvel Goal',
                              style: Styles.whiteSmall,
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  void _navigateToMembers() async {
    var result = await Navigator.push(
        context,
        SlideRightRoute(
            widget: MembersList(
          memberId: _member.memberId,
          returnTappedMember: true,
        )));
    if (result != null) {
      if (result is Member) {
        //todo - check if already in list
        bool isFound = false;
        _beneficiaries.forEach((m) {
          if (m.memberId == result.memberId) {
            isFound = true;
          }
        });
        if (isFound) {
          AppSnackBar.showErrorSnackBar(
              scaffoldKey: _key, message: 'Member is already a beneficiary');
        } else {
          _beneficiaries.add(result);
        }
      }
    }
    _benWidgets.clear();
    if (_beneficiaries.isNotEmpty) {
      _benWidgets.add(SizedBox(
        height: 8,
      ));
      _benWidgets.add(Row(
        children: <Widget>[
          Text(
            '${_beneficiaries.length}',
            style: Styles.blackBoldMedium,
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            'Beneficiaries',
            style: Styles.greyLabelMedium,
          ),
        ],
      ));
    }
    _beneficiaries.forEach((m) {
      _benWidgets.add(Card(
        child: ListTile(
          leading: Icon(
            Icons.person,
            color: getRandomColor(),
          ),
          title: Text(
            m.name,
            style: Styles.blackBoldSmall,
          ),
        ),
      ));
    });
    setState(() {});
  }

  var _benWidgets = List<Widget>();
  DateTime _targetDate;
  void _displayDatePicker() async {
    var firstDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, DateTime.now().hour + 1);
    var year = DateTime.now().year + 1;
    var lastDate = DateTime(year);
    _targetDate = await showDatePicker(
        context: context,
        initialDate: firstDate,
        firstDate: DateTime.now(),
        lastDate: lastDate);
    setState(() {});
  }

  bool isBusy = false;
  void _submitNewGoal() async {
    print('.................. Starting to submit goal .....');
    setState(() {
      isBusy = true;
    });
    try {
      //todo - validate date, amount ...
      var amount = double.parse(_amountEditor.text);
      if (amount == 0.0) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Please enter Target Amount');
        return;
      }
      print('Checking stokvel ....');
      if (_stokvel == null) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Please select Stokvel');
        return;
      }
      var goal = StokvelGoal(
          stokvel: _stokvel,
          beneficiaries: _beneficiaries,
          date: DateTime.now().toUtc().toIso8601String(),
          isActive: true,
          name: _nameEditor.text,
          targetAmount: _amountEditor.text,
          targetDate: _targetDate.toUtc().toIso8601String(),
          imageUrls: [],
          payments: []);
      print('......... Adding stokvel ....');
      var resultGoal = await genericBloc.addStokvelGoal(goal);
      prettyPrint(resultGoal.toJson(),
          '🌈🌈🌈🌈🌈🌈 Result Goal from GenericBloc. added to Firestore 🌈');
      Navigator.pop(context, resultGoal);
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Save Goal failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  void _submitUpdate() {}

  void _pickOrTakeImage() {}

  void _onDropDownChanged(Stokvel stokvel) {
    setState(() {
      _stokvel = stokvel;
    });
  }
}
