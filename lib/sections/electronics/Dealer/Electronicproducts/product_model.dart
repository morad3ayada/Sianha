// lib/models/product_model.dart
import 'package:flutter/material.dart';

class Product {
  final String name;
  final IconData icon;
  final double price;
  final String description;

  Product({
    required this.name,
    required this.icon,
    required this.price,
    required this.description,
  });
}
