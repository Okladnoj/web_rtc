import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../configs/constants.dart';
import '../../utils/logger.dart';

class WebRTCService {
  final RTCPeerConnection peerConnection;
  final remoteRenderer = RTCVideoRenderer();

  WebRTCService._(this.peerConnection);

  static Future<WebRTCService> createPeerToOffer(
    MediaStream localStream,
    AsyncValueSetter<RTCSessionDescription> sendOffer,
    ValueSetter<RTCIceCandidate> setCandidate,
    VoidCallback onRemoteMedia,
  ) async {
    final service = WebRTCService._(await _createPeerConnection());

    await _registerPeerConnectionListeners(
      service,
      setCandidate,
      onRemoteMedia,
    );

    localStream.getTracks().forEach((track) {
      service.peerConnection.addTrack(track, localStream);
    });

    final offer = await service.peerConnection.createOffer();

    await service.peerConnection.setLocalDescription(offer);

    await sendOffer(offer);

    return service;
  }

  static Future<WebRTCService> createPeerToAnswer(
    MediaStream localStream,
    RTCSessionDescription remoteDescription,
    AsyncValueSetter<RTCSessionDescription> sendAnswer,
    ValueSetter<RTCIceCandidate> setCandidate,
    VoidCallback onRemoteMedia,
  ) async {
    final service = WebRTCService._(await _createPeerConnection());

    await _registerPeerConnectionListeners(
      service,
      setCandidate,
      onRemoteMedia,
    );

    localStream.getTracks().forEach((track) {
      service.peerConnection.addTrack(track, localStream);
    });

    await service.peerConnection.setRemoteDescription(remoteDescription);

    final answer = await service.peerConnection.createAnswer();

    await service.peerConnection.setLocalDescription(answer);

    await sendAnswer(answer);

    return service;
  }

  static Future<RTCPeerConnection> _createPeerConnection() async {
    const configuration = AppConstants.peerConfiguration;
    const constraints = AppConstants.peerConstraints;
    final peerConnection = await createPeerConnection(
      configuration,
      constraints,
    );
    Logger.printGreen('Peer Connection created');
    return peerConnection;
  }

  static Future<void> _registerPeerConnectionListeners(
    WebRTCService service,
    ValueSetter<RTCIceCandidate> setCandidate,
    VoidCallback onRemoteMedia,
  ) async {
    await service.remoteRenderer.initialize();
    service.peerConnection.onIceCandidate = (candidate) {
      Logger.printCyan('Received ${candidate.candidate?.substring(0, 90)}\t.');
      setCandidate(candidate);
    };

    service.peerConnection.onAddStream = (stream) {
      Logger.printBlue('Remote stream added');
      service.remoteRenderer.srcObject = stream;
      onRemoteMedia();
    };

    service.peerConnection.onTrack = (event) {
      Logger.printCyan('Track is added to the connection');
      event.streams[0].getTracks().forEach((track) {
        service.remoteRenderer.srcObject?.addTrack(track);
      });
    };
  }

  Future<void> dispose() async {
    await peerConnection.dispose();
    await remoteRenderer.srcObject?.dispose();
    await remoteRenderer.dispose();
  }
}
