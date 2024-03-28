abstract class AppConstants {
  // WebRTC configuration (STUN/TURN servers)
  static const peerConfiguration = {
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
