import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../configs/constants.dart';
import '../../models/room/rtc_connection_model.dart';
import 'webrtc_service.dart';

class AppWebRTCService extends WebRTCService {
  late final MediaStream _localStream;

  final _onAddRemoteSC = StreamController<MediaStream>.broadcast();
  final _onConnectionSC = StreamController<bool>.broadcast();
  final _onIceCandidateSC = StreamController<RTCIceCandidate>.broadcast();

  @override
  Future<void> initializeLocalStream() async {
    const constraints = AppConstants.mediaConstraints;
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    } catch (error) {
      log('Unable to obtain local media stream:', error: error);
    }
  }

  @override
  Future<void> initializeLocalPeer(
    ValueChanged<RtcConnectionModel> rtcConnectModel,
  ) async {
    late final RtcConnectionModel connectModel;
    try {
      connectModel = await RtcConnectionModel.createAsync(0);

      for (var track in _localStream.getTracks()) {
        log('---> Track added ${track.label}');
        await connectModel.peerConnection.addTrack(track, _localStream);
      }
    } catch (error) {
      log('Unable to create Peer Connection:', error: error);
      return;
    }

    try {
      connectModel.peerConnection.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _onAddRemoteSC.add(event.streams.first);
        }
      };

      connectModel.peerConnection.onIceConnectionState =
          (RTCIceConnectionState state) {
        bool isConnected =
            state == RTCIceConnectionState.RTCIceConnectionStateConnected;
        _onConnectionSC.add(isConnected);
      };

      connectModel.peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
        _onIceCandidateSC.add(candidate);
      };

      rtcConnectModel(connectModel);
    } catch (error) {
      log('Unable to init Peer Connection Listeners:', error: error);
    }
  }

  @override
  Future<void> createOffer(
    RTCPeerConnection? localPeerConnection,
    AsyncValueSetter<String> spdToSignal,
  ) async {
    try {
      if (localPeerConnection == null) throw 'localPeerConnection == null';
      final description = await localPeerConnection.createOffer({});
      final sdp = description.sdp;
      if (sdp == null) throw 'sdp == null';
      await localPeerConnection.setLocalDescription(description);
      await spdToSignal(sdp);
    } catch (error) {
      log('Error creating offer:', error: error);
    }
  }

  @override
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection.addCandidate(candidate);
    } catch (error) {
      log('Error adding ICE candidate:', error: error);
    }
  }

  @override
  Future<String?> createAnswer(String sdp) async {
    try {
      final offer = RTCSessionDescription(sdp, 'offer');
      await _peerConnection.setRemoteDescription(offer);
      final description = await _peerConnection.createAnswer({});
      await _peerConnection.setLocalDescription(description);
      return description.sdp;
    } catch (error) {
      log('Error creating answer:', error: error);
    }
    return null;
  }

  @override
  Future<void> setRemoteDescription(String sdp) async {
    try {
      RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');
      await _peerConnection.setRemoteDescription(description);
    } catch (error) {
      log('Error setting remote description:', error: error);
    }
  }

  @override
  Stream<MediaStream> get onAddRemoteStream => _onAddRemoteSC.stream;

  @override
  Stream<bool> get onConnectionStateChange => _onConnectionSC.stream;

  @override
  Stream<RTCIceCandidate> get onIceCandidate => _onIceCandidateSC.stream;

  @override
  void dispose() {
    _onAddRemoteSC.close();
    _onConnectionSC.close();
    _onIceCandidateSC.close();
  }
}
