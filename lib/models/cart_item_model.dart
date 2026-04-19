import 'product_model.dart';
import 'deal_model.dart';

class CartItem {
  final Product? product;
  final Deal? deal;
  int quantity;

  CartItem({this.product, this.deal, this.quantity = 1})
      : assert(product != null || deal != null,
            'CartItem must have either a product or a deal');

  bool get isDeal => deal != null;

  String get id => isDeal ? deal!.id : product!.id;
  String get name => isDeal ? deal!.name : product!.name;
  double get price => isDeal ? deal!.price : product!.price;
  String get itemEmoji => isDeal ? '🎁' : product!.emoji;

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product?.toMap(),
        'deal': deal != null
            ? {
                'id': deal!.id,
                'name': deal!.name,
                'price': deal!.price,
                'imageUrl': deal!.imageUrl,
                // We don't necessarily need all items for persistence
              }
            : null,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    if (json['deal'] != null) {
      return CartItem(
        deal: Deal(
          id: json['deal']['id'],
          name: json['deal']['name'],
          price: (json['deal']['price'] ?? 0).toDouble(),
          imageUrl: json['deal']['imageUrl'],
        ),
        quantity: json['quantity'] ?? 1,
      );
    }
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
