import 'package:flutter/material.dart';
import 'package:keen_pos/models/models.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;
  List<CartItem> get items => _cart.items;
  double get subtotal => _cart.subtotal;
  double get tax => _cart.tax;
  double get discount => _cart.discount;
  double get total => _cart.total;
  int get itemCount => _cart.items.length;
  int get totalQuantity => _cart.items.fold(0, (sum, item) => sum + item.quantity);
  double get taxRate => _cart.taxRate; // Expose taxRate

  void addItem(Product product, int quantity, String size) {
    _cart.addItem(product, quantity, size);
    notifyListeners();
  }

  void removeItem(int productId, String size) {
    _cart.removeItem(productId, size);
    notifyListeners();
  }

  void updateQuantity(int productId, String size, int quantity) {
    _cart.updateQuantity(productId, size, quantity);
    notifyListeners();
  }

  void setDiscount(double discount) {
    _cart.discount = discount;
    notifyListeners();
  }

  void setTaxRate(double rate) { // New method to set tax rate
    _cart.taxRate = rate;
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }

  Map<String, dynamic> getOrderData(String paymentMethod) {
    final items = _cart.items
        .map((item) => {
              'productId': item.product.id,
              'quantity': item.quantity,
              'size': item.size,
            })
        .toList();

    return {
      'items': items,
      'subtotal': _cart.subtotal.toStringAsFixed(2),
      'taxAmount': _cart.tax.toStringAsFixed(2),
      'discountAmount': _cart.discount.toStringAsFixed(2),
      'totalAmount': _cart.total.toStringAsFixed(2),
      'paymentMethod': paymentMethod,
    };
  }
}