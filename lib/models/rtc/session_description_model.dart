import 'package:flutter_webrtc/flutter_webrtc.dart';

class SessionDescriptionModel {
  final String peerId;
  final String type;
  final String sdp;

  const SessionDescriptionModel({
    this.peerId = '',
    this.type = '',
    this.sdp = '',
  });

  Map<String, dynamic> toJson() => {
        'peerId': peerId,
        'type': type,
        'sdp': sdp,
      };

  factory SessionDescriptionModel.fromJson(Map<String, dynamic> json) {
    return SessionDescriptionModel(
      peerId: json['peerId'],
      type: json['type'],
      sdp: json['sdp'],
    );
  }

  RTCSessionDescription get trc {
    return RTCSessionDescription(sdp, type);
  }

  SessionDescriptionModel copyWith({
    String? peerId,
    String? type,
    String? sdp,
  }) {
    return SessionDescriptionModel(
      peerId: peerId ?? this.peerId,
      type: type ?? this.type,
      sdp: sdp ?? this.sdp,
    );
  }
}

extension RTCSessionDescriptionExt on RTCSessionDescription {
  SessionDescriptionModel get model {
    return SessionDescriptionModel(sdp: sdp ?? '', type: type ?? '');
  }
}
