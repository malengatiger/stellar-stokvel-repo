import 'package:flutter/material.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/ui/member_account_card.dart';
import 'package:stokvelibrary/ui/members_list.dart';
import 'package:stokvelibrary/ui/payment_totals.dart';
import 'package:stokvelibrary/ui/stokvel_account_card.dart';

List<Widget> getDashboardWidgets(Member member) {
  print(
      '.................  🔴 .... getting dashboard widgets .............. member has ${member.stokvelIds} stokvels');
  List<Widget> widgets = [];
  prettyPrint(
      member.toJson(), 'getDashboardWidgets: MEMBER, check stokvels ....');
  widgets.clear();
  widgets.add(MemberAccountCard(
    memberId: member.memberId,
  ));
  widgets.add(SizedBox(
    height: 8,
  ));

  member.stokvelIds.forEach((stokvelId) {
    widgets.add(StokvelAccountCard(
      stokvelId: stokvelId,
    ));
  });
  widgets.add(SizedBox(
    height: 8,
  ));
  //add payment cards
  widgets.add(Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Text(
      'Member Payments',
      style: Styles.greyLabelSmall,
    ),
  ));
  widgets.add(SizedBox(
    height: 8,
  ));
  widgets.add(PaymentsTotals(
    memberId: member.memberId,
  ));
  widgets.add(SizedBox(
    height: 8,
  ));
  widgets.add(Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Text(
      'Stokvel Payments',
      style: Styles.greyLabelSmall,
    ),
  ));
  widgets.add(SizedBox(
    height: 8,
  ));
  member.stokvelIds.forEach((id) {
    widgets.add(PaymentsTotals(
      stokvelId: id,
    ));
  });
  widgets.add(SizedBox(
    height: 20,
  ));
  //add member list card
  widgets.add(Text(
    'Stokvel Members',
    style: Styles.greyLabelSmall,
  ));
  widgets.add(SizedBox(
    height: 8,
  ));

  widgets.add(MembersList(memberId: member.memberId));
  widgets.add(SizedBox(
    height: 20,
  ));
  print(
      '...................  🔴 getDashboardWidgets: ${widgets.length} widgets added to dashboard, did refresh happen ????');
  return widgets;
}