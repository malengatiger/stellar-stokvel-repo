import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

class MembersList extends StatefulWidget {
  final String stokvelId, memberId;
  final bool returnTappedMember;

  const MembersList({Key key, this.stokvelId, this.returnTappedMember, this.memberId}) : super(key: key);
  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  var _memberBags = List<MemberBag>();
  var _widgets = List<Widget>();
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    if (widget.stokvelId == null && widget.memberId == null) {
      throw Exception('Both stokvelId and memberId are null. Not good.');
    }
    _getMembers();
  }

  _getMembers() async {
    setState(() {
      isBusy = true;
    });
    try {
      if (widget.stokvelId != null) {
        var stokvel = await genericBloc.getStokvelById(widget.stokvelId);
        var members = await genericBloc.getStokvelMembers(widget.stokvelId);
        members.forEach((member) {
          _memberBags.add(MemberBag(stokvel.name, member));
        });
      } else {
        if (widget.memberId != null) {
          var member = await genericBloc.getMember(widget.memberId);
          for (var id in member.stokvelIds) {
            var stokvel = await genericBloc.getStokvelById(id);
            var members = await genericBloc.getStokvelMembers(id);
            members.forEach((member) {
              _memberBags.add(MemberBag(stokvel.name, member));
            });
          }
        } else {
          throw Exception('Missing stokvelId or memberId');
        }
      }
      _buildList();
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  _refresh() async {
    setState(() {
      isBusy = true;
    });
    try {
      _memberBags.clear();
      if (widget.stokvelId != null) {
        await _getData(widget.stokvelId);
      } else {
        if (widget.memberId != null) {
          var member = await genericBloc.refreshMember(widget.memberId);
          for (var id in member.stokvelIds) {
            await _getData(id);
          }
        } else {
          throw Exception('Missing stokvelId or memberId');
        }
      }
      print('${_memberBags.length} members found ...');
      _buildList();
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }

  Future _getData(String stokvelId) async {
    var stokvel = await genericBloc.getStokvelById(stokvelId);
    var members = await genericBloc.refreshStokvelMembers(stokvelId);
    members.sort((a, b) => a.name.compareTo(b.name));
    members.forEach((member) {
      _memberBags.add(MemberBag(stokvel.name, member));
    });
  }

  _buildList() {
    _widgets.clear();
    String lastStokvel;
    _memberBags.forEach((m) {
      if (lastStokvel == null) {
        _addTitle(m.stokvelName);
        _addMember(m);
      } else {
        if (lastStokvel != m.stokvelName) {
          _addTitle(m.stokvelName);
          _addMember(m);
        } else {
          _addMember(m);
        }
      }
      lastStokvel = m.stokvelName;
    });
    print('${_widgets.length} Widgets built .... should set state');
  }

  void _addTitle(String stokvelName) {
    _widgets.add(Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 20, bottom: 0),
      child: Text(
        stokvelName,
        style: Styles.greyLabelMedium,
      ),
    ));
    _widgets.add(SizedBox(
      height: 12,
    ));
  }

  void _addMember(MemberBag bag) {
    _widgets.add(GestureDetector(
      onTap: () {
        if (widget.returnTappedMember != null) {
          if (widget.returnTappedMember) {
            Navigator.pop(context, bag.member);
          }
        }

      },
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Icon(
            Icons.person,
            color: getRandomColor(),
          ),
          title: Text(
            bag.member.name,
            style: Styles.blackBoldSmall,
          ),
          subtitle: Text(
            bag.member.email,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Member List',
          style: Styles.whiteBoldSmall,
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('Members'),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '${_memberBags.length}',
                    style: Styles.whiteBoldMedium,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: _widgets,
              ),
            ),
    );
  }
}

class MemberBag {
  final String stokvelName;
  final Member member;

  MemberBag(this.stokvelName, this.member);
}
