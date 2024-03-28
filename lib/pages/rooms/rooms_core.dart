// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import '../../models/room/conference_model.dart';
import '../../services/auth/auth_anonymous.dart';
import '../../services/rooms/rooms_service.dart';

class RoomsCore {
  final _roomsService = RoomsService();
  final _authService = AuthAnonymous();
  late final String uID;

  RoomsCore() {
    _init();
  }

  final _controllerLoading = StreamController<bool>.broadcast();
  StreamSink<bool> get sinkLoading => _controllerLoading.sink;
  Stream<bool> get observerLoading => _controllerLoading.stream;

  Future<void> _init() async {
    _loading();
    uID = await _authService.uID;
    _loaded();
  }

  Future<void> createRoom(String roomName) async {
    _loading();
    try {
      await _roomsService.createRoom(roomName);
    } catch (_) {}

    _loaded();
  }

  Future<void> removeRoom(ConferenceModel room) async {
    _loading();
    try {
      await _roomsService.removeRoom(room);
    } catch (_) {}

    _loaded();
  }

  Stream<List<ConferenceModel>> get roomsLiveStream =>
      _roomsService.roomsLiveStream;

  void _loading() => sinkLoading.add(true);

  void _loaded() => sinkLoading.add(false);
}
