class Review {
  final int id;
  final String productId;
  final String userName;
  final int rating;
  final String? comment;
  final String? reply;
  final DateTime? createdAt;
  final String? imageUrl;

  Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    this.comment,
    this.reply,
    this.createdAt,
    this.imageUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      userName: json['user_name'],
      rating: json['rating'],
      comment: json['comment'],
      reply: json['reply'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'product_id': productId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'reply': reply,
      'created_at': createdAt?.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
