import 'package:eyewear/utils/constants.dart';
import 'package:eyewear/widgets/static_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find();

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("سبد خرید")),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartController.cartItems[index];
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListTile(
                      leading: SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.network(
                          '${Constants.baseUrl}${product.image}',
                          width: 200,
                          height: 122,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        ' قیمت: ${"${product.isSale ? product.salePrice : product.price}".seRagham()} تومان ',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          cartController.removeFromCart(product);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Get.isDarkMode ? Colors.grey[900] : Colors.purple,
            ),
            padding: EdgeInsets.all(15),
            child: Column(
              spacing: 10,
              children: [
                Obx(
                  () => RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'مجموع: '),
                        TextSpan(
                          text: '${cartController.totalPrice}'.seRagham(),
                          style: TextStyle(color: Colors.green.shade300),
                        ),
                        TextSpan(text: ' تومان'),
                      ],
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                Obx(
                  () => Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      " مجموع: ${'${cartController.totalPrice}'.beToman().toWord()} تومان ",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: CustomOkButton(onPressed: () {
                        Get.snackbar('پرداخت', "به زودی این امکان فراهم میشود");
                      }, text: 'پرداخت'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
