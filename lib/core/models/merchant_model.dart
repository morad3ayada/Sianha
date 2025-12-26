class MerchantModel {
  final String id;
  final String name;
  final String? description;
  final String? shopName;
  final String? userAccountFullName;
  final String? userAccountPhoneNumber;
  final List<String>? shopImages;
  final List<MerchantSubCategory> subCategories;
  final List<ProductModel> products;

  MerchantModel({
    required this.id,
    required this.name,
    this.description,
    this.shopName,
    this.userAccountFullName,
    this.userAccountPhoneNumber,
    this.shopImages,
    required this.subCategories,
    required this.products,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      shopName: json['shopName'],
      userAccountFullName: json['userAccountFullName'],
      userAccountPhoneNumber: json['userAccountPhoneNumber'],
      shopImages: (json['shopImages'] as List<dynamic>?)
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  // Fix: Extract imageUrl from object
                  final url = item['imageUrl']?.toString() ?? '';
                  print('🔍 Parsed Shop Image Object: $url'); // DEBUG
                  return url;
                }
                print('🔍 Parsed Shop Image String: $item'); // DEBUG
                return item.toString();
              })
              .where((item) => item.isNotEmpty)
              .toList() ??
          [],
      subCategories: (json['subCategories'] as List<dynamic>?)
              ?.map((item) => MerchantSubCategory.fromJson(item))
              .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shopName': shopName,
      'userAccountFullName': userAccountFullName,
      'userAccountPhoneNumber': userAccountPhoneNumber,
      'shopImages': shopImages,
      'subCategories': subCategories.map((item) => item.toJson()).toList(),
      'products': products.map((item) => item.toJson()).toList(),
    };
  }

  List<String> get fullShopImages {
    if (shopImages == null) return [];
    return shopImages!.map((url) {
      if (url.startsWith('http')) return url;
      // Normalize path separators
      var path = url.replaceAll('\\', '/');
      path = path.startsWith('/') ? path.substring(1) : path;
      final fullUrl = 'https://api.khidma.shop/$path';
      print('📸 Shop Image Full URL: $fullUrl'); // DEBUG LOG
      return fullUrl;
    }).toList();
  }
}

class MerchantSubCategory {
  final String id; // This is likely the serviceSubCategoryId
  final String serviceCategoryId;
  final String serviceCategoryName;
  final String name;
  final String? description;

  MerchantSubCategory({
    required this.id,
    required this.serviceCategoryId,
    required this.serviceCategoryName,
    required this.name,
    this.description,
  });

  factory MerchantSubCategory.fromJson(Map<String, dynamic> json) {
    return MerchantSubCategory(
      id: json['id'] ?? '', // Capture the ID
      serviceCategoryId: json['serviceCategoryId'] ?? '',
      serviceCategoryName: json['serviceCategoryName'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceCategoryId': serviceCategoryId,
      'serviceCategoryName': serviceCategoryName,
      'name': name,
      'description': description,
    };
  }
}

class MerchantCategory {
  final String serviceCategoryId;
  final String serviceCategoryName;
  final int merchantCount;

  MerchantCategory({
    required this.serviceCategoryId,
    required this.serviceCategoryName,
    required this.merchantCount,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
  });

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    // Normalize path separators
    var path = imageUrl!.replaceAll('\\', '/');
    path = path.startsWith('/') ? path.substring(1) : path;
    return 'https://api.khidma.shop/$path';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

class SelectedProduct {
  final ProductModel product;
  int quantity;

  SelectedProduct({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
