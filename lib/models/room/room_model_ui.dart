import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'rtc_connection_model.dart';

class RoomModelUI {
  final List<RtcConnectionModel> connections;

  const RoomModelUI({
    this.connections = const [],
  });

  RoomModelUI copyWith({
    List<RtcConnectionModel>? connections,
  }) {
    return RoomModelUI(
      connections: connections ?? this.connections,
    );
  }

  RTCPeerConnection? get peerConnection {
    return connections.firstOrNull?.peerConnection;
  }
}
