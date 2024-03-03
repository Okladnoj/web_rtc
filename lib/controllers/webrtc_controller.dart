import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/room/room_model_ui.dart';
import '../models/room/rtc_connection_model.dart';
import '../services/signaling/signaling_service.dart';
import '../services/webrtc/webrtc_service.dart';

class WebRTCController {
  final SignalingService signalingService;
  final WebRTCService webRTCService;

  WebRTCController(this.signalingService, this.webRTCService) {
    _init();
  }

  RoomModelUI _modelUI = const RoomModelUI();

  final _controllerLoading = StreamController<bool>.broadcast();
  StreamSink<bool> get _sinkLoading => _controllerLoading.sink;
  Stream<bool> get loading => _controllerLoading.stream;

  final _controllerUI = StreamController<RoomModelUI>.broadcast();
  StreamSink<RoomModelUI> get _sinkUI => _controllerUI.sink;
  Stream<RoomModelUI> get streamUI => _controllerUI.stream;

  Future<void> _init() async {
    _modelUI = _modelUI.copyWith();
    _sinkLoading.add(true);

    await webRTCService.initializeLocalStream();

    await webRTCService.initializeLocalPeer(_updateRtcConnectModel);

    final peer = _modelUI.peerConnection;

    await webRTCService.createOffer(peer, signalingService.sendOffer);
    _sinkLoading.add(false);

    signalingService.onAnswerReceived.listen(
      webRTCService.setRemoteDescription,
    );

    signalingService.onIceCandidateReceived.listen(
      webRTCService.addIceCandidate,
    );

    signalingService.onOfferReceived.listen((String sdp) async {
      final answerSDP = await webRTCService.createAnswer(sdp);
      if (answerSDP == null) return;
      await signalingService.sendAnswer(answerSDP);
    });

    webRTCService.onIceCandidate.listen((candidate) {
      signalingService.sendIceCandidate(candidate);
    });

    webRTCService.onAddRemoteStream.listen((remoteStream) {
      _remoteRenderer.srcObject = remoteStream;
    });

    webRTCService.onConnectionStateChange.listen((isConnected) {
      if (isConnected) {
        log('---> Connection Established');
      } else {
        log('---> Connection Lost');
      }
    });
  }

  void speak() {
    _localRenderer.muted = true;
  }

  void stop() {
    _localRenderer.muted = false;
  }

  void _updateUI() {
    _sinkUI.add(_modelUI);
  }

  Future<void> dispose() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    webRTCService.dispose();
    signalingService.disconnect();
  }

  void _updateRtcConnectModel(RtcConnectionModel value) {
    _modelUI = _modelUI.copyWith(connections: [..._modelUI.connections, value]);
  }
}
