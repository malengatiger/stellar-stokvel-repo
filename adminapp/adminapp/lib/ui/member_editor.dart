import 'package:flutter/material.dart';

class MemberEditor extends StatefulWidget {
  @override
  _MemberEditorState createState() => _MemberEditorState();
}

class _MemberEditorState extends State<MemberEditor> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Member Editor ...'),
      ),
    );
  }
}
