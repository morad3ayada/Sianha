class ServiceSubCategory {
  final String id;
  final String name;
  final String serviceCategoryId;
  final String? description;
  final String? imageUrl;

  ServiceSubCategory({
    required this.id,
    required this.name,
    required this.serviceCategoryId,
    this.description,
    this.imageUrl,
  });

  factory ServiceSubCategory.fromJson(Map<String, dynamic> json) {
    return ServiceSubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      serviceCategoryId: json['serviceCategoryId']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(), // Assuming API might return image, otherwise null
    );
  }
}
