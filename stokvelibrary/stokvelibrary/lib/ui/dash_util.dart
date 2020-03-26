import 'package:flutter/material.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';
import 'package:stokvelibrary/ui/member_account_card.dart';
import 'package:stokvelibrary/ui/members_list.dart';
import 'package:stokvelibrary/ui/payment_totals.dart';
import 'package:stokvelibrary/ui/stokvel_account_card.dart';

List<Widget> getDashboardWidgets(Member member, bool forceRefresh) {
  List<Widget> widgets = [];
  widgets.clear();
  widgets.add(MemberAccountCard(
    memberId: member.memberId,
    forceRefresh: forceRefresh,
  ));
  widgets.add(SizedBox(
    height: 8,
  ));

  member.stokvelIds.forEach((stokvelId) {
    widgets.add(StokvelAccountCard(
      stokvelId: stokvelId,
      forceRefresh: forceRefresh,
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
  widgets.add(MemberPaymentsTotals(
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
    widgets.add(StokvelPaymentsTotals(
      stokvelId: id,
    ));
  });
  widgets.add(SizedBox(
    height: 20,
  ));

  return widgets;
}
