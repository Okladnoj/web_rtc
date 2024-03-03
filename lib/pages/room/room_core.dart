import 'dart:async';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/room/room_model.dart';
import '../../models/room/room_model_ui.dart';
import '../../services/webrtc_service.dart';
import '../../services/signaling_service.dart';

class RoomCore {
  final RoomModel currentRoom;
  final WebRTCService _webrtcService;

  RoomCore({
    required this.currentRoom,
  }) : _webrtcService = WebRTCService(FirebaseSignalingService(currentRoom.id));

  bool _enabledMicrophone = false;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  final _controllerLoading = StreamController<bool>.broadcast();
  final _controllerRemoteStream =
      StreamController<RTCVideoRenderer>.broadcast();
  final _controllerLocalStream = StreamController<RTCVideoRenderer>.broadcast();
  final _controllerUI = StreamController<RoomModelUI>.broadcast();

  StreamSink<bool> get _sinkLoading => _controllerLoading.sink;
  Stream<bool> get loading => _controllerLoading.stream;

  StreamSink<RTCVideoRenderer> get _sinkRemoteStream =>
      _controllerRemoteStream.sink;
  Stream<RTCVideoRenderer> get remoteStream => _controllerRemoteStream.stream;

  StreamSink<RTCVideoRenderer> get _sinkLocalStream =>
      _controllerLocalStream.sink;
  Stream<RTCVideoRenderer> get localStream => _controllerLocalStream.stream;

  Stream<RoomModelUI> get observerUI => _controllerUI.stream;

  Future<void> initWebRTC() async {
    _loading(true);
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      await _webrtcService.initialize(_onLocal, _onRemote);
    } catch (e) {
      log('Error initializing WebRTC: $e');
    } finally {
      _loading(false);
    }
  }

  void _onLocal(MediaStream value) {
    _localRenderer.srcObject = value;
    _sinkLocalStream.add(_localRenderer);
  }

  void _onRemote(MediaStream value) {
    _remoteRenderer.srcObject = value;
    _sinkRemoteStream.add(_remoteRenderer);
  }

  // Creating an offer and sending it through the signaling service
  Future<void> speak() async {
    _enabledMicrophone = true;
    _webrtcService.toggleMicrophone(_enabledMicrophone);
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
    _controllerUI.close();
    _webrtcService.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }
}
