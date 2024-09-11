import 'dart:isolate';
import 'dart:ui';
import 'package:call_kit2/appLifecycleObserver.dart';
import 'package:call_kit2/call.dart';
import 'package:call_kit2/callkit.dart';
import 'package:call_kit2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SIPService extends SipUaHelperListener {
  final SIPUAHelper _helper = SIPUAHelper();
  Call? caller;

  SIPService() {
    _helper.addSipUaHelperListener(this);
  }

  Future<void> register() async {
    final UaSettings uaSettings = UaSettings()
      ..port = '5060'
      ..webSocketSettings.allowBadCertificate = true
      ..tcpSocketSettings.allowBadCertificate = true
      ..transportType = TransportType.WS
      ..webSocketUrl = ''
      ..uri = ''
      ..authorizationUser = ''
      ..password = '';

    _helper.start(uaSettings);
  }

  void makeCall(String target) async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'width': '1280',
        'height': '720',
        'facingMode': 'user',
      }
    };

    MediaStream mediaStream;

    mediaConstraints['video'] = false;

    mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _helper.call(target, voiceOnly: true, mediaStream: mediaStream) as Call?;
  }

  @override
  void callStateChanged(Call call, CallState state) async {
    print("STATESIP ${state.state} call ${call.remote_display_name}");

    caller = call;

    switch (state.state) {
      case CallStateEnum.CONFIRMED:
        if (callBack) {
          SendPort? sendPort = IsolateNameServer.lookupPortByName('main');
          if (sendPort != null) {
            sendPort.send('call');
          } else {
            print("Port not");
          }
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => CallScreen(call: call),
            ),
          );
        }
        break;
      case CallStateEnum.CONNECTING:
        break;

      case CallStateEnum.PROGRESS:
        handleIncomingSipCall(call);
        break;

      case CallStateEnum.ENDED:
        disposeCall(call);
        break;

      case CallStateEnum.ACCEPTED:
        break;

      case CallStateEnum.STREAM:
        break;

      case CallStateEnum.FAILED:
        disposeCall(call);
        break;

      default:
        break;
    }
  }

  Call? findCaller(String id) {
    Call? call = _helper.findCall(id);

    return call;
  }

  void disposeCall(Call call) async {
    await FlutterCallkitIncoming.endCall(call.id!);

    if (callBack) {
      SendPort? sendPort = IsolateNameServer.lookupPortByName('main');
      if (sendPort != null) {
        sendPort.send('end');
      } else {
        print("Port not");
      }
    } else if (lifecycleObserver.isAppInForeground) {
      print("callback else");
      navigatorKey.currentState?.pop();
    }

    _helper.removeSipUaHelperListener(this);

    _helper.stop();
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    // Handle registration state changes
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // TODO: implement onNewMessage
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }

  @override
  void onNewReinvite(ReInvite event) {
    // TODO: implement onNewReinvite
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }

  // Implement other listener methods...
}
