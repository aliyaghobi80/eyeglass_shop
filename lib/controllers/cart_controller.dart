import 'package:get/get.dart';
import '../models/product.dart';

class CartController extends GetxController {
  var cartItems = <Product>[].obs;

  void addToCart(Product product) {
    cartItems.add(product);
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
  }

  int get totalPrice => cartItems.fold(0, (sum, item) => sum + item.getFinalPrice());

}
