class RoomState {
  final bool speak;

  RoomState({
    this.speak = false,
  });

  RoomState copyWith({
    bool? speak,
  }) {
    return RoomState(
      speak: speak ?? this.speak,
    );
  }
}
