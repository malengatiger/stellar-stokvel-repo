import 'package:flutter/material.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';

class Statements extends StatefulWidget {
  @override
  _StatementsState createState() => _StatementsState();
}

class _StatementsState extends State<Statements> {
  var _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {


    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _key,
      appBar: AppBar(
        title: Text('Statements'),
      ),
    );
  }
}
