import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../../models/room/conference_model.dart';
import '../../models/rtc/session_description_model.dart';
import '../rtc/signal_service.dart';

abstract class SignalingManagerService {
  final ConferenceModel room;
  final String userIdLocal;

  SignalingManagerService(this.room, this.userIdLocal);

  Future<void> createUserNode();

  Future<void> removeUserNode();

  Future<void> listenRemoteNodes(AsyncValueSetter<String> onNewConnection);

  Future<void> listenRemoteDeleteNode(ValueSetter<String> onDeleteConnection);

  Future<void> listenOwnNodes(DescCallBack onNewConnection);

  String get connectionUrl => 'rooms/${room.id}';
}

class SignalingManagerFirebaseService extends SignalingManagerService {
  final DatabaseReference _dbRef;
  final _subs = <StreamSubscription<DatabaseEvent>>[];

  SignalingManagerFirebaseService(super.room, super.userIdLocal)
      : _dbRef = FirebaseDatabase.instance.ref('rooms/${room.id}');

  @override
  Future<void> createUserNode() async {
    var node = _dbRef //
        .child(_users)
        .child(userIdLocal);

    await node.set({'id': userIdLocal, 'name': 'userIdLocal'});
  }

  @override
  Future<void> removeUserNode() async {
    for (var sub in _subs) {
      await sub.cancel();
    }

    await _dbRef //
        .child(_users)
        .child(userIdLocal)
        .remove();
  }

  @override
  Future<void> listenRemoteNodes(onNewConnection) async {
    bool canProcessEvents = false;

    Future.delayed(const Duration(milliseconds: 150), () {
      canProcessEvents = true;
    });

    final sub = _dbRef //
        .child(_users)
        .onChildAdded
        .listen((event) async {
      if (!canProcessEvents) return;
      final value = event.snapshot.value;
      if (value is! Map) return;
      final id = value['id'];
      if (id is! String || id.isEmpty) return;
      if (userIdLocal == id) return;
      await onNewConnection(id);
    });
    _subs.add(sub);
  }

  @override
  Future<void> listenRemoteDeleteNode(onDeleteConnection) async {
    bool canProcessEvents = false;

    Future.delayed(const Duration(milliseconds: 150), () {
      canProcessEvents = true;
    });

    _dbRef //
        .child(_users)
        .onChildRemoved
        .listen((event) async {
      if (!canProcessEvents) return;
      final value = event.snapshot.value;
      if (value is! Map) return;
      final id = value['id'];
      if (id is! String || id.isEmpty) return;
      if (userIdLocal == id) return;
      onDeleteConnection(id);
    });
  }

  @override
  Future<void> listenOwnNodes(onNewConnection) async {
    final sub = _dbRef //
        .child(_users)
        .child(userIdLocal)
        .child(_remoteUsers)
        .onChildAdded
        .listen((event) async {
      final value = event.snapshot.value;
      if (value is! Map) return;
      final map = Map<String, dynamic>.from(value['offer']);
      final data = SessionDescriptionModel.fromJson(map);
      if (data.peerId == userIdLocal) return;
      await onNewConnection(data);
    });
    _subs.add(sub);
  }

  static const _users = 'users';
  static const _remoteUsers = 'remote_users';
}
