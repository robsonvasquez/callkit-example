import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sip_ua/sip_ua.dart';

class CallScreen extends StatefulWidget {
  final Call? call;
  final Map<String, dynamic>? data;

  const CallScreen({super.key, this.call, this.data});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call progress'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Call name: ${widget.call?.remote_display_name ?? widget.data?["name"]}'),
            Text('Call ID: ${widget.call?.id ?? widget.data?["name"]}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Encerra a chamada
                if (widget.call != null) {
                  widget.call?.hangup();
                } else {
                  SendPort? sendPort =
                      IsolateNameServer.lookupPortByName('background');
                  if (sendPort != null) {
                    sendPort.send('end');
                  } else {
                    print("Port not");
                  }
                }
              },
              child: const Text('Call end'),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.call != null) {
                  widget.call?.mute();
                } else {
                  SendPort? sendPort =
                      IsolateNameServer.lookupPortByName('background');
                  if (sendPort != null) {
                    sendPort.send('mute');
                  } else {
                    print("Port not");
                  }
                }
              },
              child: const Text("mute"),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.call != null) {
                  widget.call?.unmute();
                } else {
                  SendPort? sendPort =
                      IsolateNameServer.lookupPortByName('background');
                  if (sendPort != null) {
                    sendPort.send('unmute');
                  } else {
                    print("Port not");
                  }
                }
              },
              child: const Text("Unmute"),
            )
          ],
        ),
      ),
    );
  }
}
