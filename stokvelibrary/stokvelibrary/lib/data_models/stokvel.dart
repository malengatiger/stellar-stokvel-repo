
import 'package:flutter/material.dart';

class Stokvel {
  String name, cellphone, email, date, stokvelId, accountId;
  bool isActive;
  Member adminMember;

  Stokvel(
      {this.name,
        this.stokvelId,
        this.email,
        this.cellphone,
        this.date, this.adminMember,
        this.isActive});

  Stokvel.fromJson(Map map) {
    name = map['name'];
    accountId = map['accountId'];
    stokvelId = map['stokvelId'];
    cellphone = map['cellphone'];
    email = map['email'];
    date = map['date'];
    isActive = map['isActive'];
    if (map['adminMember'] != null) {
      adminMember = Member.fromJson(map['adminMember']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'accountId': accountId,
      'stokvelId': stokvelId,
      'cellphone': cellphone,
      'email': email,
      'date': date,
      'isActive': isActive,
      'adminMember': adminMember == null? null: adminMember.toJson(),
    };
    return map;
  }
}
class Member {
  String name, cellphone, email, date, memberId, accountId, url;
  bool isActive;
  List<Stokvel> stokvels;

  Member(
      {this.name,
        this.memberId,
        this.email,
        this.cellphone,
        this.date, this.url,
        this.stokvels, this.accountId,
        this.isActive});

  Member.fromJson(Map map) {
    name = map['name'];
    url = map['url'];
    memberId = map['memberId'];
    accountId = map['accountId'];
    cellphone = map['cellphone'];
    email = map['email'];
    date = map['date'];
    isActive = map['isActive'];
    stokvels = List();
    if (map['stokvels'] != null) {
      List mm = map['stokvels'];
      mm.forEach((m) {
        stokvels.add(Stokvel.fromJson(m));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var stokvelsJson = List();
    stokvels.forEach((s) {
      stokvelsJson.add(s.toJson());
    });
    Map<String, dynamic> map = {
      'name': name,
      'url': url,
      'memberId': memberId,
      'accountId': accountId,
      'cellphone': cellphone,
      'email': email,
      'date': date,
      'stokvels': stokvelsJson,
      'isActive': isActive,
    };
    return map;
  }
}
class StokvelPayment {
   Member member;
   Stokvel stokvel;
   String amount, date, seed, stellarHash;
   
  StokvelPayment({this.member, this.amount, this.date, this.seed, this.stellarHash, this.stokvel});

  StokvelPayment.fromJson(Map map) {
    amount = map['amount'];
    date = map['date'];
    seed = map['seed'];
    stellarHash = map['stellarHash'];

    if (map['member'] != null) {
      member = Member.fromJson(map['member']);
    }
    if (map['stokvel'] != null) {
      stokvel = Stokvel.fromJson(map['stokvel']);
    }
  }

  Map<String, dynamic> toJson() {
    
    Map<String, dynamic> map = {
      'amount': amount,
      'seed': seed,
      'stellarHash': stellarHash,
      'date': date,
      'member': member == null? null: member.toJson(),
      'stokvel': stokvel == null? null: stokvel.toJson(),
    };
    return map;
  }

}
class MemberPayment {
  Member fromMember, toMember;
  String amount, date, seed, stellarHash;

  MemberPayment({@required this.fromMember, @required this.toMember, @required this.amount, @required this.date, this.seed, this.stellarHash});

  MemberPayment.fromJson(Map map) {
    amount = map['amount'];
    date = map['date'];
    seed = map['seed'];
    stellarHash = map['stellarHash'];

    if (map['fromMember'] != null) {
      fromMember = Member.fromJson(map['fromMember']);
    }
    if (map['toMember'] != null) {
      toMember = Member.fromJson(map['toMember']);
    }
  }

  Map<String, dynamic> toJson() {

    Map<String, dynamic> map = {
      'amount': amount,
      'seed': seed,
      'stellarHash': stellarHash,
      'date': date,
      'fromMember': fromMember == null? null: fromMember.toJson(),
      'toMember': toMember == null? null: toMember.toJson(),
    };
    return map;
  }

}
