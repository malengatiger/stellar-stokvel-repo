import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';

import 'dashboard.dart';

class StokvelEditor extends StatefulWidget {
  final Member member;
  StokvelEditor({this.member});

  @override
  _StokvelEditorState createState() => _StokvelEditorState();
}

class _StokvelEditorState extends State<StokvelEditor> {
  var emailEditor = TextEditingController();
  var passwordEditor = TextEditingController();
  var cellEditor = TextEditingController();
  var nameEditor = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _key = GlobalKey<ScaffoldState>();
  bool isNewStokvel = true;
  Firestore fs = Firestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Stokvel Editor'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    widget.member == null
                        ? 'No member yet'
                        : widget.member.name,
                    style: Styles.whiteBoldMedium,
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  Text(
                      'Create your stokvel and prepare to recruit your friends and family. You are able to create multiple Stokvels'),
                  SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(220)),
      ),
      backgroundColor: Colors.brown[100],
      body: isBusy
          ? Center(
              child: Container(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  backgroundColor: Colors.indigo,
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: <Widget>[
                        Text(
                          'Enter a great, descriptive name for your stokvel. Express it!',
                          style: Styles.blackMedium,
                        ),
                        SizedBox(
                          height: 24,
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
                              return 'Please enter Stokvel Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        RaisedButton(
                          color: isNewStokvel
                              ? Colors.pink[300]
                              : Colors.teal[400],
                          elevation: 8,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _submit();
                            } else {
                              debugPrint('🍎 🍎 Form validation says No Way!');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              isNewStokvel
                                  ? 'Submit New Stokvel'
                                  : 'Update Stokvel',
                              style: Styles.whiteSmall,
                            ),
                          ),
                        ),
                      ]),
                    )),
              ],
            ),
    );
  }

  _submit() async {
    _dismissKeyboard();
    setState(() {
      isBusy = true;
    });
    try {
      var stokvel = Stokvel(
        name: nameEditor.text,
        isActive: true,
        adminMember: widget.member,
        date: DateTime.now().toUtc().toIso8601String(),
      );
//
//      var res = await makerBloc.createStokvelNewAdmin(
//          stokvel: stokvel, member: widget.member);
//      print(
//          '💛️ 💛️ Stokvel seems to have been created: check stokvelId below');
//      prettyPrint(res.toJson(), '💛️ 💛️ New Stokvel back from AdminBloc');

      Navigator.pop(context);
//      Navigator.pop(context, res);
      Navigator.push(context, SlideRightRoute(widget: Dashboard()));
    } catch (e) {
      print(e);
      debugPrint('👿 👿 👿 👿 Hey Jose, we gotta a problem: $e');
      setState(() {
        isBusy = false;
      });
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: "Sign in failed", actionLabel: "");
    }
  }

  void _dismissKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
