class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isNew;
  final String icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isNew = true,
    this.icon = '📦',
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isNew: json['is_read'] == null ? true : !(json['is_read'] as bool),
      icon: json['icon'] ?? '📦',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'created_at': time.toIso8601String(),
    'is_read': !isNew,
    'icon': icon,
  };
}
