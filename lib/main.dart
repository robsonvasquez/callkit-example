import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:call_kit2/call.dart';
import 'package:call_kit2/home.dart';
import 'package:call_kit2/sip.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool initialCallkit = false;
ReceivePort? _receivePort;
SendPort? _sendPort;

bool callBack = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Handling a background message: ${message.data}");

  final SIPService helper = SIPService();
  helper.register();

  callBack = true;

  ReceivePort? _receivePort;
  SendPort? _sendPort;
  _receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(_receivePort!.sendPort, 'background');

  _receivePort!.listen((message) {
    if (message is SendPort) {
      _sendPort = message; 
    } else {

      if (message == "end") {
        helper.caller!.hangup();
      }

      if (message == "mute") {
        helper.caller!.mute();
      }

      if (message == "unmute") {
        helper.caller!.unmute();
      }
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  _receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(_receivePort!.sendPort, 'main');

  _receivePort!.listen((message) {
    print("TESTE MAIN $message");
    if (message is SendPort) {
      _sendPort = message;
    } else {
      print('Mensagem recebida do background: $message');

      if (message == "end") {
        navigatorKey.currentState?.pop();
      }

      if (message == "call") {
        navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => CallScreen(
            data: {"name": "Paulo"},
          ),
        ),
      );
      }
    }

  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Permission.microphone.request();
  await Permission.notification.request();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const platform = MethodChannel('flutter_callkit_channel');

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onCallAccepted') {
      setState(() {
        initialCallkit = true;
      });

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => CallScreen(
            data: {"name": "Paulo"},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Communication App',
      navigatorKey: navigatorKey,
      home: const Home(),
    );
  }
}
