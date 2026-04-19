class Address {
  final String id;
  final String userId;
  final String name;
  final String location;
  final String icon;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    this.icon = 'base',
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      icon: json['icon'] as String? ?? 'base',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'location': location,
      'icon': icon,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? location,
    String? icon,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      location: location ?? this.location,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
