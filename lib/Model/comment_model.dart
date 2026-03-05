class Comment {
  final String id;
  final String productId;
  final String userName;
  final String content;

  Comment({required this.id, required this.productId, required this.userName, required this.content});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['productId'],
      userName: json['userName'],
      content: json['content'],
    );
  }
}