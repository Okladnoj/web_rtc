import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class SignalingService {
  Future<void> sendSessionDescription(RTCSessionDescription description);

  Future<RTCSessionDescription?> getExistsSessionDescription();

  Future<void> sendIceCandidate(RTCIceCandidate candidate);

  void onSessionDescriptionReceived(
    Function(RTCSessionDescription description) callback,
  );

  void onIceCandidateReceived(Function(RTCIceCandidate candidate) callback);
}

class FirebaseSignalingService implements SignalingService {
  final DatabaseReference _signalingRef;

  FirebaseSignalingService(String roomId)
      : _signalingRef =
            FirebaseDatabase.instance.ref('rooms/$roomId/signaling');

  @override
  Future<void> sendSessionDescription(RTCSessionDescription description) async {
    await _signalingRef.child('session').set({
      'sdp': description.sdp,
      'type': description.type,
    });
  }

  @override
  Future<RTCSessionDescription?> getExistsSessionDescription() async {
    final snapshot = await _signalingRef.child('session').get();

    if (!snapshot.exists && snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final sdp = data['sdp'];
    final type = data['type'];
    return RTCSessionDescription(sdp, type);
  }

  @override
  Future<void> sendIceCandidate(RTCIceCandidate candidate) async {
    _signalingRef.child('iceCandidates').push().set({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  @override
  void onSessionDescriptionReceived(
      Function(RTCSessionDescription description) callback) {
    _signalingRef.child('session').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final sdp = data['sdp'];
        final type = data['type'];
        callback(RTCSessionDescription(sdp, type));
      }
    });
  }

  @override
  void onIceCandidateReceived(Function(RTCIceCandidate candidate) callback) {
    _signalingRef.child('iceCandidates').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        callback(candidate);
      }
    });
  }
}
