class OfferModel {
  final String sdp;
  final String type;

  OfferModel({required this.sdp, required this.type});

  Map<String, dynamic> toJson() => {
        'sdp': sdp,
        'type': type,
      };

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      sdp: json['sdp'],
      type: json['type'],
    );
  }
}
