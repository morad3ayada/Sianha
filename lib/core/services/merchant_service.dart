import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/merchant_model.dart';
import '../models/area_model.dart';

class MerchantService {
  final ApiClient _apiClient = ApiClient();
  
  // Removed hardcoded token

  /// Fetch all merchants with their products from the API
  Future<List<MerchantModel>> fetchMerchantsWithProducts({String? token}) async {
    try {
      final response = await _apiClient.get(
        'https://api.khidma.shop/api/Customers/merchants-with-products',
        token: token,
      );

      if (response is List) {
        return response
            .map((json) => MerchantModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error fetching merchants: $e');
      rethrow;
    }
  }

  /// Extract unique merchant categories grouped by serviceCategoryId
  Future<List<MerchantCategory>> getMerchantCategories({String? token}) async {
    try {
      final merchants = await fetchMerchantsWithProducts(token: token);
      
      // Map to store unique categories by serviceCategoryId
      final Map<String, MerchantCategory> categoriesMap = {};

      for (var merchant in merchants) {
        for (var subCategory in merchant.subCategories) {
          final categoryId = subCategory.serviceCategoryId;
          
          if (!categoriesMap.containsKey(categoryId)) {
            categoriesMap[categoryId] = MerchantCategory(
              serviceCategoryId: categoryId,
              serviceCategoryName: subCategory.serviceCategoryName,
              merchantCount: 1,
            );
          } else {
            // Increment merchant count for this category
            final existing = categoriesMap[categoryId]!;
            categoriesMap[categoryId] = MerchantCategory(
              serviceCategoryId: existing.serviceCategoryId,
              serviceCategoryName: existing.serviceCategoryName,
              merchantCount: existing.merchantCount + 1,
            );
          }
        }
      }

      return categoriesMap.values.toList();
    } catch (e) {
      print('Error getting merchant categories: $e');
      rethrow;
    }
  }

  /// Get merchants filtered by serviceCategoryId
  Future<List<MerchantWithCategory>> getMerchantsByCategory(
      String serviceCategoryId, {String? token}) async {
    try {
      final merchants = await fetchMerchantsWithProducts(token: token);
      final List<MerchantWithCategory> filteredMerchants = [];

      for (var merchant in merchants) {
        for (var subCategory in merchant.subCategories) {
          if (subCategory.serviceCategoryId == serviceCategoryId) {
            filteredMerchants.add(MerchantWithCategory(
              merchantId: merchant.id,
              merchantName: merchant.shopName ?? merchant.name, // Priority to shopName
              serviceCategoryName: subCategory.serviceCategoryName,
              description: subCategory.description,
              serviceCategoryId: subCategory.serviceCategoryId,
              serviceSubCategoryId: subCategory.id,
            ));
          }
        }
      }

      return filteredMerchants;
    } catch (e) {
      print('Error getting merchants by category: $e');
      rethrow;
    }
  }

  /// Get merchant details by ID
  Future<MerchantModel?> getMerchantById(String merchantId, {String? token}) async {
    try {
      final merchants = await fetchMerchantsWithProducts(token: token);
      return merchants.firstWhere(
        (merchant) => merchant.id == merchantId,
        orElse: () => throw Exception('Merchant not found'),
      );
    } catch (e) {
      print('Error getting merchant by ID: $e');
      rethrow;
    }
  }

  /// Fetch list of areas
  Future<List<AreaModel>> getAreas({String? token}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.areas,
        token: token,
      );

      if (response is List) {
        return response.map((json) => AreaModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format for areas');
      }
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }

  /// Create a new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, {String? token}) async {
    try {
      print('🚀 Creating Order with data: $orderData'); // DEBUG
      
      final response = await _apiClient.post(
        ApiConstants.createOrder,
        orderData,
        token: token,
      );
      
      print('✅ Order Created Successfully: $response'); // DEBUG
      return response;
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }
}

/// Helper class to represent a merchant with its category information
class MerchantWithCategory {
  final String merchantId;
  final String merchantName;
  final String serviceCategoryName;
  final String? description;
  final String serviceCategoryId;
  final String serviceSubCategoryId;

  MerchantWithCategory({
    required this.merchantId,
    required this.merchantName,
    required this.serviceCategoryName,
    this.description,
    required this.serviceCategoryId,
    required this.serviceSubCategoryId,
  });
}
