class Constants {
  static const String baseUrl = 'http://87.248.155.142';

  // Authentication endpoints
  static const String loginUrl = '$baseUrl/api/login/';
  static const String registerUrl = '$baseUrl/api/signup/';
  static const String logoutUrl = '$baseUrl/api/logout/';
  static const String refreshTokenUrl = '$baseUrl/api/token/refresh/';

  // Product endpoints
  static const String productUrl = '$baseUrl/api/product_list/';
  static const String addProductUrl = '$baseUrl/api/add_product/';
  static const String getProductUrl = '$baseUrl/api/product/';
  static const String deleteProductUrl = '$baseUrl/api/delete_product/';
  static const String editProductUrl = '$baseUrl/api/edit_product/';

  // Category endpoints
  static const String categoriesUrl = '$baseUrl/api/categories/';
  static const String addCategoryUrl = '$baseUrl/api/add_category/';
  static const String editCategoryUrl = '$baseUrl/api/edit_category/';
  static const String deleteCategoryUrl = '$baseUrl/api/delete_category/';

  // Helper method for getting product-specific URLs
  static String getProductDetailUrl(int productId) =>
      '$getProductUrl$productId/';
  static String getDeleteProductUrl(int productId) =>
      '$deleteProductUrl$productId/';
  static String getEditProductUrl(int productId) =>
      '$editProductUrl$productId/';

  // Helper method for getting category-specific URLs
  static String getEditCategoryUrl(int categoryId) =>
      '$editCategoryUrl$categoryId/';
  static String getDeleteCategoryUrl(int categoryId) =>
      '$deleteCategoryUrl$categoryId/';
}
