import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/room/room_model.dart';

/// The `SignalingService` interface is responsible for handling the signaling
/// process necessary for WebRTC communication. It manages the exchange of
/// signaling messages between peers to facilitate the discovery and configuration
/// of media channels. This includes creating offers/answers and exchanging
/// ICE candidates to establish a peer-to-peer connection.
abstract class SignalingService {
  final RoomModel room;

  SignalingService({required this.room});

  /// Connects to the signaling server using the provided URL.
  /// This method should establish a WebSocket (or any other protocol) connection
  /// to the signaling server, ready to send and receive signaling messages.
  ///
  /// @param url The URL of the signaling server.
  Future<void> connect(String url);

  /// Sends a WebRTC offer to the signaling server, intended for a remote peer.
  /// The offer includes details about the media formats and codecs being used.
  ///
  /// @param sdp The SDP (Session Description Protocol) offer string.
  Future<void> sendOffer(String sdp);

  /// Sends a WebRTC answer in response to an offer received from a remote peer.
  /// The answer contains the final configuration for the WebRTC connection.
  ///
  /// @param sdp The SDP answer string.
  Future<void> sendAnswer(String sdp);

  /// Sends an ICE candidate to the signaling server, intended for a remote peer.
  /// ICE candidates are used to establish the media path between peers.
  ///
  /// @param candidate The ICE candidate object.
  Future<void> sendIceCandidate(RTCIceCandidate candidate);

  /// Disconnects from the signaling server and cleans up any resources.
  /// This method should close the signaling connection and ensure that all
  /// event listeners are properly removed.
  void disconnect();

  /// Stream that emits when an offer is received from the signaling server.
  /// This is typically used to generate an answer and establish a WebRTC connection.
  Stream<String> get onOfferReceived;

  /// Stream that emits when an answer is received in response to an offer sent.
  /// This completes the handshake process, allowing the WebRTC connection to be established.
  Stream<String> get onAnswerReceived;

  /// Stream that emits when an ICE candidate is received from a remote peer.
  /// These candidates are necessary to establish the media path between peers.
  Stream<RTCIceCandidate> get onIceCandidateReceived;

  /// Stream that emits when the connection to the signaling server is successfully established.
  Stream<bool> get onConnected;

  /// Stream that emits when the connection to the signaling server is disconnected or fails.
  Stream<bool> get onDisconnected;
}
