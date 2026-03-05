import 'package:flutter/material.dart';
import 'cart_manager.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hóa đơn đã mua"), backgroundColor: Colors.white, elevation: 0),
      body: CartManager.orders.isEmpty
          ? const Center(child: Text("Bạn chưa có hóa đơn nào."))
          : ListView.builder(
        itemCount: CartManager.orders.length,
        itemBuilder: (context, index) {
          final order = CartManager.orders[index];
          double total = 0;
          for (var p in order) total += double.tryParse(p.price.replaceAll('.', '')) ?? 0;
          return Card(
            margin: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text("Hóa đơn #${CartManager.orders.length - index}"),
              subtitle: Text("Tổng tiền: ${total.toStringAsFixed(0)}đ", style: const TextStyle(color: Colors.red)),
              children: order.map((p) => ListTile(
                leading: Image.network(p.image, width: 30),
                title: Text(p.name),
                trailing: Text("${p.price}đ"),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}