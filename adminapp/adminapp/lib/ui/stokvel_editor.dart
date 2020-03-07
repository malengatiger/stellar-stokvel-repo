import 'package:adminapp/bloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:provider/provider.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';

import 'dashboard.dart';


class StokvelEditor extends StatefulWidget {
  @override
  _StokvelEditorState createState() => _StokvelEditorState();
}

class _StokvelEditorState extends State<StokvelEditor> {
  var emailEditor = TextEditingController();
  var passwordEditor = TextEditingController();
  var cellEditor = TextEditingController();
  var nameEditor = TextEditingController();
  Member _member;
  var _formKey = GlobalKey<FormState>();
  var _key = GlobalKey<ScaffoldState>();
  bool isNewStokvel = true;
  @override
  void initState() {
    super.initState();
    _getMember();
  }
 _getMember() async {
    _member = await Prefs.getMember();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    final AdminBloc bloc = Provider.of<AdminBloc>(context);
    _adminBloc = bloc;
    return  Scaffold(key: _key,
      appBar: AppBar(
        title: Text('Stokvel Editor'),
        bottom: PreferredSize(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(_member == null? 'No member yet': _member.name, style: Styles.whiteBoldMedium,),
              SizedBox(height: 8,),
              Text('Create your stokvel and prepare to recruit your friends and family. You are able to create multiple Stokvels'),
              SizedBox(height: 24,),
            ],
          ),
        ), preferredSize: Size.fromHeight(140)),
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
                    color: isNewStokvel? Colors.pink[300] : Colors.teal[400],
                    elevation: 8,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _submit();
                      } else {
                        debugPrint(
                            '🍎 🍎 Form validation says No Way!');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        isNewStokvel? 'Submit New Stokvel' : 'Update Stokvel',
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

  AdminBloc _adminBloc;
  _submit() async {
    _dismissKeyboard();
    setState(() {
      isBusy = true;
    });
    try {
      var stokvel = Stokvel(
        name: nameEditor.text,
        isActive: true,
        adminMember: _member,
        date: DateTime.now().toUtc().toIso8601String(),
      );

      var res = await _adminBloc.createStokvel(stokvel);

      Navigator.pop(context, res);
      Navigator.pop(context, res);
      Navigator.push(context, SlideRightRoute(widget: Dashboard()));
    } catch (e) {
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
