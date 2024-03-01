import 'package:firebase_database/firebase_database.dart';

import '../models/answer_model.dart';
import '../models/ice_candidate_model.dart';
import '../models/offer_model.dart';

class SignalingService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  void sendOffer(OfferModel offer) {
    _databaseRef.child('offers').push().set(offer.toJson());
  }

  void listenForAnswer(void Function(AnswerModel answer) onAnswer) {
    _databaseRef.child('answers').onValue.listen((event) {
      final answerData = event.snapshot.value as Map<String, dynamic>?;
      if (answerData != null) {
        final answer = AnswerModel.fromJson(answerData);
        onAnswer(answer);
      }
    });
  }

  void sendIceCandidate(IceCandidateModel candidate) {
    _databaseRef.child('candidates').push().set(candidate.toJson());
  }

  void listenForIceCandidates(
      void Function(IceCandidateModel candidate) onCandidate) {
    _databaseRef.child('candidates').onValue.listen((event) {
      final candidatesData = event.snapshot.value as Map<String, dynamic>?;
      if (candidatesData != null) {
        candidatesData.forEach((key, value) {
          final candidate = IceCandidateModel.fromJson(value);
          onCandidate(candidate);
        });
      }
    });
  }
}
