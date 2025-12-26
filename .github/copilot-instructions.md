# Sianha - AI Coding Agent Instructions

## Project Overview
**Sianha** is a Flutter-based Arabic service marketplace app connecting customers with merchants/technicians. The architecture follows a service-model-screen pattern with centralized API communication.

### Core Tech Stack
- **Framework**: Flutter 3.0+
- **State Management**: Provider 6.1.1
- **HTTP Client**: http 1.1.0 + custom ApiClient wrapper
- **Routing**: go_router 12.1.0
- **Storage**: shared_preferences, sqflite
- **Location**: geolocator, geocoding, google_maps_flutter
- **Media**: image_picker, cached_network_image

---

## Architecture & Data Flow

### Service Layer (`lib/core/services/`)
Services are the ONLY entry point for API calls. Example: [MerchantService](lib/core/services/merchant_service.dart)

**Key Pattern**:
```dart
class MerchantService {
  final ApiClient _apiClient = ApiClient();
  static const String _token = 'eyJhbGc...'; // Hardcoded JWT - improve later
  
  Future<List<MerchantModel>> fetchMerchantsWithProducts() async {
    // Calls _apiClient.get() with full URL from api_constants
    // Handles response parsing and error handling
  }
}
```

**Critical Rule**: Always inject ApiClient through constructor in production code (currently hardcoded token is a tech debt).

### Model Layer (`lib/core/models/`)
Immutable data classes with `fromJson()` and `toJson()` factories:
- [MerchantModel](lib/core/models/merchant_model.dart) - contains products + subCategories
- [ProductModel](lib/core/models/merchant_model.dart#L133) - product with price/description
- [ServiceCategory/SubCategory](lib/core/models/service_category_model.dart)
- [AreaModel](lib/core/models/area_model.dart)

**Special Handler**: `fullShopImages` getter in MerchantModel constructs full URLs from relative paths:
```dart
List<String> get fullShopImages {
  return shopImages!.map((url) {
    if (url.startsWith('http')) return url;
    return 'https://api.khidma.shop/' + url;
  }).toList();
}
```

### Screen Architecture
Screens follow State pattern with initialization in `initState()`. Example: [MerchantDetailsScreen](lib/sections/merchants/merchant_details_screen.dart)

**Common Pattern**:
- Load data in `initState()` via service → `setState()` to update UI
- Error states with retry buttons
- Loading indicators using CircularProgressIndicator
- RTL-aware Arabic text styling

**Navigation**: Use MaterialPageRoute, not go_router (inconsistently configured).

---

## Critical Implementation Patterns

### Data Loading Pattern
```dart
@override
void initState() {
  super.initState();
  _loadMerchantDetails();
}

Future<void> _loadMerchantDetails() async {
  try {
    final merchant = await _merchantService.getMerchantById(widget.merchantId);
    if (mounted) {
      setState(() {
        _merchant = merchant;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

### API Communication ([ApiClient](lib/core/api/api_client.dart))
- **GET requests**: `_apiClient.get(fullUrl, token: _token)`
- **POST JSON**: `_apiClient.post(endpoint, body: {...}, token: _token)`
- **Multipart (images)**: `_apiClient.postMultipart(endpoint, fields: {...}, file: file)`
- **Response handling**: Automatically parses JSON; throws on non-2xx status
- **Headers**: Adds `Authorization: Bearer {token}` when token provided

### Screen State Management
**Selected Products Pattern** (from [MerchantDetailsScreen](lib/sections/merchants/merchant_details_screen.dart#L85)):
```dart
class SelectedProduct {
  final ProductModel product;
  int quantity;
  double get totalPrice => product.price * quantity;
}

final List<SelectedProduct> _selectedProducts = [];
```

### UI Styling Conventions
- **Yellow/Amber Theme**: Colors.yellow[700] for primary actions
- **RTL Support**: Arabic text styled with explicit Colors.black87/white
- **Error Display**: Icon + text + retry button in Column
- **Cards**: Container with BoxDecoration, gradient backgrounds, shadow effects
- **Images**: Network loading with CircularProgressIndicator + error fallback

---

## Project Structure by Role

### Customer Flow
`/homeSections` → Category Browse → [MerchantDetailsScreen](lib/sections/merchants/merchant_details_screen.dart) → OrderConfirmationScreen → Checkout

### Merchant/Technician Flow
`/loginTechnician` → [TechnicianHomeScreen](lib/technician_Trader/Technician/technician_home_screen.dart) or [TraderHomeScreen](lib/technician_Trader/Merchant/trader_home_screen.dart)

### Sections (Service Categories)
Organized by `/lib/sections/{category}/`:
- `merchants/` - Merchant listings and details
- `electronics/` - Electronics service providers
- `plumbing/` - Plumbing services
- `maintenance/` - Maintenance services
- `mobile/` - Mobile services

---

## Testing & Development

### Build & Run
```bash
flutter pub get
flutter run
```

### Debug Print Pattern
Heavy use of print() for debugging network requests:
```dart
print('❌ ERROR Loading Image: $imageUrl');
print('📸 Shop Image Full URL: $fullUrl');
print('🔍 Parsed Shop Image Object: $url');
```

### Known Issues & Tech Debt
1. **Hardcoded JWT token** in MerchantService - requires secure token management
2. **Mixed navigation**: MaterialPageRoute + go_router not consistently used
3. **Image URL normalization**: Manual path construction instead of centralized formatter
4. **Missing error types**: Generic Exception catching throughout

---

## When Adding Features

1. **New API endpoint?** → Add to [ApiConstants](lib/core/api/api_constants.dart) → Create/extend Service
2. **New model?** → Add to [models/](lib/core/models/) with fromJson/toJson
3. **New screen?** → Follow [MerchantDetailsScreen](lib/sections/merchants/merchant_details_screen.dart) pattern
4. **New merchant category?** → Create folder in `/lib/sections/{category}/`
5. **Data flows?** → Service → Model → Screen with `if (mounted)` checks

---

## Code Examples
- **Full merchant + product fetching**: [MerchantService.fetchMerchantsWithProducts()](lib/core/services/merchant_service.dart#L11)
- **Category extraction**: [MerchantService.getMerchantCategories()](lib/core/services/merchant_service.dart#L27)
- **Complete order flow**: [MerchantDetailsScreen → OrderConfirmationScreen](lib/sections/merchants/merchant_details_screen.dart#L510)
- **Image handling with fallback**: [MerchantDetailsScreen._buildShopImages()](lib/sections/merchants/merchant_details_screen.dart#L255)
