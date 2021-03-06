import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:member/bloc/member_bloc.dart';
import 'package:member/ui/dashboard.dart';
import 'package:member/ui/welcome.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/bloc/maker.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/snack.dart';

/// Member SignUp
class MemberSignUp extends StatefulWidget {
  @override
  _MemberSignUpState createState() => _MemberSignUpState();
}

class _MemberSignUpState extends State<MemberSignUp> {
  final _formKey = GlobalKey<FormState>();
  var emailEditor = TextEditingController();
  var passwordEditor = TextEditingController();
  var cellEditor = TextEditingController();
  var nameEditor = TextEditingController();

  var _random = Random(DateTime.now().millisecondsSinceEpoch);

  @override
  @override
  initState() {
    super.initState();
    _setForm();
  }

  _setForm() async {
    //todo - REMOVE after DEVELOPMENT
    emailEditor.text = "member${_random.nextInt(999999)}@stokvel.com";
    passwordEditor.text = "stokkie123";
    nameEditor.text =
        "Member${getFormattedDateHourMinSec(DateTime.now().toIso8601String())}";
    cellEditor.text = "065 591 7675";
  }

  _startGoogleSignUp() async {
    try {
      var member = await Auth.startGoogleSignUp();
      prettyPrint(member.toJson(), 'Member Registered');
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Google Sign Up failed');
    }
  }

  MemberBloc _memberBloc;
  GenericBloc _genericBloc;
  var _key = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          leading: Container(),
          title: Text('Stokkie Member',
              style: TextStyle(
                  fontFamily: GoogleFonts.acme().toString(),
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          backgroundColor: Colors.deepOrange[300],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    SlideRightRoute(
                      widget: Welcome(null),
                    ));
              },
            )
          ],
          bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Are you a new Member? ',
                          style: Styles.whiteBoldSmall,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Switch(
                            value: isNewMember,
                            onChanged: (mVal) {
                              setState(() {
                                isNewMember = mVal;
                              });
                            }),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          isNewMember ? 'YES' : 'NO',
                          style: Styles.blackBoldMedium,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(80)),
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
                            height: 0,
                          ),
                          RaisedButton(
                            color: isNewMember
                                ? Colors.indigo[300]
                                : Colors.brown[300],
                            elevation: 8,
                            onPressed: _startGoogleSignUp,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                isNewMember
                                    ? 'Sign Up with Google'
                                    : 'Sign In with Google',
                                style: Styles.whiteSmall,
                              ),
                            ),
                          ),
                          isNewMember
                              ? SizedBox(
                                  height: 24,
                                )
                              : Container(),
                          isNewMember
                              ? TextFormField(
                                  controller: nameEditor,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    hintText: 'Enter Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter Name';
                                    }
                                    return null;
                                  },
                                )
                              : Container(),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: emailEditor,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter Email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: cellEditor,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Cellphone',
                              hintText: 'Enter Cellphone',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter Cellphone Number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: passwordEditor,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          RaisedButton(
                            color: isNewMember
                                ? Colors.pink[300]
                                : Colors.teal[400],
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
                                isNewMember
                                    ? 'Sign Up to Stokkie'
                                    : 'Log In to Stokkie',
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

  var isBusy = false;
  var isNewMember = true;

  _submit() async {
    _dismissKeyboard();
    setState(() {
      isBusy = true;
    });
    try {
      var member = Member(
        name: nameEditor.text,
        email: emailEditor.text,
        date: DateTime.now().toUtc().toIso8601String(),
        isActive: true,
        stokvelIds: [],
      );
      print('🍏 🍏 🍏 🍏 🍏 🍏 🍏 🍏 🍏 🍏  SignUp: submit and start: makerBloc.createMemberAccount');
      var res = await makerBloc.createMemberAccount(member, passwordEditor.text);
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
