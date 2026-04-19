class Promotion {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String emoji;
  final int backgroundColor;
  final String? imageUrl;
  final String targetCategory;

  const Promotion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.emoji,
    required this.backgroundColor,
    this.imageUrl,
    required this.targetCategory,
  });
}
