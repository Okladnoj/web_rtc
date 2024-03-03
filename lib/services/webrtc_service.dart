import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling_service.dart';

class WebRTCService {
  late final RTCPeerConnection _peerConnection;
  late final MediaStream _localStream;
  final SignalingService _signalingService;

  WebRTCService(this._signalingService);

  Future<void> initialize(
    ValueChanged<MediaStream> local,
    ValueChanged<MediaStream> remote,
  ) async {
    // Creating the peer connection
    _peerConnection =
        await createPeerConnection(_peerConfiguration, _peerConstraints);
    log('Peer connection created');

    // Getting the local audio stream
    _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
    log('Local stream obtained');

    for (var track in _localStream.getTracks()) {
      log('---> Track added ${track.label}');
      await _peerConnection.addTrack(track, _localStream);
    }
    log('Local tracks added to peer connection');

    _setupListeners(remote);

    await _createOffer();
    log('Offer created');

    await Future.delayed(const Duration(seconds: 1));
    local(_localStream);
  }

  // Handling remote session descriptions
  void _handleRemoteSession(RTCSessionDescription description) async {
    log('Attempting to set remote description. Current signaling state: ${_peerConnection.signalingState}');
    if (_peerConnection.signalingState ==
        RTCSignalingState.RTCSignalingStateHaveLocalOffer) return;

    await _peerConnection.setRemoteDescription(description);
    log('Remote description successfully set: Type: ${description.type}, SDP: ${description.sdp}');

    // If the description is an offer, we need to create an answer
    if (description.type == 'offer') {
      final answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);
      log('Answer created and local description set: SDP: ${answer.sdp}');
      log('Local description set: $answer');

      // Send the answer through the signaling service
      _signalingService.sendSessionDescription(answer);
    }
  }

  // Handling remote ICE candidates
  void _handleRemoteIceCandidate(RTCIceCandidate candidate) async {
    log('Adding remote ICE candidate: ${candidate.candidate}');
    await _peerConnection.addCandidate(candidate);
    log('Remote ICE candidate added: $candidate');
  }

  // Toggle the local microphone on/off
  void toggleMicrophone(bool enabled) {
    _localStream.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
    log('Microphone toggled: $enabled');
  }

  // Clean up resources
  void dispose() {
    _localStream.dispose();
    _peerConnection.close();
    log('Resources disposed');
  }

  // Create an offer to start the WebRTC connection
  Future<void> _createOffer() async {
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    log('Local description set: $offer');

    // Send the offer through the signaling service
    await _signalingService.sendSessionDescription(offer);
    log('Offer created and local description set: SDP: ${offer.sdp}');
  }

  void _setupListeners(ValueChanged<MediaStream> remote) {
    // Adding the local audio stream to the peer connection

    // Handling ICE candidates
    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) async {
      // Send ICE candidate through the signaling service
      log('Sending ICE candidate: ${candidate.candidate}');
      await _signalingService.sendIceCandidate(candidate);
      log('Local ICE candidate sent: $candidate');
    };

    _peerConnection.onTrack = (event) {
      log('Track event received. Track kind: ${event.track.kind}, ID: ${event.track.id}');
      final stream = event.streams.firstOrNull;
      if (stream == null) return;
      remote(stream);
      log('Remote track added: ${event.track}');
    };

    // Handling ICE connection state changes
    _peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      log('ICE Connection State has changed: $state');
    };

    // Handling Peer connection state changes
    _peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      log('Connection State has changed: $state');
    };

    _localStream.getAudioTracks().forEach((track) {
      track.onEnded = () => log('Local audio track ended: ${track.id}');
      track.onMute = () => log('Local audio track muted: ${track.id}');
      track.onUnMute = () => log('Local audio track unMute: ${track.id}');
    });

    // Listening for remote session descriptions (offers/answers)
    _signalingService.onSessionDescriptionReceived(_handleRemoteSession);

    // Listening for remote ICE candidates
    _signalingService.onIceCandidateReceived(_handleRemoteIceCandidate);
  }

  // WebRTC configuration (STUN/TURN servers)
  static const _peerConfiguration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }, // Example STUN server
      // Add TURN servers here if needed
    ]
  };

  // Constraints for the peer connection
  static const _peerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  // Constraints for the Local Media connection
  static const _mediaConstraints = {
    'audio': true, // Enable audio
    'video': false, // Disable video
  };
}
