import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/rtc/ice_candidate_model.dart';
import '../models/rtc/session_description_model.dart';
import '../services/manager/signal_manager_service.dart';
import '../services/rtc/rtc_unit.dart';
import '../services/rtc/signal_service.dart';
import '../services/rtc/webrtc_service.dart';
import '../utils/logger.dart';

class ConferenceController {
  final SignalingManagerService _managerService;
  final MediaStream _localMedia;
  final _localRender = RTCVideoRenderer();

  ConferenceController(this._managerService, this._localMedia);

  final units = <RtcUnit>[];

  String get conferenceName => _managerService.room.name;

  final _controller = StreamController<Object>.broadcast();
  Stream<Object> get onActivePeersChanged => _controller.stream;

  final _controllerLoading = StreamController<bool>.broadcast();
  Stream<bool> get loading => _controllerLoading.stream;

  Future<void> init() async {
    await _localRender.initialize();
    await _localRender.setSrcObject(stream: _localMedia);

    await _managerService.createUserNode();

    await _managerService.listenRemoteNodes((value) async {
      final connectionUrl = _managerService.connectionUrl;
      final userIdLocal = _managerService.userIdLocal;
      final userIdRemote = value;
      if (userIdRemote.isEmpty) return;

      final signalingService = SignalingFirebaseService(
        connectionUrl,
        userIdLocal,
        userIdRemote,
      );

      Future<void> sendOffer(RTCSessionDescription value) async {
        final description = value.model.copyWith(peerId: userIdLocal);
        Logger.printMagenta('sendOfferToRemotePeerNode');
        signalingService.sendOfferToRemotePeerNode(description);
      }

      void setCandidate(RTCIceCandidate value) {
        final candidate = value.model.copyWith(peerId: userIdLocal);
        signalingService.sendCandidateToRemotePeerNode(candidate);
      }

      final rtcService = await WebRTCService.createPeerToOffer(
        _localMedia,
        sendOffer,
        setCandidate,
        _updateUI,
      );
      units.add(RtcUnit.toRemote(signalingService, rtcService));
      _updateUI();
    });

    await _managerService.listenOwnNodes((remoteDescription) async {
      final connectionUrl = _managerService.connectionUrl;
      final userIdLocal = _managerService.userIdLocal;
      final userIdRemote = remoteDescription.peerId;
      if (userIdRemote.isEmpty) return;

      final signalingService = SignalingFirebaseService(
        connectionUrl,
        userIdLocal,
        userIdRemote,
      );

      Future<void> sendAnswer(RTCSessionDescription value) async {
        final description = value.model.copyWith(peerId: userIdLocal);
        Logger.printMagenta('sendAnswerToPeerNode');
        signalingService.sendAnswerToPeerNode(description);
      }

      void setCandidate(RTCIceCandidate value) {
        final candidate = value.model.copyWith(peerId: userIdLocal);
        signalingService.sendCandidateToPeerNode(candidate);
      }

      final rtcService = await WebRTCService.createPeerToAnswer(
        _localMedia,
        remoteDescription.trc,
        sendAnswer,
        setCandidate,
        _updateUI,
      );
      units.add(RtcUnit.toLocal(signalingService, rtcService));
      _updateUI();
    });
  }

  RTCVideoRenderer get localRenderer => _localRender;

  List<RTCVideoRenderer> get remoteRenderers {
    return [...units.map((e) => e.remoteRenderer)];
  }

  void leaveConference() async {
    await localRenderer.srcObject?.dispose();
    await localRenderer.dispose();

    for (var unit in units) {
      await unit.dispose();
    }
    await _managerService.removeUserNode();
  }

  void speak() {
    for (final track in _localMedia.getTracks()) {
      track.enabled = true;
    }
  }

  void stop() {
    for (final track in _localMedia.getTracks()) {
      track.enabled = false;
    }
  }

  void _updateUI() {
    _controller.add(Object());
  }
}
