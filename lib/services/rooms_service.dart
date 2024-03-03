import 'package:firebase_database/firebase_database.dart';

import '../models/room/room_model.dart';

class RoomsService {
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref('rooms');

  Future<void> createRoom(String roomName) async {
    final newRoomRef = _roomsRef.push();
    final room = RoomModel(id: newRoomRef.key!, name: roomName);
    await newRoomRef.set(room.toJson());
  }

  Future<void> removeRoom(RoomModel room) async {
    final roomRef = _roomsRef.child(room.id);

    await roomRef.remove();
  }

  Stream<List<RoomModel>> get roomsLiveStream {
    return _roomsRef.onValue.map((event) {
      final roomsMap = event.snapshot.value;
      if (roomsMap is! Map) return [];
      final rooms = roomsMap.entries.map((entry) {
        return RoomModel.fromJson({
          'id': entry.key,
          ...entry.value,
        });
      }).toList();
      return rooms;
    });
  }
}
