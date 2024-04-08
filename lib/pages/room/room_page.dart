import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../controllers/conference_controller.dart';
import '../../gen/assets.gen.dart';
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
      appBar: AppBar(title: Text(name)),
      body: StreamBuilder<bool>(
        stream: widget.controller.loading,
        builder: (context, snapshot) {
          if (snapshot.data == true) return const AppLoader();

          return Stack(
            children: [
              Assets.images.background.image(
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(child: _buildContent()),
                  _buildButtons(),
                ],
              ),
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
        final enabled = widget.controller.enabled;
        const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        );
        return Column(
          children: [
            AnimatedOpacity(
              opacity: enabled ? 1 : 0.4,
              duration: const Duration(seconds: 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  height: size,
                  width: size,
                  color: Colors.deepOrangeAccent,
                  child: _buildLocalMedia(localRenderer),
                ),
              ),
            ),
            Expanded(
              child: remoteRenderers.isEmpty
                  ? _buildNoRemoteMedia()
                  : GridView(
                      gridDelegate: gridDelegate,
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
    return const Center(child: Text('No remote Media'));
  }

  Widget _buildLocalMedia(RTCVideoRenderer renderer) {
    if (renderer.srcObject == null) return _buildNoLocalMedia();
    return RTCVideoView(renderer, mirror: true);
  }

  Widget _buildRemoteMedia(RTCVideoRenderer renderer) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RTCVideoView(renderer),
    );
  }

  Widget _buildButtons() {
    final style = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepOrangeAccent,
    );
    return StreamBuilder<Object>(
        stream: widget.controller.onActivePeersChanged,
        builder: (context, snapshot) {
          final enabled = widget.controller.enabled;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: enabled ? style : null,
                  onPressed: widget.controller.speak,
                  child: const Text('Speak'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: !enabled ? style : null,
                  onPressed: widget.controller.stop,
                  child: const Text('Stop'),
                ),
              ],
            ),
          );
        });
  }
}
