import 'package:grocery_app/models/cart_item_model.dart';

class Order {
  final String id;
  final String? orderId;
  final String date;
  final List<CartItem> items;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String deliveryType;
  final String
      deliverySpeed; // Keeping this if still used, but deliveryType is the DB field
  int statusIndex; // 0–4: Placed, Confirmed, Packed, Shipped, Delivered

  // Tracking timestamps
  final DateTime? confirmedAt;
  final DateTime? packedAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final String? paymentAccountId;
  final String? paymentProofUrl;

  Order({
    required this.id,
    this.orderId,
    required this.date,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.deliveryType = 'Standard',
    this.deliverySpeed = 'Standard',
    this.statusIndex = 0,
    this.confirmedAt,
    this.packedAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.paymentAccountId,
    this.paymentProofUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json, List<CartItem> items) {
    final statusStr = json['status'] ?? 'order Placed';
    int index = 0;
    switch (statusStr) {
      case 'order Placed':
        index = 0;
        break;
      case 'Confirmed':
        index = 1;
        break;
      case 'Items Packed':
        index = 2;
        break;
      case 'Out For Delivry':
        index = 3;
        break;
      case 'Delivered':
        index = 4;
        break;
      case 'cancelled':
        index = -1;
        break;
    }

    final createdAt = DateTime.parse(
        json['time'] ?? json['created_at'] ?? DateTime.now().toIso8601String());

    return Order(
      id: json['id'].toString(),
      orderId: json['order_number'],
      date: '${createdAt.day}/${createdAt.month}/${createdAt.year}',
      items: items,
      total: (json['amount'] ?? 0).toDouble(),
      deliveryAddress: json['address'] ?? '',
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      deliveryType: json['delivery_type'] ?? 'Standard',
      deliverySpeed: json['delivery_type'] ?? 'Standard',
      paymentAccountId: json['payment_account_id']?.toString(),
      paymentProofUrl: json['payment_proof_url'],
      statusIndex: index,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'])
          : null,
      packedAt:
          json['packed_at'] != null ? DateTime.parse(json['packed_at']) : null,
      outForDeliveryAt: json['out_for_delivery_at'] != null
          ? DateTime.parse(json['out_for_delivery_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
