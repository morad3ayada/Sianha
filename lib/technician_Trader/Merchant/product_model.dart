// product_model.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Product {
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int stockQuantity;
  final String category;
  final String condition;
  final List<XFile> images;

  Product({
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice = 0.0,
    required this.stockQuantity,
    required this.category,
    required this.condition,
    this.images = const [],
  });

  // دالة مساعدة لتحويل الـ XFile إلى File
  List<File> get imageFiles => images.map((xFile) => File(xFile.path)).toList();
}
