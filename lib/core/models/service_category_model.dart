import '../api/api_constants.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String? imageUrl;

  ServiceCategory({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['imagePath']?.toString() ?? json['image']?.toString(),
    );
  }

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    
    final baseUrl = ApiConstants.baseUrl;
    if (baseUrl.endsWith('/') && imageUrl!.startsWith('/')) {
      return baseUrl + imageUrl!.substring(1);
    } else if (!baseUrl.endsWith('/') && !imageUrl!.startsWith('/')) {
      return "$baseUrl/$imageUrl";
    } else {
      return "$baseUrl$imageUrl";
    }
  }
}
