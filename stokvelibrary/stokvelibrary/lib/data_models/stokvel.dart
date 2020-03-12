import 'package:flutter/material.dart';

class Stokvel {
  String name, date, stokvelId, accountId;
  bool isActive;
  Member adminMember;

  Stokvel(
      {this.name, this.stokvelId, this.date, this.adminMember, this.isActive});

  Stokvel.fromJson(Map map) {
    name = map['name'];
    accountId = map['accountId'];
    stokvelId = map['stokvelId'];

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
      'date': date,
      'isActive': isActive,
      'adminMember': adminMember == null ? null : adminMember.toJson(),
    };
    return map;
  }
}

class Member {
  String name, cellphone, email, date, memberId, accountId, url, fcmToken;
  bool isActive;
  List<String> stokvelIds;

  Member(
      {@required this.name,
      @required this.memberId,
      @required this.email,
      @required this.cellphone,
      @required this.date,
      @required this.url,
      @required this.fcmToken,
      @required this.accountId,
      @required this.stokvelIds,
      @required this.isActive});

  Member.fromJson(Map map) {
    name = map['name'];
    url = map['url'];
    fcmToken = map['fcmToken'];
    memberId = map['memberId'];
    accountId = map['accountId'];
    cellphone = map['cellphone'];
    email = map['email'];
    date = map['date'];
    isActive = map['isActive'];

    stokvelIds = [];
    if (map['stokvelIds'] != null) {
      List mm = map['stokvelIds'];
      mm.forEach((m) {
        stokvelIds.add(m as String);
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'url': url,
      'fcmToken': fcmToken,
      'memberId': memberId,
      'accountId': accountId,
      'cellphone': cellphone,
      'email': email,
      'date': date,
      'stokvelIds': stokvelIds == null ? [] : stokvelIds,
      'isActive': isActive,
    };
    return map;
  }
}

class StokvelPayment {
  Member member;
  Stokvel stokvel;
  String amount, date, seed, stellarHash;

  StokvelPayment(
      {@required this.member,
      @required this.amount,
      @required this.date,
      @required this.seed,
      @required this.stellarHash,
      @required this.stokvel});

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
      'member': member == null ? null : member.toJson(),
      'stokvel': stokvel == null ? null : stokvel.toJson(),
    };
    return map;
  }
}

class MemberPayment {
  Member fromMember, toMember;
  String amount, date, seed, stellarHash;

  MemberPayment(
      {@required this.fromMember,
      @required this.toMember,
      @required this.amount,
      @required this.date,
      this.seed,
      this.stellarHash});

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
      'fromMember': fromMember == null ? null : fromMember.toJson(),
      'toMember': toMember == null ? null : toMember.toJson(),
    };
    return map;
  }
}

class Invitation {
  String email, date, cellphone, memberId, message, invitationId;
  Stokvel stokvel;
  Invitation(
      {@required this.email,
      @required this.date,
      @required this.stokvel,
      this.memberId,
      this.cellphone,
      this.invitationId});

  Invitation.fromJson(Map map) {
    email = map['email'];
    date = map['date'];
    invitationId = map['invitationId'];
    message = map['message'];
    cellphone = map['cellphone'];
    memberId = map['memberId'];
    if (map['stokvel'] != null) {
      stokvel = Stokvel.fromJson(map['stokvel']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email,
      'date': date,
      'invitationId': invitationId,
      'cellphone': cellphone,
      'message': message,
      'memberId': memberId,
      'stokvel': stokvel == null ? null : stokvel.toJson(),
    };
    return map;
  }
}

class StokkieCredential {
  String accountId, date, seed, cryptKey, fortunaKey, stokvelId, memberId;
  StokkieCredential({
    @required this.accountId,
    @required this.date,
    @required this.cryptKey,
    @required this.fortunaKey,
    @required this.stokvelId,
    @required this.memberId,
    @required this.seed,
  });

  StokkieCredential.fromJson(Map map) {
    accountId = map['accountId'];
    date = map['date'];
    seed = map['seed'];
    memberId = map['memberId'];
    stokvelId = map['stokvelId'];
    cryptKey = map['cryptKey'];
    fortunaKey = map['fortunaKey'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'accountId': accountId,
      'seed': seed,
      'memberId': memberId,
      'stokvelId': stokvelId,
      'date': date,
      'cryptKey': cryptKey,
      'fortunaKey': fortunaKey,
    };
    return map;
  }
}

class StokkieCredentials {
  List<StokkieCredential> credentials;

  StokkieCredentials(this.credentials);

  StokkieCredentials.fromJson(Map map) {
    credentials = List();
    if (map['credentials'] != null) {
      List mm = map['credentials'];
      mm.forEach((m) {
        credentials.add(StokkieCredential.fromJson(m));
      });
    }
    print('Inside fromJson: 🌼 ${credentials.length}, is this incrementing??');
  }

  Map<String, dynamic> toJson() {
    List mList = [];

    credentials.forEach((c) {
      mList.add(c.toJson());
    });

    Map<String, dynamic> map = {
      'credentials': mList,
    };
    print('Inside toJson: 🌼 ${credentials.length}, is this incrementing??');
    return map;
  }
}

class Stokvels {
  List<Stokvel> stokvels;
  Stokvels(this.stokvels);

  Stokvels.fromJson(Map map) {
    stokvels = List();
    if (map['stokvels'] != null) {
      List mm = map['stokvels'];
      mm.forEach((m) {
        stokvels.add(Stokvel.fromJson(m));
      });
    }
  }
  Map<String, dynamic> toJson() {
    List mList = [];

    stokvels.forEach((c) {
      mList.add(c.toJson());
    });

    Map<String, dynamic> map = {
      'stokvels': mList,
    };
    return map;
  }
}

class Members {
  List<Member> members;
  Members(this.members);

  Members.fromJson(Map map) {
    members = List();
    if (map['members'] != null) {
      List mm = map['members'];
      mm.forEach((m) {
        members.add(Member.fromJson(m));
      });
    }
  }
  Map<String, dynamic> toJson() {
    List mList = [];

    members.forEach((c) {
      mList.add(c.toJson());
    });

    Map<String, dynamic> map = {
      'members': mList,
    };
    return map;
  }
}

class MemberPayments {
  List<MemberPayment> memberPayments;
  MemberPayments(this.memberPayments);

  MemberPayments.fromJson(Map map) {
    memberPayments = List();
    if (map['memberPayments'] != null) {
      List mm = map['memberPayments'];
      mm.forEach((m) {
        memberPayments.add(MemberPayment.fromJson(m));
      });
    }
  }
  Map<String, dynamic> toJson() {
    List mList = [];
    memberPayments.forEach((c) {
      mList.add(c.toJson());
    });

    Map<String, dynamic> map = {
      'memberPayments': mList,
    };
    return map;
  }
}

class StokvelPayments {
  List<StokvelPayment> stokvelPayments;
  StokvelPayments(this.stokvelPayments);

  StokvelPayments.fromJson(Map map) {
    stokvelPayments = List();
    if (map['stokvelPayments'] != null) {
      List mm = map['stokvelPayments'];
      mm.forEach((m) {
        stokvelPayments.add(StokvelPayment.fromJson(m));
      });
    }
  }
  Map<String, dynamic> toJson() {
    List mList = [];
    stokvelPayments.forEach((c) {
      mList.add(c.toJson());
    });

    Map<String, dynamic> map = {
      'stokvelPayments': mList,
    };
    return map;
  }
}
