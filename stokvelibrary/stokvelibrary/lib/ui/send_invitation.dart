import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';

class SendInvitation extends StatefulWidget {
  @override
  _SendInvitationState createState() => _SendInvitationState();
}

class _SendInvitationState extends State<SendInvitation> {
  var _key = GlobalKey<ScaffoldState>();
  GenericBloc _genericBloc;

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
    _genericBloc = Provider.of<GenericBloc>(context);
    return Scaffold(key: _key,
      appBar: AppBar(
        title: Text('Send Invitation'),
      ),
    );
  }
}
