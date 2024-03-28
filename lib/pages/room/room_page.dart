import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../controllers/conference_controller.dart';
import '../../views/app_loader.dart';

class CoreRoomPage extends StatefulWidget {
  final ConferenceController controller;

  const CoreRoomPage({super.key, required this.controller});

  @override
  State<CoreRoomPage> createState() => _CoreRoomPageState();
}

class _CoreRoomPageState extends State<CoreRoomPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    widget.controller.leaveConference();
    super.dispose();
  }

  void _init() async {
    await widget.controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.controller.conferenceName;
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: StreamBuilder<bool>(
        stream: widget.controller.loading,
        builder: (context, snapshot) {
          if (snapshot.data == true) return const AppLoader();

          return Column(
            children: [
              Expanded(child: _buildContent()),
              _buildButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return StreamBuilder<Object>(
      stream: widget.controller.onActivePeersChanged,
      builder: (context, snapshot) {
        final size = MediaQuery.of(context).size.width / 1.5;
        final localRenderer = widget.controller.localRenderer;
        final remoteRenderers = widget.controller.remoteRenderers;
        if (localRenderer.srcObject == null) return _buildNoLocalMedia();
        if (remoteRenderers.isEmpty) return _buildNoRemoteMedia();
        return Column(
          children: [
            Container(
              height: size,
              width: size,
              color: Colors.red.shade100,
              child: _buildLocalMedia(localRenderer),
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                children: [
                  ...remoteRenderers.map(_buildRemoteMedia),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoLocalMedia() {
    return const Center(child: Text('No local Media'));
  }

  Widget _buildNoRemoteMedia() {
    return const Center(child: Text('No remoute Media'));
  }

  Widget _buildLocalMedia(RTCVideoRenderer renderer) {
    return RTCVideoView(renderer, mirror: true);
  }

  Widget _buildRemoteMedia(RTCVideoRenderer renderer) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RTCVideoView(renderer),
    );
  }

  Widget _buildButtons() {
    return Padding(
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
    );
  }
}
