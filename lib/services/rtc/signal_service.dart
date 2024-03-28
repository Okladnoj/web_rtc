import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/rtc/ice_candidate_model.dart';
import '../../models/rtc/session_description_model.dart';

typedef DescCallBack = AsyncValueSetter<SessionDescriptionModel>;

typedef CandidateCallBack = AsyncValueSetter<IceCandidateModel>;

abstract class SignalingService {
  final String connectionUrl;
  final String userIdLocal;
  final String userIdRemote;

  SignalingService(
    this.connectionUrl,
    this.userIdLocal,
    this.userIdRemote,
  );

  Future<void> sendOfferToRemotePeerNode(SessionDescriptionModel description);

  Future<void> sendAnswerToRemotePeerNode(SessionDescriptionModel description);

  Future<void> sendAnswerToPeerNode(SessionDescriptionModel description);

  Future<void> sendCandidateToPeerNode(IceCandidateModel candidate);

  Future<void> sendCandidateToRemotePeerNode(IceCandidateModel candidate);

  Future<void> onNewOffer(DescCallBack callBack);

  Future<void> onRemoteAnswer(DescCallBack callBack);

  Future<void> onAnswer(DescCallBack callBack);

  Future<void> onCandidate(CandidateCallBack callBack);

  Future<void> onRemoteCandidate(CandidateCallBack callBack);

  Future<void> dispose();
}

class SignalingFirebaseService extends SignalingService {
  final DatabaseReference _dbRefLocal;
  final DatabaseReference _dbRefRemote;
  final _subs = <StreamSubscription<DatabaseEvent>>[];

  SignalingFirebaseService(
    super.connectionUrl,
    super.userIdLocal,
    super.userIdRemote,
  )   : _dbRefLocal = FirebaseDatabase.instance.ref(
          '$connectionUrl/$_users/$userIdLocal/$_remoteUsers/$userIdRemote',
        ),
        _dbRefRemote = FirebaseDatabase.instance.ref(
          '$connectionUrl/$_users/$userIdRemote/$_remoteUsers/$userIdLocal',
        );

  @override
  Future<void> dispose() async {
    for (var sub in _subs) {
      await sub.cancel();
    }
  }

  @override
  Future<void> sendOfferToRemotePeerNode(description) async {
    await _dbRefRemote //
        .child(_offer)
        .set(description.toJson());
  }

  @override
  Future<void> sendAnswerToRemotePeerNode(description) async {
    await _dbRefRemote //
        .child(_answer)
        .set(description.toJson());
  }

  @override
  Future<void> sendAnswerToPeerNode(description) async {
    await _dbRefLocal //
        .child(_answer)
        .set(description.toJson());
  }

  @override
  Future<void> sendCandidateToRemotePeerNode(candidate) async {
    await _dbRefRemote //
        .child(_candidates)
        .push()
        .set(candidate.toJson());
  }

  @override
  Future<void> sendCandidateToPeerNode(candidate) async {
    await _dbRefLocal //
        .child(_candidates)
        .push()
        .set(candidate.toJson());
  }

  @override
  Future<void> onNewOffer(callBack) async {
    final sub = _dbRefLocal //
        .child(_offer)
        .onValue
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final json = Map<String, dynamic>.from(value);
      await callBack(SessionDescriptionModel.fromJson(json));
    });
    _subs.add(sub);
  }

  @override
  Future<void> onRemoteAnswer(callBack) async {
    final sub = _dbRefRemote //
        .child(_answer)
        .endAt(null)
        .onValue
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final json = Map<String, dynamic>.from(value);
      await callBack(SessionDescriptionModel.fromJson(json));
    });
    _subs.add(sub);
  }

  @override
  Future<void> onAnswer(callBack) async {
    final sub = _dbRefLocal //
        .child(_answer)
        .endAt(null)
        .onValue
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final json = Map<String, dynamic>.from(value);
      await callBack(SessionDescriptionModel.fromJson(json));
    });
    _subs.add(sub);
  }

  @override
  Future<void> onRemoteCandidate(callBack) async {
    final sub = _dbRefRemote //
        .child(_candidates)
        .onChildAdded
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final json = Map<String, dynamic>.from(value);
      await callBack(IceCandidateModel.fromJson(json));
    });
    _subs.add(sub);
  }

  @override
  Future<void> onCandidate(callBack) async {
    final sub = _dbRefLocal //
        .child(_candidates)
        .onChildAdded
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final json = Map<String, dynamic>.from(value);
      await callBack(IceCandidateModel.fromJson(json));
    });
    _subs.add(sub);
  }

  static const _remoteUsers = 'remote_users';
  static const _users = 'users';
  static const _candidates = 'candidates';
  static const _offer = 'offer';
  static const _answer = 'answer';
}
