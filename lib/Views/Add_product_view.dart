import 'package:flutter/material.dart';
import '../Model/product_model.dart';
import '../API/api_service.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = "Điện thoại";

  void _submitData() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;

    final newProduct = Product(
      id: "",
      name: _nameController.text,
      price: _priceController.text,
      image: _imageController.text.isEmpty
          ? "https://via.placeholder.com/150"
          : _imageController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
    );

    bool success = await ApiService().addProduct(newProduct);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thêm thành công!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm sản phẩm mới")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên sản phẩm")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Giá (đ)"), keyboardType: TextInputType.number),
            TextField(controller: _imageController, decoration: const InputDecoration(labelText: "Link hình ảnh")),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Mô tả sản phẩm"),
              maxLines: 3,
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: ["Điện thoại", "Máy tính", "Đồng hồ", "Tivi", "Tai nghe"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("LƯU SẢN PHẨM"),
            )
          ],
        ),
      ),
    );
  }
}