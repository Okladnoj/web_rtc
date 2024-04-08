import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../configs/constants.dart';
import '../../controllers/conference_controller.dart';
import '../../gen/assets.gen.dart';
import '../../models/room/conference_model.dart';
import '../../services/manager/signal_manager_service.dart';
import '../../views/app_loader.dart';
import '../room/room_page.dart';
import 'rooms_core.dart';
import 'views/create_room_dialog.dart';

class RoomsListScreen extends StatefulWidget {
  final RoomsCore roomsCore;

  const RoomsListScreen({super.key, required this.roomsCore});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  Future<void> _showCreateRoomDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CreateRoomDialog(createRoom: _createRoom);
      },
    );
  }

  Future<void> _createRoom(String text) async {
    await widget.roomsCore.createRoom(text).catchError((error, stack) {
      log('createRoom', error: error, stackTrace: stack);
    });
  }

  Future<void> _deleteRoom(ConferenceModel room) async {
    await widget.roomsCore.removeRoom(room).catchError((error, stack) {
      log('removeRoom', error: error, stackTrace: stack);
    });
  }

  void _openRoom(ConferenceModel room) async {
    final uid = widget.roomsCore.uID;
    const ctx = AppConstants.mediaConstraints;
    final localMedia = await navigator.mediaDevices.getUserMedia(ctx);
    final managerService = SignalingManagerFirebaseService(room, uid);
    if (!mounted) return;

    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      final controller = ConferenceController(managerService, localMedia);
      return CoreRoomPage(controller: controller);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Rooms')),
      body: Stack(
        children: [
          Assets.images.background.image(
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          _buildRooms(),
          _buildLoader(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoomDialog,
        tooltip: 'Create Room',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoader() {
    return StreamBuilder(
        stream: widget.roomsCore.observerLoading,
        builder: (_, snapshot) {
          if (snapshot.data == true) return const AppLoader();

          return const SizedBox.shrink();
        });
  }

  Widget _buildRooms() {
    return StreamBuilder(
      stream: widget.roomsCore.roomsLiveStream,
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];

        if (rooms.isEmpty) return _buildNoRooms();

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _buildRoomItem(room);
          },
        );
      },
    );
  }

  Widget _buildNoRooms() {
    return const Center(child: Text('No rooms available'));
  }

  Widget _buildRoomItem(ConferenceModel room) {
    return ListTile(
      title: Text(room.name),
      onTap: () => _openRoom(room),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteRoom(room),
      ),
    );
  }
}
