class AnswerModel {
  final String sdp;
  final String type;

  AnswerModel({required this.sdp, required this.type});

  Map<String, dynamic> toJson() => {
        'sdp': sdp,
        'type': type,
      };

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      sdp: json['sdp'],
      type: json['type'],
    );
  }
}
