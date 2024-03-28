import 'package:flutter_webrtc/flutter_webrtc.dart';

class IceCandidateModel {
  final String peerId;
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;

  IceCandidateModel({
    required this.peerId,
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });

  Map<String, dynamic> toJson() => {
        'peerId': peerId,
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      };

  factory IceCandidateModel.fromJson(Map<String, dynamic> json) {
    return IceCandidateModel(
      peerId: json['peerId'],
      candidate: json['candidate'],
      sdpMid: json['sdpMid'],
      sdpMLineIndex: json['sdpMLineIndex'] as int,
    );
  }

  RTCIceCandidate get rtc {
    return RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
  }

  IceCandidateModel copyWith({
    String? peerId,
    String? candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  }) {
    return IceCandidateModel(
      peerId: peerId ?? this.peerId,
      candidate: candidate ?? this.candidate,
      sdpMid: sdpMid ?? this.sdpMid,
      sdpMLineIndex: sdpMLineIndex ?? this.sdpMLineIndex,
    );
  }
}

extension RTCIceCandidateExt on RTCIceCandidate {
  IceCandidateModel get model {
    return IceCandidateModel(
      peerId: '',
      candidate: candidate ?? '',
      sdpMid: sdpMid ?? '',
      sdpMLineIndex: sdpMLineIndex ?? -1,
    );
  }
}
