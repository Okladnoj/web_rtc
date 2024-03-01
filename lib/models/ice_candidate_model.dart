class IceCandidateModel {
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;

  IceCandidateModel({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });

  Map<String, dynamic> toJson() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      };

  factory IceCandidateModel.fromJson(Map<String, dynamic> json) {
    return IceCandidateModel(
      candidate: json['candidate'],
      sdpMid: json['sdpMid'],
      sdpMLineIndex: json['sdpMLineIndex'],
    );
  }
}
