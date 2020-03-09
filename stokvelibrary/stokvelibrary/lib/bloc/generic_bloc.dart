import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sms/flutter_sms_platform.dart';
//import 'package:flutter_launch/flutter_launch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stellarplugin/data_models/account_response.dart';
import 'package:stellarplugin/stellarplugin.dart';
import 'package:stokvelibrary/bloc/prefs.dart';
import 'package:stokvelibrary/data_models/stokvel.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth.dart';
import 'data_api.dart';
import 'list_api.dart';

class GenericBloc extends ChangeNotifier {
  List<Member> _members = List();
  List<Stokvel> _stokvels = List();
  AccountResponse _accountResponse;
  Firestore fs = Firestore.instance;
  FirebaseMessaging fcm = FirebaseMessaging();

  Future configureFCM() async {
    
    print(
        '✳️ ✳️ ✳️ ✳️ GenericBloc:_configureFCM: CONFIGURE FCM: ✳️ ✳️ ✳️ ✳️  ');
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        String messageType = message['data']['type'];
        print(
            "\n\n️♻️♻️♻️️♻️♻️♻️  ✳️ ✳️ ✳️ ✳️ GenericBloc:FCM onMessage messageType: 🍎 $messageType arrived 🍎 \n\n");
        switch (messageType) {
          case 'stokvels':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 STOKVELS arrived 🍎");
            _processStokvels(message);
            break;
          case 'members':
            print(
                "✳️ ✳️ FCM onMessage messageType: 🍎 MEMBERS arrived 🍎");
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
      print(
          '♻️♻️♻️️♻️♻️️ MarshalBloc:FCM token  ❤️ 🧡 💛️ $token ❤️ 🧡 💛');
    });
    subscribeToFCM();

    return null;
  }

  Future getContacts() async {
    // Get all contacts on device
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.contacts);
    int status = serviceStatus.value;
    print('👽 PermissionHandler service status: $status');
    if (status == ServiceStatus.disabled.value) {
      print('👽 PermissionHandler service status is DISABLED .. openAppSettings ...');
      var isOK = await PermissionHandler().openAppSettings();
      print('👽 PermissionHandler openAppSettings returned: 🍯 $isOK');
    }
    await _requestContactsPermission();

    print('👽 PermissionHandler starting 🍯 ContactsService ... getContacts ...');
    Iterable<Contact> contacts = await ContactsService.getContacts();
    print('👽 👽 👽 getContacts found ${contacts.toList().length} contacts on device');
    return contacts.toList();

  }

  Future _requestContactsPermission() async {
    print('👽 PermissionHandler service status is enabled. checking permission for contacts ...');
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    if (permissionStatus.value != PermissionStatus.granted.value) {
      print('👽 PermissionHandler permission for contacts to be requested ...');
      var permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
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
    print('💚 💚 sendInvitationViaEmail: email sent to  🥬 ${invitation.email}');
  }

  Future sendInvitationViaSMS({Invitation invitation}) async {
    _setInvitationMessage(invitation);
    var msg = 'Invitation to ${invitation.stokvel.name}';
    var smsPlatform = FlutterSmsPlatform.instance;
    var canSend = await smsPlatform.canSendSMS();
    if (canSend) {
      var res = await smsPlatform.sendSMS(message: msg, recipients: [invitation.cellphone]);
      print(res);
      print('💚 💚 sendInvitationViaSMS: sms sent to  🥬 ${invitation.cellphone}');
    } else {
      throw Exception('Unable to send SMS');
    }
  }


  Future sendInvitationToExistingMember(
      {Invitation invitation}) async {
    _setInvitationMessage(invitation);
    await DataAPI.sendInvitation(invitation);
    print('💚 💚 sendInvitationToExistingMember: data will be sent via cloud message to 🍎 ${invitation.memberId}');
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

  AccountResponse get accountResponse => _accountResponse;
  Future<AccountResponse> getAccount(String seed) async {
    _accountResponse = await Stellar.getAccount(seed: seed);
    print('🍎 GenericBloc 🍎  - account response from Stellar Network 🍎 balances: ${_accountResponse.balances.length}');
    notifyListeners();
    return _accountResponse;
  }

  Future<Member> getMember(String memberId) async {
    return await ListAPI.getMember(memberId);
  }

  Future<List<Member>> getStokvelMembers(String stokvelId) async {
    var shot = await fs.collection('members').where('stokvels',
        arrayContains: {'stokvelId': stokvelId}).getDocuments();
    _members.clear();
    shot.documents.forEach((doc) {
      _members.add(Member.fromJson(doc.data));
    });
    _members.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return _members;
  }

  Future<List<Stokvel>> getStokvels({int limit = 1000}) async {
    var shot = await fs.collection('members').limit(limit).getDocuments();
    _stokvels.clear();
    shot.documents.forEach((doc) {
      _stokvels.add(Stokvel.fromJson(doc.data));
    });
    notifyListeners();
    return _stokvels;
  }

  var _stokvelMembers = List<Member>();
  var _stokvelPayments = List<StokvelPayment>();
  var _membersPayments = List<MemberPayment>();

  Member _member;

  GenericBloc() {
    print('🅿️ 🅿️  🎽 🎽 🎽 🎽  GenericBloc constructor ... 🅿️ 🅿️ ');
    getCachedMember();
    configureFCM();
  }

  Future<Member> getCachedMember() async {
    _member = await Prefs.getMember();
    notifyListeners();
    return _member;
  }

  Future<bool> isAuthenticated() async {
    return await Auth.checkAuth();
  }

  Future<Member> createMember({Member member, String password}) async {
    _member = await Auth.createMember(member: member, memberPassword: password);
    print(
        'AdminBloc will notify listeners that things are cool! ${_member.name}');
    notifyListeners();
    return _member;
  }

  Future<Stokvel> createStokvel(Stokvel stokvel) async {
    _member = await Prefs.getMember();
    if (_member == null) {
      throw Exception('Admin Member not found');
    }
    var stokvelResult = await DataAPI.createStokvel(stokvel);
    _stokvels.add(stokvelResult);
    await DataAPI.addStokvelToMember(
        stokvel: stokvel, memberId: _member.memberId);
    notifyListeners();
    return stokvelResult;
  }

  Future<Member> updateMember(Member member) async {
    return await DataAPI.updateMember(member);
  }

  Future<StokvelPayment> sendStokvelPayment(
      {Member member, String amount, Stokvel stokvel}) async {
    var seed = await Prefs.getMemberSeed();
    if (seed == null) {
      throw Exception('Seed not found');
    }
    var payment = StokvelPayment(
      member: member,
      amount: amount,
      date: DateTime.now().toUtc().toIso8601String(),
      seed: seed,
      stokvel: stokvel,
    );
    var res = await DataAPI.addStokvelPayment(payment: payment, seed: seed);
    _stokvelPayments.add(res);
    notifyListeners();
    return res;
  }

  Future<StokvelPayment> sendMemberToMemberPayment(
      {Member fromMember, Member toMember, String amount}) async {
    var seed = await Prefs.getMemberSeed();
    if (seed == null) {
      throw Exception('Seed not found');
    }
    var payment = MemberPayment(
        fromMember: fromMember,
        toMember: toMember,
        amount: amount,
        date: DateTime.now().toUtc().toIso8601String());
    var res = await DataAPI.addMemberPayment(payment: payment, seed: seed);
    _membersPayments.add(res);
    notifyListeners();
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
    notifyListeners();
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
      print(
          'GenericBloc: 💜 💜 Subscribed to FCM topic: 🍎  $t ✳️ ');
    }
  }

}

