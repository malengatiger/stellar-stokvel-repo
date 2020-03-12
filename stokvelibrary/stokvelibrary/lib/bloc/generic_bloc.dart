import 'dart:async';
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
import 'package:stokvelibrary/bloc/auth.dart';
import 'package:stokvelibrary/bloc/data_api.dart';
import 'package:stokvelibrary/bloc/file_util.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:stokvelibrary/functions.dart';

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

  List<AccountResponse> _accountResponses = List();
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
  StreamController<List<AccountResponse>> _accountResponseController =
      StreamController.broadcast();
  StreamController<List<AccountResponse>> _stokkieAccountResponseController =
      StreamController.broadcast();

  Stream<List<Member>> get memberStream => _memberController.stream;
  Stream<List<Stokvel>> get stokvelStream => _stokvelController.stream;
  Stream<List<StokkieCredential>> get credStream => _credController.stream;
  Stream<List<MemberPayment>> get memberPaymentStream =>
      _memberPaymentController.stream;
  Stream<List<Contact>> get contactStream => _contactController.stream;
  Stream<List<AccountResponse>> get accountResponseStream =>
      _accountResponseController.stream;

  void close() {
    _memberPaymentController.close();
    _memberController.close();
    _stokvelPaymentController.close();
    _stokvelController.close();
    _credController.close();
    _contactController.close();
    _accountResponseController.close();
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
        prettyPrint(message, '♻️♻️♻️️♻️♻️ message RECEIVED via FCM');
        switch (messageType) {
          case 'stokvels':
            print("✳️ ✳️ FCM onMessage messageType: 🍎 STOKVELS arrived 🍎");
            _processStokvels(message);
            break;
          case 'members':
            print("✳️ ✳️ FCM onMessage messageType: 🍎 MEMBERS arrived 🍎");
            _processMembers(message);
            break;

          case 'memberPayments':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 MEMBER PAYMENTS arrived 🍎");
            _processMemberPayments(message);
            break;
          case 'stokvelPayments':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 COMMUTER_FENCE_DWELL_EVENTS arrived 🍎");
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
      print('♻️♻️♻️️♻️♻️️ MarshalBloc:FCM token  ❤️ 🧡 💛️ $token ❤️ 🧡 💛');
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

  Future<AccountResponse> getAccount(String seed) async {
    var accountResponse = await Stellar.getAccount(seed: seed);
    _accountResponses.add(accountResponse);
    _accountResponseController.sink.add(_accountResponses);
    print('🍎 GenericBloc 🍎  account response from 🧡 Stellar Network 🍎 '
        'balances: ${accountResponse.balances.length} responses in list: ${_accountResponses.length}');

    return accountResponse;
  }

  Future<AccountResponse> getStokvelAccount(String stokvelId) async {
    //get stokvel cred to get balance
    var cred = await FileUtil.getCredentialByStokvel(stokvelId);
    AccountResponse accountResponse;
    if (cred != null) {
      var encryptedSeed = cred.seed;
      var seed = makerBloc.decrypt(
          encryptedSeed: encryptedSeed,
          cryptKey: cred.cryptKey,
          fortunaKey: cred.fortunaKey);
      accountResponse = await Stellar.getAccount(seed: seed);
      _stokkieAccountResponses.add(accountResponse);
      _stokkieAccountResponseController.sink.add(_accountResponses);
      print(
          '🍎 GenericBloc 🍎  stokvel account response from 🧡 Stellar Network 🍎 '
          'balances: ${accountResponse.balances.length} responses in list: ${_accountResponses.length}');
      accountResponse.balances.forEach((bal) {
        print('🧡 🧡 🧡 STOKVEL Balance: ${bal.balance} of ${bal.assetType}');
      });
    } else {
      throw Exception('Stokvel credential not found');
    }

    return accountResponse;
  }

  Future<Member> getMember(String memberId) async {
    var member = await ListAPI.getMember(memberId);
    await FileUtil.addMember(member);
    return member;
  }

  Future<List<Member>> getStokvelMembers(String stokvelId) async {
    _members = await ListAPI.getStokvelMembers(stokvelId);
    _members.clear();
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

  Future<Member> createMember({Member member, String password}) async {
    _member = await Auth.createMember(member: member, memberPassword: password);
    return _member;
  }

  Future<Stokvel> createStokvel({Stokvel stokvel, Member member}) async {
    var stokvelResult =
        await DataAPI.createStokvelNewAdmin(stokvel: stokvel, member: member);
    _stokvels.add(stokvelResult);

    return stokvelResult;
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
    var seed = await makerBloc.getDecryptedCredential();
    if (seed == null) {
      throw Exception('Seed not found, cannot do payment');
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
    //todo - check account after transaction
    var updatedAcct = await getStokvelAccount(stokvel.stokvelId);
    prettyPrint(
        updatedAcct.toJson(), '🧡 Updated stokvel account, check balance ....');
    return res;
  }

  Future<StokvelPayment> sendMemberToMemberPayment(
      {Member fromMember, Member toMember, String amount}) async {
    var seed = await makerBloc.getDecryptedCredential();
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

  Future getStokvelPayments(String stokvelId) async {
    if (_member == null) {
      _member = await getCachedMember();
    }
    var _stokvelPaymnts = await ListAPI.getStokvelPayments(stokvelId);
    var filtered = List<StokvelPayment>();
    _stokvelPayments.forEach((m) {
      if (m.stokvel.stokvelId != stokvelId) {
        filtered.add(m);
      }
    });
    filtered.addAll(_stokvelPaymnts);
    _stokvelPayments = filtered;
    _stokvelPaymentController.sink.add(_stokvelPayments);
    return _stokvelPayments;
  }

  Future<List<Stokvel>> getStokvelsAdministered(String memberId) async {
    return await ListAPI.getStokvelsAdministered(memberId);
  }

  void _processStokvels(Map<String, dynamic> message) {}

  void _processMembers(Map<String, dynamic> message) {}

  void _processMemberPayments(Map<String, dynamic> message) {}

  void _processStokvelPayments(Map<String, dynamic> message) {}

  Future subscribeToFCM() async {
    List<String> topics = List();
    topics.add('stokvels');
    topics.add('members');
    topics.add('memberPayments');
    topics.add('stokvelPayments');
    for (var t in topics) {
      await fcm.subscribeToTopic(t);
      print('GenericBloc: 💜 💜 Subscribed to FCM topic: 🍎  $t ✳️ ');
    }
  }
}
