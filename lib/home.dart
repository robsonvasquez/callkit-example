import 'package:call_kit2/sip.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SIPService? _registration = SIPService();

  @override
  void initState() {
    super.initState();
    _registration = SIPService();
    _getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message: ${message.data}');
      SIPService().register();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification click');
    });

  }

  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("Token: $token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communication App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Call.'),
            ElevatedButton(
              onPressed: () {
                _registration?.register();
              },
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                String destiny = '100';
                _registration!.makeCall(destiny);
              },
              child: Text('Initial SIP call'),
            ),
          ],
        ),
      ),
    );
  }
}
