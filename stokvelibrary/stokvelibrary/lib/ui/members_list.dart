import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stokvelibrary/bloc/list_api.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class MembersList extends StatefulWidget {
  final String stokvelId, memberId;

  const MembersList({Key key, this.stokvelId, this.memberId}) : super(key: key);
  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  var _members = List<Member>();
  Member _member;
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    if (widget.stokvelId == null && widget.memberId == null) {
      throw Exception('Both stokvelId and memberId are null. Not good.');
    }
    _refresh();
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      if (widget.stokvelId != null) {
        _members = await ListAPI.getStokvelMembers(widget.stokvelId);
      }
      if (widget.memberId != null) {
        _member = await ListAPI.getMember(widget.memberId);
        _members.clear();
        for (var id in _member.stokvelIds) {
          var mems = await ListAPI.getStokvelMembers(id);
          _members.addAll(mems);
        }
      }
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _members.length * 80.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: _members.length,
            itemBuilder: (context, index) {
              var member = _members.elementAt(index);
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  member.name,
                  style: Styles.blackBoldSmall,
                ),
                subtitle: Text(
                  member.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
