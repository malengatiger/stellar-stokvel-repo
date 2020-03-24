import 'package:flutter/material.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class StokvelGoalEditor extends StatefulWidget {
  final StokvelGoal stokvelGoal;

  const StokvelGoalEditor({Key key, this.stokvelGoal}) : super(key: key);
  @override
  _StokvelGoalEditorState createState() => _StokvelGoalEditorState();
}

class _StokvelGoalEditorState extends State<StokvelGoalEditor> {
  var _key = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var nameEditor = TextEditingController();
  var descEditor = TextEditingController();
  var _members = List<Member>();
  var _stokvels = List<Stokvel>();
  Member _beneficiary;
  Stokvel _stokvel;
  var _memberItems = List<DropdownMenuItem<Member>>();
  var _stokvelItems = List<DropdownMenuItem<Member>>();
  @override
  void initState() {
    super.initState();
    if (widget.stokvelGoal != null) {
      nameEditor.text = widget.stokvelGoal.name;
      descEditor.text = widget.stokvelGoal.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Stokvel Goal Editor'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Create a Stokvel Goal. Goals are used to describe the reason for the collection of funds. '
                    'A member or the stokvel itself would be the beneficiary of the collected funds',
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 40,
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
                    height: 20,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(280)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: <Widget>[
                    SizedBox(
                      height: 0,
                    ),
                    TextFormField(
                      controller: nameEditor,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                      controller: descEditor,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter Goal description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: _displayDatePicker,
                        child: Text(_selectedDate == null
                            ? 'Select Target Date'
                            : getFormattedDateShortWithTime(
                                _selectedDate.toIso8601String(), context), style: Styles.blueBoldSmall,)),
                    SizedBox(
                      height: 24,
                    ),
                    RaisedButton(
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
                  ]),
                )),
          ],
        ),
      ),
    );
  }

  DateTime _selectedDate;
  void _displayDatePicker() async {
    var firstDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1);
    var year = DateTime.now().year + 1;
    var lastDate = DateTime(year);
    _selectedDate = await showDatePicker(
        context: context,
        initialDate: firstDate,
        firstDate: DateTime.now(),
        lastDate: lastDate);
  }

  bool isBusy = false;
  void _submitNewGoal() {}
  void _submitUpdate() {}

  void _pickOrTakeImage() {}
}
