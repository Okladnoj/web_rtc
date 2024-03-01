import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/room_model.dart';
import '../../services/webrtc_service.dart';
import '../../services/signaling_service.dart';

class RoomCore {
  final RoomModel currentRoom;
  late final WebRTCService _webrtcService;
  late final SignalingService _signalingService;

  RoomCore({required this.currentRoom}) {
    _webrtcService = WebRTCService(currentRoom.id);
    _signalingService = SignalingService();
  }

  bool _enabledMicrophone = false;

  final _controllerLoading = StreamController<bool>.broadcast();
  final _controllerRemoteStream = StreamController<MediaStream>.broadcast();

  StreamSink<bool> get _sinkLoading => _controllerLoading.sink;
  Stream<bool> get loading => _controllerLoading.stream;

  StreamSink<MediaStream> get _sinkRemoteStream => _controllerRemoteStream.sink;
  Stream<MediaStream> get remoteStream => _controllerRemoteStream.stream;

  Future<void> initWebRTC() async {
    _loading(true);
    try {
      await _webrtcService.initialize();
      _setupListeners();
    } catch (e) {
      log('Error initializing WebRTC: $e');
    } finally {
      _loading(false);
    }
  }

  void _setupListeners() {
    // Setting up listeners for ICE candidates, answers, and offers
    _webrtcService.peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        // Remote peer stream
        _sinkRemoteStream.add(event.streams.first);
      }
    };

    // Additional: Setting up signaling listeners
    _signalingService.listenForAnswer((answer) {
      _webrtcService.handleAnswer(answer.sdp);
    });

    _signalingService.listenForIceCandidates((candidate) {
      _webrtcService.addIceCandidate(candidate.toJson());
    });
  }

  // Creating an offer and sending it through the signaling service
  Future<void> createOffer() async {
    await _webrtcService.createOffer();
    _enabledMicrophone = true;
    // Offer is automatically sent via WebRTCService
  }

  void stop() {
    _enabledMicrophone = false;
    _webrtcService.toggleMicrophone(_enabledMicrophone);
  }

  void _loading(bool isLoading) {
    _sinkLoading.add(isLoading);
  }

  void dispose() {
    _controllerLoading.close();
    _controllerRemoteStream.close();
    _webrtcService.dispose();
  }
}
