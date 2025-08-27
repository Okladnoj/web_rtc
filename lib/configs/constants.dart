abstract class AppConstants {
  // WebRTC configuration (STUN/TURN servers)
  static const peerConfiguration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }, // STUN servers
      {
        'urls': [
          'turn:193.23.249.198:3478',
        ],
        'username': 'testuser',
        'credential': 'testpass',
      }, // TURN server
    ]
  };

  // Constraints for the peer connection
  static const peerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  // Constraints for the Local Media connection
  static const mediaConstraints = {
    'audio': true, // Enable audio
    'video': true, // Disable video
  };
}
