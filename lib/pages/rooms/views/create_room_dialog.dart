import 'package:flutter/material.dart';

class CreateRoomDialog extends StatefulWidget {
  final ValueSetter<String> createRoom;

  const CreateRoomDialog({
    super.key,
    required this.createRoom,
  });

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _controller = TextEditingController();

  void _createRoom() {
    if (_controller.text.isEmpty) return;

    widget.createRoom(_controller.text);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a new room'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const Text('Please enter the name of the room.'),
            TextField(controller: _controller),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _createRoom,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
