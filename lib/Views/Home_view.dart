import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/product_model.dart';
import '../API/api_service.dart';
import 'Product_detail_view.dart';
import 'cart_manager.dart';
import 'Cart_view.dart';
import 'Profile_view.dart';
import 'Order_view.dart';
import 'dart:async';
import 'Add_product_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "";
  final ApiService apiService = ApiService();
  String _selectedCategory = "Tất cả";
  final PageController _bannerController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  late Future<List<Product>> _productsFuture;
  final int _totalBanners = 3;

  @override
  void initState() {
    super.initState();
    _productsFuture = apiService.fetchProducts();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _totalBanners - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }
  Widget _buildHomeBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Danh mục", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMenuItem(Icons.grid_view_rounded, "Tất cả"),
                _buildMenuItem(Icons.phone_iphone, "Điện thoại"),
                _buildMenuItem(Icons.laptop, "Máy tính"),
                _buildMenuItem(Icons.watch, "Đồng hồ"),
                _buildMenuItem(Icons.tv, "Tivi"),
                _buildMenuItem(Icons.headphones, "Tai nghe"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView(
                    controller: _bannerController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildBannerItem(
                          "Siêu Sale Hè!",
                          "Giảm đến 50%",
                          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=1000&auto=format&fit=crop"
                      ),
                      _buildBannerItem(
                          "Đồ Công Nghệ",
                          "Trả góp 0%",
                          "https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000&auto=format&fit=crop"
                      ),
                      _buildBannerItem(
                          "Freeship",
                          "Đơn từ 0đ",
                          "https://images.unsplash.com/photo-1586880244406-556ebe35f28e?q=80&w=1000&auto=format&fit=crop"
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalBanners, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8, // Dấu chấm trang hiện tại sẽ dài hơn
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Sản phẩm mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<Product>>(
            // --- SỬA TẠI ĐÂY: Dùng biến _productsFuture đã khởi tạo ---
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Không có sản phẩm nào"));
              }

              final allProducts = snapshot.data!;
              final filteredProducts = allProducts.where((product) {
                final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesCategory = (_selectedCategory == "Tất cả") || (product.category == _selectedCategory);
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("🔍 Không tìm thấy sản phẩm phù hợp."),
                ));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(String title, String subtitle, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeBody(),
      const OrderView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _selectedIndex == 0
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: const InputDecoration(
              hintText: "Tìm kiếm sản phẩm...",
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          _buildCartBadge(),
        ],
      )
          : null,

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF6389D9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Hoá Đơn"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6389D9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductView()),
          );
          if (refresh == true) {
            setState(() {
              _productsFuture = apiService.fetchProducts();
            });
          }
        },
      ),
    );
  }

  Widget _buildCartBadge() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartView()),
            ).then((value) => setState(() {}));
          },
        ),
        if (CartManager.cartItems.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '${CartManager.cartItems.length}',
                style: const TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    bool isSelected = _selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6389D9) : Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6389D9) : Colors.blue[100]!,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : const Color(0xFF6389D9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF6389D9) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailView(product: product)),
        ).then((value) => setState(() {}));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("${product.price}đ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}