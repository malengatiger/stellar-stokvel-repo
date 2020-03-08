import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokvelibrary/bloc/generic_bloc.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/snack.dart';

import 'contact_card.dart';

class SendInvitation extends StatefulWidget {
  @override
  _SendInvitationState createState() => _SendInvitationState();
}

class _SendInvitationState extends State<SendInvitation> {
  var _key = GlobalKey<ScaffoldState>();
  GenericBloc _genericBloc = GenericBloc();
  List<Contact> _contacts = List();
  List<Stokvel> _stokvels = [];
  bool isBusy = false;
  Member _member;

  String filter;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      isBusy = true;
    });
    try {
      _member = await _genericBloc.getCachedMember();
      _contacts = await _genericBloc.getContacts();
      print('🥦🥦🥦🥦🥦 ${_contacts.length} contacts returned to UI');
      _stokvels = await _genericBloc.getStokvelsAdministered(_member.memberId);
      print('🥦🥦🥦🥦🥦 ${_stokvels.length} stokvels returned to UI');
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Contacts failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  bool sendByWhatsapp = false;
  var emailEditor = TextEditingController();
  var cellEditor = TextEditingController();
  Contact selectedContact;
  Stokvel selectedStokvel;
  List<Contact> filteredContacts = [];

  Widget _getDropDownOrText() {
    if (_stokvels.length == 1) {
      selectedStokvel = _stokvels.elementAt(0);
      return Text(
        selectedStokvel.name,
        style: Styles.blackBoldMedium,
      );
    } else {
      List<DropdownMenuItem<Stokvel>> items = [];
      _stokvels.forEach((s) {
        items.add(DropdownMenuItem(child: Text(s.name)));
      });
      return DropdownButton<Stokvel>(
          items: items, onChanged: _onDropDownChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    _genericBloc = Provider.of<GenericBloc>(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Send Invitation'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(300),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Invite your friends and famility to participate in one or more of your administered stokvels',
                  style: Styles.whiteSmall,
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: <Widget>[
                    Text('Invite People Using: '),
                    SizedBox(
                      width: 12,
                    ),
                    Switch(
                      value: sendByWhatsapp,
                      onChanged: onSwitchChanged,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      sendByWhatsapp ? 'Whatsapp' : 'eMail',
                      style: Styles.whiteBoldMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                _stokvels.isEmpty ? Container() : _getDropDownOrText(),
                SizedBox(
                  height: 12,
                ),
                isBusy
                    ? Container()
                    : TextField(
                        style: Styles.blackMedium,
                        decoration: InputDecoration(
                            suffix: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.pink,
                              ),
                              onPressed: _dismissKeyboard,
                            ),
                            hintText: '  Find Contact '),
                        onChanged: (val) {
                          filter = val;
                          _filterContacts();
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      body: isBusy
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _submitInvitation(
                            contact: filteredContacts.elementAt(index));
                      },
                      child: Card(
                        color: getRandomPastelColor(),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                              filteredContacts.elementAt(index).displayName),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }

  void _submitInvitation({Contact contact, String email}) async {
    if (selectedStokvel == null) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Please select Stokvel');
      return;
    }
    if (email == null) {
      var emails = contact.emails.toList();
      if (emails.isEmpty) {
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Contact has no email address');
        _displayEmailDialog(contact);
        return;
      } else {
        email = emails.elementAt(0).value;
      }
    }

    print(
        '🌽 🌽 🌽 Creating invite prior to sending .... 🔵 ${contact.displayName} email: 🔵 $email');
    var invite = Invitation(
        email: email,
        date: DateTime.now().toUtc().toIso8601String(),
        stokvel: selectedStokvel);
    if (sendByWhatsapp) {
      AppSnackBar.showErrorSnackBar(
          scaffoldKey: _key, message: 'Whatsapp feature under construction');
      return;
    } else {
      setState(() {
        isBusy = true;
      });
      try {
        var res = await _genericBloc.sendInvitationViaEmail(invitation: invite);
        print(res);
      } catch (e) {
        print(e);
        AppSnackBar.showErrorSnackBar(
            scaffoldKey: _key, message: 'Invitation failed');
        return;
      }
      setState(() {
        isBusy = false;
      });
    }
  }

  void _displayEmailDialog(Contact contact) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Enter eMail Address",
                  style: Styles.blackBoldMedium),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'eMail Address',
                        hintText: 'Enter invitee eMail address here',
                      ),
                      onChanged: _onTextChanged,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                RaisedButton(
                  child: Text(
                    'Use SMS',
                    style: Styles.whiteSmall,
                  ),
                  onPressed: () {
                    _sendViaSMS(contact);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_controller.text.isEmpty) {
                        AppSnackBar.showErrorSnackBar(
                            scaffoldKey: _key,
                            message:
                                'No email found, invitation cannot be sent');
                        return;
                      }
                      _dismissKeyboard();
                      Navigator.pop(context);
                      _submitInvitation(
                          contact: contact, email: _controller.text);
                    },
                    elevation: 4.0,
                    color: Colors.pink.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Send Invitation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Future<void> _sendViaSMS(Contact contact) async {
    _dismissKeyboard();
    Navigator.pop(context);
    setState(() {
      isBusy = true;
    });
    var invite = Invitation(
        cellphone: contact.phones.toList().elementAt(0).value,
        date: DateTime.now().toUtc().toIso8601String(),
        stokvel: selectedStokvel, email: null);
    try {
      await _genericBloc.sendInvitationViaSMS(invitation: invite);
      print('Looks like we good with the SMS');
    } catch (e) {
      print(e);
      AppSnackBar.showErrorSnackBar(scaffoldKey: _key, message: 'SMS send failed');
    }
    setState(() {
      isBusy = false;
    });
  }

  void _filterContacts() {
    if (filter.isEmpty) {
      setState(() {
        filteredContacts.clear();
      });
      return;
    }
    debugPrint('🔵 filter contacts here ... from ${_contacts.length}');
    filteredContacts.clear();
    _contacts.forEach((v) {
      if (v.displayName.toLowerCase().contains(filter)) {
        filteredContacts.add(v);
      }
    });
    filteredContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    debugPrint('🍎 🍎 🍎 filtered contacts: ${filteredContacts.length}');
    setState(() {});
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void onSwitchChanged(bool value) {
    setState(() {
      sendByWhatsapp = value;
    });
  }

  void _onDropDownChanged(Stokvel value) {
    selectedStokvel = value;
    print('Stokvel selected : ${selectedStokvel.name}');
  }

  void _onTextChanged(String value) {
    print('🧩 $value');
  }
}
