import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
    widget.coreRoom.speak();
  }

  void _stop() {
    widget.coreRoom.stop();
  }

  @override
  void initState() {
    super.initState();
    widget.coreRoom.initWebRTC();
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
        title: Text(widget.coreRoom.currentRoom.name),
      ),
      body: StreamBuilder<bool>(
        stream: widget.coreRoom.loading,
        builder: (context, snapshot) {
          if (snapshot.data == true) return const AppLoader();

          final size = MediaQuery.of(context).size.width / 2.5;

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: size + 32,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<RTCVideoRenderer>(
                          stream: widget.coreRoom.localStream,
                          builder: (context, snapshot) {
                            final data = snapshot.data;

                            return Column(
                              children: [
                                Container(
                                  height: size,
                                  width: size,
                                  color: Colors.red.shade100,
                                  child: data == null
                                      ? null
                                      : RTCVideoView(data, mirror: true),
                                ),
                                const Text(
                                  'Local',
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        StreamBuilder<RTCVideoRenderer>(
                          stream: widget.coreRoom.remoteStream,
                          builder: (context, snapshot) {
                            final data = snapshot.data;

                            return Column(
                              children: [
                                Container(
                                  height: size,
                                  width: size,
                                  color: Colors.red.shade100,
                                  child: data == null
                                      ? null
                                      : RTCVideoView(data, mirror: true),
                                ),
                                const Text(
                                  'Remote',
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
