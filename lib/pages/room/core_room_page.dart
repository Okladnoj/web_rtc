import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../controllers/webrtc_controller.dart';
import '../../views/app_loader.dart';

class CoreRoomPage extends StatefulWidget {
  final WebRTCController controller;

  const CoreRoomPage({super.key, required this.controller});

  @override
  State<CoreRoomPage> createState() => _CoreRoomPageState();
}

class _CoreRoomPageState extends State<CoreRoomPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.controller.signalingService.room.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: StreamBuilder<bool>(
        stream: widget.controller.loading,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return const AppLoader();
          }

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
                        Column(
                          children: [
                            Container(
                              height: size,
                              width: size,
                              color: Colors.red.shade100,
                              child: RTCVideoView(
                                widget.controller.localRenderer,
                                mirror: true,
                              ),
                            ),
                            const Text(
                              'Local',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Container(
                              height: size,
                              width: size,
                              color: Colors.red.shade100,
                              child: RTCVideoView(
                                  widget.controller.remoteRenderer),
                            ),
                            const Text(
                              'Remote',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ],
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
                  children: [
                    ElevatedButton(
                      onPressed: widget.controller.speak,
                      child: const Text('Speak'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: widget.controller.stop,
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
