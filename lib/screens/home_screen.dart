import 'package:auto_size_text/auto_size_text.dart';
import 'package:eyewear/controllers/product_controller.dart';
import 'package:eyewear/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {


  HomeScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه عینک'),
        centerTitle: true,
        actions: [],
      ),
      drawer: CustomDrawer(),
      body: Obx(() {
        if (productController.isLoading.value) {
          return Center(child: CircularProgressIndicator(),);
        }

        return RefreshIndicator(
          onRefresh: () => productController.fetchProducts(),
          child: productController.products.isEmpty
              ? _buildEmptyState()
              : ListView.builder(itemCount: productController.products.length,
              itemBuilder: (context, index) {
                final product = productController.products[index];
                return _buildProductCard(product);
              }),);
      }),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text(
            'هیچ کالایی برای نمایش وجود ندارد',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.find<ProductController>().fetchProducts(),
            child: const Text('بارگذاری مجدد'),
          ),
        ],
      ),
    );
  }





  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Get.toNamed('/product-details', arguments: product),
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${Constants.baseUrl}${product['image']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              product['name']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            AutoSizeText(
                              product['description']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product['is_sale'] == true) ...[
                                  Text(
                                    '${product['price']} تومان',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  '${product['is_sale'] == true ? product['sale_price'] : product['price']} تومان',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    product['is_sale'] == true
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product['is_available'] == true
                                      ? 'موجود'
                                      : 'ناموجود',
                                  style: TextStyle(
                                    color:
                                    product['is_available'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                  product['is_available'] == true
                                      ? () {
                                    Get.snackbar(
                                      'اضافه به سبد خرید',
                                      'این قابلیت به زودی اضافه خواهد شد',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.blue,
                                      colorText: Colors.white,
                                    );
                                  }
                                      : null,
                                  icon: Icon(
                                    Icons.shopping_cart,
                                    color:
                                    product['is_available'] == true
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (product['is_sale'] == true)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '${((double.parse(product['price']) - double.parse(product['sale_price'])) / double.parse(product['price']) * 100).round()}% تخفیف ویژه',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

