import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../configs/constants.dart';

class RtcConnectionModel {
  final int id;
  final RTCPeerConnection peerConnection;
  final RTCVideoRenderer renderer;

  const RtcConnectionModel._(
    this.id,
    this.peerConnection,
    this.renderer,
  );

  static Future<RtcConnectionModel> createAsync(int id) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    const configuration = AppConstants.peerConfiguration;
    const constraints = AppConstants.peerConstraints;

    return RtcConnectionModel._(
      id,
      await createPeerConnection(configuration, constraints),
      renderer,
    );
  }
}
