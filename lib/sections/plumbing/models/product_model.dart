class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final String category;
  final String brand;
  final bool inStock;
  final double discount;
  final String storage;
  final String color;
  final String memory;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.brand,
    required this.inStock,
    required this.discount,
    required this.storage,
    required this.color,
    required this.memory,
  });

  double get discountedPrice => price * (1 - discount);
}
