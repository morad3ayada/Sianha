import 'product_model.dart';

class Shop {
  final String id;
  final String name;
  final String location;
  final double rating;
  final List<Product> products;
  final String imageUrl;
  final bool isVerified;
  final bool isOpen;
  final String specialOffers;
  final int reviewCount;
  final String deliveryTime;
  final double minOrder;
  final List<String> categories;

  Shop({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.products,
    required this.imageUrl,
    required this.isVerified,
    required this.isOpen,
    required this.specialOffers,
    required this.reviewCount,
    required this.deliveryTime,
    required this.minOrder,
    required this.categories,
  });
}
