class Category {
  final String id;
  final String name;
  final String emoji;
  final int color;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📁',
      color: json['color'] != null 
          ? int.tryParse(json['color'].toString()) ?? 0xFFE8F5E9 
          : 0xFFE8F5E9,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'image_url': imageUrl,
    };
  }
}
