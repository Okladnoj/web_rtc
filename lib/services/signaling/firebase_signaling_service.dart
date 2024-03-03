import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signaling_service.dart';

class FirebaseSignalingService extends SignalingService {
  final DatabaseReference _signalingRef;

  final _onOfferReceivedController = StreamController<String>();
  final _onAnswerReceivedController = StreamController<String>();
  final _onIceCandidateReceivedController = StreamController<RTCIceCandidate>();

  FirebaseSignalingService({required super.room})
      : _signalingRef = FirebaseDatabase.instance.ref(
          'rooms/${room.id}/signaling',
        ) {
    _signalingRef.child('offer').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final offer = value['sdp'];
      if (offer == null) return;
      _onOfferReceivedController.add(offer);
    });

    _signalingRef.child('answer').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final answer = value['sdp'];
      if (answer != null) _onAnswerReceivedController.add(answer);
    });

    _signalingRef.child('iceCandidates').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data is! Map) return;
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      _onIceCandidateReceivedController.add(candidate);
    });
  }

  @override
  Stream<String> get onOfferReceived => _onOfferReceivedController.stream;

  @override
  Stream<String> get onAnswerReceived => _onAnswerReceivedController.stream;

  @override
  Stream<RTCIceCandidate> get onIceCandidateReceived =>
      _onIceCandidateReceivedController.stream;

  @override
  Future<void> sendOffer(String sdp) async {
    final offerData = {
      'type': 'offer',
      'sdp': sdp,
      'timestamp': ServerValue.timestamp,
    };
    await _signalingRef.child('offer').set(offerData);
  }

  @override
  Future<void> sendAnswer(String sdp) async {
    final answerData = {
      'type': 'answer',
      'sdp': sdp,
      'timestamp': ServerValue.timestamp,
    };
    await _signalingRef.child('answer').set(answerData);
  }

  @override
  Future<void> sendIceCandidate(RTCIceCandidate candidate) async {
    log('---> sendIceCandidate $candidate');
    final iceCandidateData = {
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
      'timestamp': ServerValue.timestamp,
    };
    await _signalingRef
        .child('iceCandidates')
        .push()
        .set(iceCandidateData)
        .then((_) {
      log('ICE candidate was sent successfully.');
    }).catchError((error) {
      log('Failed to send ICE candidate: $error');
    });
  }

  @override
  Future<void> connect(String url) async {}

  @override
  void disconnect() {
    _onOfferReceivedController.close();
    _onAnswerReceivedController.close();
    _onIceCandidateReceivedController.close();
  }

  @override
  Stream<bool> get onConnected => throw UnimplementedError();

  @override
  Stream<bool> get onDisconnected => throw UnimplementedError();
}
