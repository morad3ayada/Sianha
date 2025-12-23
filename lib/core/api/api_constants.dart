class ApiConstants {
  static const String baseUrl = "https://api.khidma.shop";
  
  // Auth Endpoints
  static const String login = "$baseUrl/api/Auth/login";
  static const String register = "$baseUrl/api/Auth/register";
  static const String registerCustomer = "$baseUrl/api/Auth/register/customer";
  static const String logout = "$baseUrl/api/Auth/logout";
  static const String profile = "$baseUrl/api/Users/profile";
  
  // Customer Endpoints
  static const String createOrder = "$baseUrl/api/Customers/create-order";
  static const String activeOrders = "$baseUrl/api/Customers/active-orders";
  static const String orderHistory = "$baseUrl/api/Customers/order-history";
  static const String myOrders = "$baseUrl/api/Customers/my-orders";
  static const String cancelOrder = "$baseUrl/api/Customers/cancel-order";
  static const String rateOrder = "$baseUrl/api/Customers/rate-order";
  static const String merchantsWithProducts = "$baseUrl/api/Customers/merchants-with-products";
  
  // Image Upload
  static const String uploadImage = "$baseUrl/api/Users/upload-profile-image";
  static const String changePassword = "$baseUrl/api/Users/change-password";
  
  static const String areas = "$baseUrl/api/Areas";
  static const String serviceCategories = "$baseUrl/api/ServiceCategories";
  static const String serviceSubCategories = "$baseUrl/api/ServiceSubCategories";
  static const String registerMerchant = "$baseUrl/api/Auth/register/merchant";
  static const String registerTechnician = "$baseUrl/api/Auth/register/technician";
  static const String technicianAssignedOrders = "$baseUrl/api/Technicians/assigned-orders";
  static const String acceptOrder = "$baseUrl/api/Technicians/accept-order";
  static const String rejectOrder = "$baseUrl/api/Technicians/reject-order";
  static const String technicianMyJobs = "$baseUrl/api/Technicians/my-jobs";
  static const String updateOrderStatus = "$baseUrl/api/Technicians/update-order-status";
  static const String technicianMyStats = "$baseUrl/api/Technicians/my-stats";
  static const String myShop = "$baseUrl/api/Merchants/my-shop";
  static const String shopOrders = "$baseUrl/api/Merchants/shop-orders";
  static const String merchantUpdateOrderStatus = "$baseUrl/api/Merchants/update-order-status";
  static const String merchantAcceptOrder = "$baseUrl/api/Merchants/accept-order";
  static const String merchantRejectOrder = "$baseUrl/api/Merchants/reject-order";
  static const String merchantAddProduct = "$baseUrl/api/Merchants/products";
  static const String merchantProductSearch = "$baseUrl/api/Merchants/products/search";
  static const String updateShopInfo = "$baseUrl/api/Merchants/update-shop-info";
  static const String addShopImage = "$baseUrl/api/Merchants/add-shop-image";
  static const String deleteShopImage = "$baseUrl/api/Merchants/delete-shop-image";
  static const String createReport = "$baseUrl/api/Reports";
}
