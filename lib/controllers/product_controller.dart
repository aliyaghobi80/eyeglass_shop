import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ProductController extends GetxController {
  final products = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final error = RxString('');
  late IOWebSocketChannel channel;
  late IOWebSocketChannel categoryChannel;
  final ApiService apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    initWebSocket();
    initCategoryWebSocket();
    fetchInitialData();
  }

  @override
  void onClose() {
    channel.sink.close();
    categoryChannel.sink.close();
    super.onClose();
  }

  Future<Map<String, String>> get _headers async {
    final token = await apiService.getValidAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept-Charset': 'utf-8',
    };
  }

  Future<void> initWebSocket() async {
    try {
      final token = await apiService.getValidAccessToken();
      channel = IOWebSocketChannel.connect(
        'ws://87.248.155.142/ws/products/',
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      );

      channel.stream.listen(
            (message) {
          try {
            final data = jsonDecode(utf8.decode(message.toString().codeUnits));

            if (data['action'] == 'delete') {
              products.removeWhere(
                    (p) => p['id'].toString() == data['product_id'].toString(),
              );
            } else if (data['action'] == 'add') {
              products.add(data['product']);
            } else if (data['action'] == 'update') {
              final index = products.indexWhere(
                    (p) => p['id'].toString() == data['product']['id'].toString(),
              );
              if (index != -1) {
                products[index] = data['product'];
              }
            }
          } catch (e) {
            error.value = 'خطا در پردازش پیام وب‌سوکت';
          }
        },
        onError: (error) {
          Future.delayed(const Duration(seconds: 5), initWebSocket);
        },
        onDone: () {
          Future.delayed(const Duration(seconds: 5), initWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), initWebSocket);
    }
  }

  Future<void> initCategoryWebSocket() async {
    try {
      final token = await apiService.getValidAccessToken();
      categoryChannel = IOWebSocketChannel.connect(
        'ws://87.248.155.142/ws/categories/',
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      );

      categoryChannel.stream.listen(
            (message) {
          try {
            final data = jsonDecode(utf8.decode(message.toString().codeUnits));

            if (data['action'] == 'delete') {
              categories.removeWhere(
                    (c) => c['id'].toString() == data['category_id'].toString(),
              );
            } else if (data['action'] == 'add') {
              categories.add(data['category']);
            } else if (data['action'] == 'update') {
              final index = categories.indexWhere(
                    (c) => c['id'].toString() == data['category']['id'].toString(),
              );
              if (index != -1) {
                categories[index] = data['category'];
              }
            }
          } catch (e) {
            error.value = 'خطا در پردازش پیام وب‌سوکت دسته‌بندی';
          }
        },
        onError: (error) {
          Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
        },
        onDone: () {
          Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
    }
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    await Future.wait([fetchProducts(), fetchCategories()]);
    isLoading.value = false;
  }

  Future<void> fetchProducts() async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('http://87.248.155.142/api/product_list/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedData['products'] != null) {
          products.value = List<Map<String, dynamic>>.from(
            decodedData['products'],
          );
        }
      } else {
        error.value = 'خطا در دریافت محصولات';
      }
    } catch (e) {
      error.value = 'خطا در دریافت محصولات';
    }
  }

  Future<void> fetchCategories() async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('http://87.248.155.142/api/categories/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedData['categories'] != null) {
          categories.value = List<Map<String, dynamic>>.from(
            decodedData['categories'],
          );
        }
      }
    } catch (e) {
      error.value = 'خطا در دریافت دسته‌بندی‌ها';
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required int price,
    required int salePrice,
    required bool isSale,
    required bool isAvailable,
    required File image,
    required int category,
  }) async {
    try {
      isLoading.value = true;
      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'sale_price': salePrice,
        'is_sale': isSale,
        'is_available': isAvailable,
        'category': category,
        'image': image,
      };

      await apiService.addProduct(productData);
      await fetchProducts();
      Get.snackbar(
        'موفقیت',
        'محصول با موفقیت اضافه شد',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در افزودن محصول: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(Map<String, dynamic> product) async {
    try {
      isLoading.value = true;
      await apiService.updateProduct(product['id'], product);
      await fetchProducts();
      Get.snackbar('موفقیت', 'محصول با موفقیت به‌روزرسانی شد');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در به‌روزرسانی محصول: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      await apiService.deleteProduct(productId);
      await fetchProducts();
      Get.snackbar('موفقیت', 'محصول با موفقیت حذف شد');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در حذف محصول: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
