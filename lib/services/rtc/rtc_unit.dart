import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'signal_service.dart';
import 'webrtc_service.dart';

class RtcUnit {
  final SignalingService _signalingService;
  final WebRTCService _rtcService;

  const RtcUnit._(this._signalingService, this._rtcService);

  factory RtcUnit.toLocal(
    SignalingService signalingService,
    WebRTCService rtcService,
  ) {
    final unit = RtcUnit._(signalingService, rtcService);

    unit._signalingService.onCandidate((candidate) async {
      unit._rtcService.peerConnection.addCandidate(candidate.rtc);
    });

    return unit;
  }
  factory RtcUnit.toRemote(
    SignalingService signalingService,
    WebRTCService rtcService,
  ) {
    final unit = RtcUnit._(signalingService, rtcService);

    unit._signalingService.onRemoteCandidate((candidate) async {
      unit._rtcService.peerConnection.addCandidate(candidate.rtc);
    });

    unit._signalingService.onRemoteAnswer((description) async {
      unit._rtcService.peerConnection.setRemoteDescription(description.trc);
    });
    return unit;
  }

  Future<void> dispose() async {
    await _signalingService.dispose();
    await _rtcService.dispose();
  }

  RTCVideoRenderer get remoteRenderer => _rtcService.remoteRenderer;
}
