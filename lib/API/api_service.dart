import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/product_model.dart';
import '../Model/comment_model.dart';
class ApiService {
  final String apiUrl = "https://69a7fafe37caab4b8c6053ca.mockapi.io/products";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Không thể lấy dữ liệu từ Server");
    }
  }
  Future<bool> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse("https://69a7fafe37caab4b8c6053ca.mockapi.io/products"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": product.name,
        "price": product.price,
        "image": product.image,
        "category": product.category,
        "description": product.description ??"",
      }),
    );
    return response.statusCode == 201;
  }
  Future<List<Comment>> fetchComments(String productId) async {
    final response = await http.get(Uri.parse("https://69a7fafe37caab4b8c6053ca.mockapi.io/comments?productId=$productId"));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Comment.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> postComment(String productId, String name, String content) async {
    await http.post(
      Uri.parse("https://69a7fafe37caab4b8c6053ca.mockapi.io/comments"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"productId": productId, "userName": name, "content": content}),
    );
  }
}