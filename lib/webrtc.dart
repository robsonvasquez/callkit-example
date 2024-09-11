import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  Future<void> initWebRTC() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);
    _peerConnection!.addStream(_localStream!);
  }

  void makeCall() {
    // Implement WebRTC call logic
  }

  void endCall() {
    _peerConnection?.close();
  }
}
