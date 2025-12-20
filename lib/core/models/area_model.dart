class AreaModel {
  final String id;
  final String name;
  final String governorateId;
  final String governorateName;

  AreaModel({
    required this.id,
    required this.name,
    required this.governorateId,
    required this.governorateName,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      governorateId: json['governorateId']?.toString() ?? '',
      governorateName: json['governorateName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorateId': governorateId,
      'governorateName': governorateName,
    };
  }
}

class GovernorateWithAreas {
  final String governorateId;
  final String governorateName;
  final List<AreaModel> areas;

  GovernorateWithAreas({
    required this.governorateId,
    required this.governorateName,
    required this.areas,
  });
}
