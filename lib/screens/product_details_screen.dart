
import 'package:eyewear/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatelessWidget {
   ProductDetailsScreen({super.key});
  final Map<String,dynamic> product = Get.arguments as Map<String,dynamic>;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" محصول: ${product['name']?.toString() ?? ''}"),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                '${Constants.baseUrl}${product['image']}',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  );
                },
              ),
              if (product['is_sale'] == true)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_calculateDiscountPercentage(product)}% تخفیف ویژه',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(" نام محصول: ${product['name']?.toString() ?? ''}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(" توضیحات: ${product['description']?.toString() ?? ''}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product['is_sale'] == true) ...[
                        Row(
                          children: [
                            const Text(
                              'قیمت اصلی: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${product['price']} تومان',
                              style: const TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Text(
                            product['is_sale'] == true
                                ? 'قیمت با تخفیف: '
                                : 'قیمت: ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${product['is_sale'] == true ? product['sale_price'] : product['price']} تومان',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                              product['is_sale'] == true
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined),
                    const SizedBox(width: 8),
                    Text(
                      product['is_available'] == true
                          ? 'موجود در انبار'
                          : 'ناموجود',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                        product['is_available'] == true
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    product['is_available'] == true
                        ? () {
                      Get.snackbar(
                        'اطلاع‌رسانی',
                        'این قابلیت به زودی اضافه خواهد شد',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor:
                      product['is_available'] == true
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(
                      product['is_available'] == true
                          ? 'افزودن به سبد خرید'
                          : 'ناموجود',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
            ),
            ),
      ),
    );
  }


   double _calculateDiscountPercentage(Map<String, dynamic> product) {
     final price = double.parse(product['price']);
     final salePrice = double.tryParse(product['sale_price']) ;
     return ((price - salePrice!) / price * 100).round().toDouble();
   }


}
