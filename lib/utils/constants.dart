class Constants {
  static const String baseUrl = 'http://87.248.155.142';

  // Authentication endpoints
  static const String loginUrl = '$baseUrl/api/login/';
  static const String registerUrl = '$baseUrl/api/signup/';
  static const String logoutUrl = '$baseUrl/api/logout/';
  static const String refreshTokenUrl = '$baseUrl/api/token/refresh/';

  // Profile endpoints
  static const String profileUrl = '$baseUrl/api/profile/';
  static const String updateProfileUrl = '$baseUrl/api/profile/update/';

  // Product endpoints
  static const String productListUrl = '$baseUrl/api/product_list/';
  static const String addProductUrl = '$baseUrl/api/add_product/';
  static const String productUrl = '$baseUrl/api/product/';
  static const String deleteProductUrl = '$baseUrl/api/delete_product/';
  static const String editProductUrl = '$baseUrl/api/edit_product/';

  // Category endpoints
  static const String categoriesUrl = '$baseUrl/api/categories/';
  static const String addCategoryUrl = '$baseUrl/api/add_category/';
  static const String editCategoryUrl = '$baseUrl/api/edit_category/';
  static const String deleteCategoryUrl = '$baseUrl/api/delete_category/';

  // Cart endpoints
  static const String addToCartUrl = '$baseUrl/api/add_to_cart/';
  static const String viewCartUrl = '$baseUrl/api/view_cart/';

  // Order endpoints
  static const String recentOrdersUrl = '$baseUrl/api/recent_orders/';

  // Helper methods for getting resource-specific URLs
  static String getProductDetailUrl(int productId) =>
      '$productUrl$productId/';
  static String getDeleteProductUrl(int productId) =>
      '$deleteProductUrl$productId/';
  static String getEditProductUrl(int productId) =>
      '$editProductUrl$productId/';

  // Helper methods for category-specific URLs
  static String getEditCategoryUrl(int categoryId) =>
      '$editCategoryUrl$categoryId/';
  static String getDeleteCategoryUrl(int categoryId) =>
      '$deleteCategoryUrl$categoryId/';
}