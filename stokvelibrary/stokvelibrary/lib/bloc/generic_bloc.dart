import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_sms/flutter_sms_platform.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/api/db.dart';
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

import 'data_api.dart';
import 'list_api.dart';
import 'maker.dart';

GenericBloc genericBloc = GenericBloc();

class GenericBloc {
  List<Member> _members = List();
  List<Stokvel> _stokvels = List();
  List<StokkieCredential> _creds = [];
  List<MemberPayment> _memberPayments = [];
  List<StokvelPayment> _stokvelPayments = [];
  List<Contact> _contacts = [];

  List<AccountResponse> _memberAccountResponses = List();
  List<AccountResponse> _stokkieAccountResponses = List();
  FirebaseMessaging fcm = FirebaseMessaging();
  StreamController<List<Member>> _memberController =
      StreamController.broadcast();
  StreamController<List<Stokvel>> _stokvelController =
      StreamController.broadcast();
  StreamController<List<StokkieCredential>> _credController =
      StreamController.broadcast();
  StreamController<List<MemberPayment>> _memberPaymentController =
      StreamController.broadcast();
  StreamController<List<StokvelPayment>> _stokvelPaymentController =
      StreamController.broadcast();
  StreamController<List<Contact>> _contactController =
      StreamController.broadcast();
  StreamController<List<AccountResponse>> _memberAccountResponseController =
      StreamController.broadcast();
  StreamController<List<AccountResponse>> _stokkieAccountResponseController =
      StreamController.broadcast();

  Stream<List<Member>> get memberStream => _memberController.stream;
  Stream<List<Stokvel>> get stokvelStream => _stokvelController.stream;
  Stream<List<StokkieCredential>> get credStream => _credController.stream;
  Stream<List<MemberPayment>> get memberPaymentStream =>
      _memberPaymentController.stream;
  Stream<List<StokvelPayment>> get stokvelPaymentStream =>
      _stokvelPaymentController.stream;
  Stream<List<Contact>> get contactStream => _contactController.stream;

  Stream<List<AccountResponse>> get memberAccountResponseStream =>
      _memberAccountResponseController.stream;
  Stream<List<AccountResponse>> get stokvelAccountResponseStream =>
      _stokkieAccountResponseController.stream;

  void close() {
    _memberPaymentController.close();
    _memberController.close();
    _stokvelPaymentController.close();
    _stokvelController.close();
    _credController.close();
    _contactController.close();
    _memberAccountResponseController.close();
    _stokkieAccountResponseController.close();
  }

