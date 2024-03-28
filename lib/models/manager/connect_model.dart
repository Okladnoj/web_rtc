import '../rtc/ice_candidate_model.dart';
import '../rtc/session_description_model.dart';

class ConnectModel {
  final SessionDescriptionModel offer;
  final SessionDescriptionModel answer;
  final List<IceCandidateModel> candidates;

  const ConnectModel({
    this.offer = const SessionDescriptionModel(),
    this.answer = const SessionDescriptionModel(),
    this.candidates = const [],
  });

  ConnectModel copyWith({
    SessionDescriptionModel? offer,
    SessionDescriptionModel? answer,
    List<IceCandidateModel>? candidates,
  }) {
    return ConnectModel(
      offer: offer ?? this.offer,
      answer: answer ?? this.answer,
      candidates: candidates ?? this.candidates,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'offer': offer.toJson(),
      'answer': answer.toJson(),
      'candidates': candidates.map((x) => x.toJson()).toList(),
    };
  }

  factory ConnectModel.fromJson(Map<String, dynamic> map) {
    return ConnectModel(
      offer: map['offer'] == null
          ? const SessionDescriptionModel()
          : SessionDescriptionModel.fromJson(
              map['offer'] as Map<String, dynamic>),
      answer: map['answer'] == null
          ? const SessionDescriptionModel()
          : SessionDescriptionModel.fromJson(
              map['answer'] as Map<String, dynamic>),
      candidates: map['candidates'] == null
          ? const []
          : List<IceCandidateModel>.from(
              (map['candidates'] as List).map<IceCandidateModel>(
                (x) => IceCandidateModel.fromJson(x as Map<String, dynamic>),
              ),
            ),
    );
  }

  @override
  String toString() =>
      'ConnectModel(offer: $offer, answer: $answer, candidates: $candidates)';
}
