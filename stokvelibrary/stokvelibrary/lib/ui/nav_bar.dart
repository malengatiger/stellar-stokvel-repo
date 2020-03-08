import 'package:flutter/material.dart';
import 'package:stokvelibrary/slide_right.dart';
import 'package:stokvelibrary/ui/send_invitation.dart';
import 'package:stokvelibrary/ui/send_money.dart';
import 'package:stokvelibrary/ui/statements.dart';

class StokkieNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _navigate(int index) {
      switch(index) {
        case 0:
          Navigator.push(context, SlideRightRoute(
            widget: SendInvitation(),
          ));
          break;
        case 1:
          Navigator.push(context, SlideRightRoute(
            widget: Statements(),
          ));
          break;
        case 2:
          Navigator.push(context, SlideRightRoute(
            widget: SendMoney(),
          ));
          break;
      }
    }
     final List<BottomNavigationBarItem> _items = List();
     _items.add(BottomNavigationBarItem(icon: Icon(Icons.email), title: Text('Send Invitation')));
     _items.add(BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), title: Text('Statements')));
     _items.add(BottomNavigationBarItem(icon: Icon(Icons.send), title: Text('Send Money')));
    return BottomNavigationBar(items: _items, onTap: _navigate,);
  }
}
