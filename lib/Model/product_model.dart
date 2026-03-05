class Product {
  final String id;
  final String name;
  final String price;
  final String image;
  final String category;
  final String? description;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Tất cả',
    );
  }
}