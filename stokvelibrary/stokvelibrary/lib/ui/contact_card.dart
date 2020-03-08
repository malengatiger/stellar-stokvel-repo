import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  const ContactCard({Key key, this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var email = contact.emails.isEmpty? '': contact.emails.elementAt(0);
    var cellphone = contact.phones.isEmpty? '': contact.phones.elementAt(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            CircularProfileAvatar('',
              borderColor: Colors.purpleAccent,
              borderWidth: 5,
              elevation: 2,
              radius: 50,
              child: FlutterLogo(),
            ),
            SizedBox(width: 4,),
            ListTile(
              title: Text('${contact.displayName}'),
              subtitle: Row(
                children: <Widget>[
                  Text(cellphone.toString()),
                  SizedBox(width: 8,),
                  Text(email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
