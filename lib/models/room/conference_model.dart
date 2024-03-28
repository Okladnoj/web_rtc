class ConferenceModel {
  final String id;
  final String name;

  ConferenceModel({required this.id, required this.name});

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    return ConferenceModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
