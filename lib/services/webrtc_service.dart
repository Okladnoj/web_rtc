import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ice_candidate_model.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  final DatabaseReference _signalingRef;
  String roomId; // Room ID to differentiate signaling messages by rooms

  WebRTCService(this.roomId)
      : _signalingRef = FirebaseDatabase.instance.ref(
          'rooms/$roomId/signaling',
        );

  // Initialize the WebRTC connection
  Future<void> initialize() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    final constraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    peerConnection = await createPeerConnection(configuration, constraints);

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _sendIceCandidate(candidate);
    };

    // Listen for signaling messages from other users
    _listenForRemoteSession();
    _listenForRemoteIceCandidate();

    localStream!.getAudioTracks().forEach((track) {
      log('Audio track enabled: ${track.enabled}, state: ${track.getConstraints()}');
    });

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      log('ICE Connection State has changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      log('Connection State has changed: $state');
    };
  }

  // Create an offer to start a WebRTC connection
  Future<void> createOffer() async {
    final offer = await peerConnection?.createOffer({});
    if (offer == null) return;
    await peerConnection?.setLocalDescription(offer);
    _sendSessionDescription(offer);
  }

  void toggleMicrophone(bool enabled) {
    if (localStream != null) {
      localStream!.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }

  // Handle an answer to an offer sent
  void handleAnswer(String sdp) async {
    RTCSessionDescription answer = RTCSessionDescription(sdp, 'answer');
    await peerConnection?.setRemoteDescription(answer);
  }

  // Add an ICE candidate received from a remote peer
  void addIceCandidate(Map candidateMap) async {
    final map = Map<String, dynamic>.from(candidateMap);
    final candidateModel = IceCandidateModel.fromJson(map);
    RTCIceCandidate iceCandidate = RTCIceCandidate(
      candidateModel.candidate,
      candidateModel.sdpMid,
      candidateModel.sdpMLineIndex,
    );
    await peerConnection?.addCandidate(iceCandidate);
  }

  // Send the local session description (offer/answer) to a remote peer
  void _sendSessionDescription(RTCSessionDescription description) {
    _signalingRef.child('session').set({
      'sdp': description.sdp,
      'type': description.type,
    });
  }

  // Send a local ICE candidate to a remote peer
  void _sendIceCandidate(RTCIceCandidate candidate) {
    _signalingRef.child('iceCandidates').push().set({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  // Listen for session descriptions (offers/answers) from remote peers
  void _listenForRemoteSession() {
    _signalingRef.child('session').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final sdp = data['sdp'];
        final type = data['type'];
        if (type == 'offer') {
          // Handle the received offer
        } else if (type == 'answer') {
          handleAnswer(sdp);
        }
      }
    });
  }

  // Listen for ICE candidates from remote peers
  void _listenForRemoteIceCandidate() {
    _signalingRef.child('iceCandidates').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, value) {
          addIceCandidate(value);
        });
      }
    });
  }

  // Clean up resources
  void dispose() {
    localStream?.dispose();
    peerConnection?.close();
  }
}
