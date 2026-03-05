import 'package:flutter/material.dart';
import 'cart_manager.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng của bạn", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CartManager.cartItems.isEmpty
          ? const Center(child: Text("Giỏ hàng trống 😭"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartManager.cartItems.length,
              itemBuilder: (context, index) {
                final item = CartManager.cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: Image.network(item.image, width: 50, fit: BoxFit.cover),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item.price}đ", style: const TextStyle(color: Colors.red)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          CartManager.cartItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng thanh toán:", style: TextStyle(fontSize: 18)),
                    Text("${CartManager.getTotalPrice()}đ",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { if (CartManager.cartItems.isEmpty) return;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Xác nhận"),
                        content: const Text("Bạn có muốn thanh toán đơn hàng này không?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                CartManager.checkout();
                              });
                              Navigator.pop(context);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Thanh toán thành công! Xem ở mục Hóa đơn.")),
                              );
                            },
                            child: const Text("Đồng ý"),
                          ),
                        ],
                      ),
                    ); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6389D9),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text("THANH TOÁN NGAY", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}