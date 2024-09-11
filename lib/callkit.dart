import 'package:call_kit2/main.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sip_ua/sip_ua.dart';

void displayIncomingCall(String callUUID, String handle) async {
  CallKitParams params = CallKitParams(
    id: callUUID,
    nameCaller: handle,
    appName: 'Callkit',
    avatar: 'https://i.pravatar.cc/100',
    handle: '0123456789',
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'assets/test.png',
      actionColor: '#4CAF50',
      textColor: '#ffffff',
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

void handleIncomingSipCall(Call call) {
  String? callUUID = call.id;

  displayIncomingCall(callUUID!, call.remote_display_name!);

  FlutterCallkitIncoming.onEvent.listen((event) async {
    print("STATECALLKIT ${event} call ${call.remote_display_name}");

    switch (event!.event) {
      case Event.actionCallAccept:
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

        mediaStream =
            await navigator.mediaDevices.getUserMedia(mediaConstraints);

        call.answer(mediaConstraints, mediaStream: mediaStream);
        break;
      case Event.actionCallIncoming:
        break;
      case Event.actionCallDecline:
        callBack = false;
        call.hangup();
        break;
      default:
        print('Other event: ');
        break;
    }
  });
}
