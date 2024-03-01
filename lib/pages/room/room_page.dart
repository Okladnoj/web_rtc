import 'dart:developer';

import 'package:flutter/material.dart';

import '../../views/app_loader.dart';
import 'room_core.dart';

class RoomPage extends StatefulWidget {
  final RoomCore coreRoom;

  const RoomPage({super.key, required this.coreRoom});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  void _speak() {
    widget.coreRoom.createOffer();
  }

  void _stop() {
    widget.coreRoom.stop();
  }

  @override
  void initState() {
    super.initState();
    widget.coreRoom.initWebRTC().catchError((error) {
      log('Error initializing WebRTC: $error');
    });
  }

  @override
  void dispose() {
    widget.coreRoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coreRoom.currentRoom.name), // Отображаем имя комнаты
      ),
      body: StreamBuilder<bool>(
        stream: widget.coreRoom.loading,
        builder: (context, snapshot) {
          if (snapshot.data == true) return const AppLoader();

          return Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text('Room: ${widget.coreRoom.currentRoom.name}'),
                  // MediaStream
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _speak,
                      child: const Text('Speak'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _stop,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
