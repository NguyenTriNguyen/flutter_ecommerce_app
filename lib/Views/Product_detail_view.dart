import 'package:flutter/material.dart';
import '../Model/product_model.dart';
import 'cart_manager.dart';
import '../API/api_service.dart';
import '../Model/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();

}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ApiService apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = apiService.fetchComments(widget.product.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.image,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${widget.product.price}đ",
                    style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Mô tả sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${widget.product.description}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const Divider(height: 40),

                  const Text(
                    "Bình luận",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildCommentSection(),
                  const SizedBox(height: 100), // Khoảng trống cuối trang
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            CartManager.cartItems.add(widget.product);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã thêm vào giỏ hàng!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6389D9),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("THÊM VÀO GIỎ HÀNG", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      children: [
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text("Không thể tải bình luận");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Chưa có bình luận nào. Hãy là người đầu tiên!");
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var comment = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF6389D9),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(comment.content),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Nhập bình luận của bạn...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _handleSendComment,
              icon: const Icon(Icons.send, color: Color(0xFF6389D9)),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    String nameToShow = "Khách hàng";

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        nameToShow = user.displayName!;
      } else if (user.email != null) {
        nameToShow = user.email!.split('@')[0];
      }
    }
    await apiService.postComment(
      widget.product.id,
      nameToShow,
      _commentController.text,
    );

    _commentController.clear();
    setState(() {
      _commentsFuture = apiService.fetchComments(widget.product.id);
    });
  }
}