import '../Model/product_model.dart';

class CartManager {
  static List<Product> cartItems = [];
  static List<List<Product>> orders = [];
  static double getTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += double.tryParse(item.price.replaceAll('.', '')) ?? 0;
    }
    return total;
  }
  static void checkout() {
    if (cartItems.isNotEmpty) {
      orders.insert(0, List.from(cartItems));
      cartItems.clear();
    }
  }
}