  Future configureFCM() async {
    print(
        '✳️ ✳️ ✳️ ✳️ GenericBloc:_configureFCM: CONFIGURE FCM: ✳️ ✳️ ✳️ ✳️  ');
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        String messageType = message['data']['type'];
        print(
            "\n\n️♻️♻️♻️️♻️♻️♻️  ✳️ ✳️ ✳️ ✳️ GenericBloc:FCM onMessage messageType: 🍎 $messageType arrived 🍎 \n\n");
        prettyPrint(message,
            '♻️♻️♻️️♻️♻️ ............... message RECEIVED via FCM .............');
        switch (messageType) {
          case 'stokvels':
            print("✳️ ✳️ FCM onMessage messageType: 🍎 STOKVEL arrived 🍎");
            _processStokvels(message);
            break;
          case 'members':
            print("✳️ ✳️ FCM onMessage messageType: 🍎 MEMBER arrived 🍎");
            _processMembers(message);
            break;

          case 'memberPayment':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 MEMBER PAYMENT arrived 🍎");
            _processMemberPayments(message);
            break;
          case 'stokvelPayment':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 STOKVEL PAYMENT arrived 🍎");
            _processStokvelPayments(message);
            break;
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print(
            "️♻️♻️♻️️♻️♻️♻️ onLaunch:  🧩 triggered by FCM message: $message  🧩 ");
      },
      onResume: (Map<String, dynamic> message) async {
        print(
            "️♻️♻️♻️️♻️♻️♻️ App onResume  🧩 triggered by FCM message: $message  🧩 ");
      },
    );
    fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("IosNotificationSettings Settings registered: $settings");
    });
    fcm.getToken().then((String token) {
      assert(token != null);
//      print('♻️♻️♻️️♻️♻️️ GenericBloc:FCM token  ❤️ 🧡 💛️ $token ❤️ 🧡 💛');
    });
    subscribeToFCM();

    return null;
  }

  Future getContacts() async {
    // Get all contacts on device
    ServiceStatus serviceStatus =
        await PermissionHandler().checkServiceStatus(PermissionGroup.contacts);
    int status = serviceStatus.value;
    print('👽 PermissionHandler service status: $status');
    if (status == ServiceStatus.disabled.value) {
      print(
          '👽 PermissionHandler service status is DISABLED .. openAppSettings ...');
      var isOK = await PermissionHandler().openAppSettings();
      print('👽 PermissionHandler openAppSettings returned: 🍯 $isOK');
    }
    await _requestContactsPermission();

    print(
        '👽 PermissionHandler starting 🍯 ContactsService ... getContacts ...');
    Iterable<Contact> contacts = await ContactsService.getContacts();
    print(
        '👽 👽 👽 getContacts found ${contacts.toList().length} contacts on device');
    var mapped = contacts.toList();
    mapped.forEach((m) {
      _contacts.add(m);
    });
    _contactController.sink.add(_contacts);
    return _contacts;
  }

  Future _requestContactsPermission() async {
    print(
        '👽 PermissionHandler service status is enabled. checking permission for contacts ...');
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permissionStatus.value != PermissionStatus.granted.value) {
      print('👽 PermissionHandler permission for contacts to be requested ...');
      var permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.contacts]);
      var mStatus = permissions[PermissionGroup.contacts];
      if (mStatus.value != PermissionStatus.granted.value) {
        throw Exception('Contacts permission denied');
      }
    }
  }

  Future sendInvitationViaEmail({Invitation invitation}) async {
    _setInvitationMessage(invitation);
    final Email email = Email(
      body: invitation.message,
      subject: 'Invitation to ${invitation.stokvel.name}',
      recipients: [invitation.email],
      isHTML: true,
    );
    await FlutterEmailSender.send(email);
    print(
        '💚 💚 sendInvitationViaEmail: email sent to  🥬 ${invitation.email}');
  }

  Future sendInvitationViaSMS({Invitation invitation}) async {
    _setInvitationMessage(invitation);
    var msg = 'Invitation to ${invitation.stokvel.name}';
    var smsPlatform = FlutterSmsPlatform.instance;
    var canSend = await smsPlatform.canSendSMS();
    if (canSend) {
      var res = await smsPlatform
          .sendSMS(message: msg, recipients: [invitation.cellphone]);
      print(res);
      print(
          '💚 💚 sendInvitationViaSMS: sms sent to  🥬 ${invitation.cellphone}');
    } else {
      throw Exception('Unable to send SMS');
    }
  }

  Future sendInvitationToExistingMember({Invitation invitation}) async {
    _setInvitationMessage(invitation);
    await DataAPI.sendInvitation(invitation);
    print(
        '💚 💚 sendInvitationToExistingMember: data will be sent via cloud message to 🍎 ${invitation.memberId}');
    return null;
  }

  Future sendInvitationViaWhatsapp(Invitation invitation) async {
//    _setInvitationMessage(invitation);
//    await FlutterLaunch.launchWathsApp(
//        phone: invitation.cellphone, message: invitation.message);
//    print('💚 💚 sendInvitationViaWhatsapp: whatsapp message sent to 🍊 ${invitation.cellphone}');
    return null;
  }

  void _setInvitationMessage(Invitation invitation) {
    if (invitation.message == null) {
      invitation.message = _buildInvitationHTML(invitation);
    }
  }

  String _buildInvitationHTML(Invitation invitation) {
    //todo - create pretty invitation html .... with good links to app ....
    return '<h1>${invitation.stokvel.name}</h1><p>You are cordially invited to join our stokvel so we can start shit together!</p>';
  }

  Future<File> getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future<bool> isDevelopmentStatus() async {
    await DotEnv().load('.env');
    var status = DotEnv().env['status'];
    if (status == null) {
      status = 'dev';
    }
    if (status == 'prod') {
      return false;
    } else {
      return true;
    }
  }

  Future<AccountResponse> getStokvelAccount(String stokvelId) async {
    var accountResponses = await LocalDB.getStokvelAccountResponses();
    if (accountResponses.isNotEmpty) {
      accountResponses
          .sort((m, n) => n.sequenceNumber.compareTo(m.sequenceNumber));
      _stokkieAccountResponses.add(accountResponses.first);
      _stokkieAccountResponseController.sink.add(_stokkieAccountResponses);
      print(
          '🌈  GenericBloc 🌈   stokvel account response from 🌈 MongoDB cache 🌈  '
          'balances: ${accountResponses.first.balances.length} responses in list: ${_stokkieAccountResponses.length}');
      return accountResponses.first;
    } else {
      return await refreshAccount(stokvelId: stokvelId, memberId: null);
    }
  }

  Future<AccountResponse> getMemberAccount(String memberId) async {
    var accountResponses = await LocalDB.getMemberAccountResponses();
    if (accountResponses.isNotEmpty) {
      accountResponses
          .sort((m, n) => n.sequenceNumber.compareTo(m.sequenceNumber));
      _memberAccountResponses.add(accountResponses.first);
      _memberAccountResponseController.sink.add(_memberAccountResponses);
      print(
          '🌈  GenericBloc 🌈   member account response from 🌈 MongoDB cache 🌈  '
          'balances: ${accountResponses.first.balances.length} responses in list: ${_stokkieAccountResponses.length}');
      return accountResponses.first;
    } else {
      return await refreshAccount(stokvelId: null, memberId: memberId);
    }
  }

  Future<AccountResponse> refreshAccount(
      {String stokvelId, String memberId}) async {
    if (stokvelId != null) {
      var cred = await LocalDB.getStokvelCredential(stokvelId);
      var seed = makerBloc.getDecryptedSeed(cred);
      var accountResponse = await Stellar.getAccount(seed: seed);
      _memberAccountResponses.add(accountResponse);
      _memberAccountResponseController.sink.add(_memberAccountResponses);

      print('🍎 GenericBloc 🍎  account response from 🧡 Stellar Network 🍎 '
          'balances: ${accountResponse.balances.length} responses in list: ${_memberAccountResponses.length}');
      await LocalDB.addStokvelAccountResponse(accountResponse: accountResponse);

      return accountResponse;
    }
    if (memberId != null) {
      var cred = await LocalDB.getMemberCredential(memberId);
      var seed = makerBloc.getDecryptedSeed(cred);
      var accountResponse = await Stellar.getAccount(seed: seed);
      _memberAccountResponses.add(accountResponse);
      _memberAccountResponseController.sink.add(_memberAccountResponses);
      print('🍎 GenericBloc 🍎  account response from 🧡 Stellar Network 🍎 '
          'balances: ${accountResponse.balances.length} responses in list: ${_memberAccountResponses.length}');
      await LocalDB.addMemberAccountResponse(accountResponse: accountResponse);
      return accountResponse;
    }
    return null;
  }

  Future<Member> getMember(String memberId) async {
    var members = await LocalDB.getMembers();
    Member member;
    members.forEach((m) {
      if (m.memberId == memberId) {
        member = m;
      }
    });
    if (member == null) {
      member = await ListAPI.getMember(memberId);
      if (member != null) {
        await LocalDB.addMember(member: member);
      }
    }

    return member;
  }

  Future<List<Member>> getStokvelMembers(String stokvelId) async {
    _members.clear();
    _members = await ListAPI.getStokvelMembers(stokvelId);
    _memberController.sink.add(_members);
    print(' 🔵  🔵 returning members found: ${_members.length}');
    return _members;
  }

  Member _member;

  GenericBloc() {
    print('🅿️ 🅿️  🎽 🎽 🎽 🎽  GenericBloc constructor ... 🅿️ 🅿️ ');
    getCachedMember();
  }

  Future<Member> getCachedMember() async {
    _member = await Prefs.getMember();
    return _member;
  }

  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }

  Future<Member> updateMember(Member member) async {
    return await DataAPI.updateMember(member);
  }

  Future addInvitation(Invitation invite) async {
    return await DataAPI.addInvitation(invite);
  }

  Future<StokvelPayment> sendStokvelPayment(
      {@required Member member,
      @required String amount,
      @required Stokvel stokvel}) async {
    var seed = await makerBloc.getDecryptedSeedFromCache();
    if (seed == null) {
      throw Exception('Seed not found on Firestore, cannot do payment');
    }
    var payment = StokvelPayment(
      member: member,
      amount: amount,
      date: DateTime.now().toUtc().toIso8601String(),
      seed: seed,
      stokvel: stokvel,
      stellarHash: null,
    );
    var res =
        await DataAPI.sendStokvelPaymentToStellar(payment: payment, seed: seed);
    _stokvelPayments.add(res);
    _stokvelPaymentController.add(_stokvelPayments);

    return res;
  }

  Future<MemberPayment> sendMemberToMemberPayment(
      {Member fromMember, Member toMember, String amount}) async {
    var seed = await makerBloc.getDecryptedSeedFromCache();
    if (seed == null) {
      throw Exception('Seed not found, MemberToMemberPayment cannot be made');
    }
    var payment = MemberPayment(
        fromMember: fromMember,
        toMember: toMember,
        amount: amount,
        date: DateTime.now().toUtc().toIso8601String());
    var res =
        await DataAPI.sendMemberPaymentToStellar(payment: payment, seed: seed);
    _memberPayments.add(res);
    _memberPaymentController.sink.add(_memberPayments);

    return res;
  }

  Future<List<StokvelPayment>> getStokvelPayments(String stokvelId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    _stokvelPayments = await LocalDB.getStokvelPayments(stokvelId);
    if (_stokvelPayments.isEmpty) {
      return await refreshStokvelPayments(stokvelId);
    }
    _stokvelPaymentController.sink.add(_stokvelPayments);
    print(
        'GenericBloc:  🌎 🌎 🌎 getStokvelPayments: found ${_stokvelPayments.length}  🔵 🔵 🔵 ');

    return _stokvelPayments;
  }

  Future<List<Stokvel>> getStokvels() async {
    _stokvels = await LocalDB.getStokvels();
    if (_stokvels.isEmpty) {
      return await refreshStokvels();
    }
    _stokvelController.sink.add(_stokvels);
    print(
        'GenericBloc:  🌎 🌎 🌎 getStokvels: found ${_stokvels.length}  🔵 🔵 🔵 ');
    return _stokvels;
  }

  Future<List<Stokvel>> refreshStokvels() async {
    _stokvels = await ListAPI.getStokvels();
    _stokvelController.sink.add(_stokvels);
    for (var stokvel in _stokvels) {
      await LocalDB.addStokvel(stokvel: stokvel);
    }
    print(
        'GenericBloc:  🌎 🌎 🌎 refreshStokvels: found ${_stokvels.length}  🔵 🔵 🔵 ');
    return _stokvels;
  }

  Future<List<StokvelPayment>> refreshStokvelPayments(String stokvelId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    _stokvelPayments = await ListAPI.getStokvelPayments(stokvelId);
    _stokvelPaymentController.sink.add(_stokvelPayments);
    for (var pay in _stokvelPayments) {
      await LocalDB.addStokvelPayment(stokvelPayment: pay);
    }
    print(
        'GenericBloc:  🌎 🌎 🌎 refreshStokvelPayments: found ${_stokvelPayments.length}  🔵 🔵 🔵 ');

    return _stokvelPayments;
  }

  Future<List<MemberPayment>> getMemberPayments(String memberId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    _memberPayments = await LocalDB.getMemberPayments(memberId);
    if (_memberPayments.isEmpty) {
      return await refreshMemberPayments(memberId);
    }
    _memberPaymentController.sink.add(_memberPayments);
    print(
        'GenericBloc:  🔵 🔵 🔵 getMemberPayments, found ${_memberPayments.length}');
    return _memberPayments;
  }

  Future<List<MemberPayment>> refreshMemberPayments(String memberId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    _memberPayments = await ListAPI.getMemberPayments(memberId);
    _memberPaymentController.sink.add(_memberPayments);
    for (var pay in _memberPayments) {
      await LocalDB.addMemberPayment(memberPayment: pay);
    }
    print(
        'GenericBloc:  🌎 🌎 🌎 refreshMemberPayments: found ${_stokvelPayments.length}  🔵 🔵 🔵 ');

    return _memberPayments;
  }

  Future<List<Stokvel>> getStokvelsAdministered(String memberId) async {
    var stokvels = await ListAPI.getStokvelsAdministered(memberId);
    for (var stk in stokvels) {
      await LocalDB.addStokvel(stokvel: stk);
    }
    return stokvels;
  }

  void _processStokvels(Map<String, dynamic> message) {
    print(
        '......................... ️ 🌀 _processStokvels ️ 🌀 ...................................');
    var stokvel = Stokvel.fromJson(message['data']['stokvel']);
    _stokvels.add(stokvel);
    print('♻️ Add received stokvel to stream');
    _stokvelController.sink.add(_stokvels);
    LocalDB.addStokvel(stokvel: stokvel);
  }

  void _processMembers(Map<String, dynamic> message) {
    print(
        '......................... ️ 🌀 _processMembers ️ 🌀 ...................................');
    var member = Member.fromJson(message['data']['member']);
    _members.add(member);
    print('♻️ Add received member to stream');
    _memberController.sink.add(_members);
    LocalDB.addMember(member: member);
  }

  void _processMemberPayments(Map<String, dynamic> message) {
    print(
        '......................... ️ 🌀 _processMemberPayments, something weird going down .... ️ 🌀 ...................................');
    var string = message['data']['memberPayment'];
    if (string == null) {
      throw Exception('message data fucked somehow');
    }
    var mJSON = jsonDecode(string);
    prettyPrint(mJSON, 'MEMBER PAYMENT from FCM');
    try {
      var payment = MemberPayment.fromJson(mJSON);
      _memberPayments.add(payment);
      print('♻️ Add received memberPayment to stream');
      _memberPaymentController.sink.add(_memberPayments);
      LocalDB.addMemberPayment(memberPayment: payment);
      return;
    } catch (e) {
      print('Something is really weird here ...');
      print(e);
    }
  }

  void _processStokvelPayments(Map<String, dynamic> message) {
    print(
        '............................️ 🌀  _processStokvelPayments ️ 🌀 ................................');
    var string = message['data']['stokvelPayment'];
    if (string == null) {
      throw Exception('message data fucked somehow');
    }

    var mJSON = jsonDecode(string);
    prettyPrint(mJSON, 'STOKVEL PAYMENT from FCM');
    try {
      var payment = StokvelPayment.fromJson(mJSON);
      _stokvelPayments.add(payment);
      print('♻️ Add received stokvelPayment to stream');
      _stokvelPaymentController.sink.add(_stokvelPayments);
      LocalDB.addStokvelPayment(stokvelPayment: payment);
    } catch (e) {
      print(e);
    }
  }

  Future subscribeToFCM() async {
    _member = await Prefs.getMember();
    List<String> topics = List();
    topics.add('stokvels');
    _member.stokvelIds.forEach((id) {
      topics.add('members_$id');
      topics.add('memberPayments_$id');
      topics.add('stokvelPayments_$id');
    });

    for (var t in topics) {
      await fcm.subscribeToTopic(t);
      print('GenericBloc: 💜 💜 Subscribed to FCM topic: 🍎  $t  💜 💜 ');
    }
  }
}
