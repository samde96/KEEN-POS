import 'package:flutter/material.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/services/api_service.dart';
import 'package:keen_pos/services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<Order> _orders = [];
  Order? _lastOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get lastOrder => _lastOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserOrders({int page = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to fetch from API
      final orderList = await _apiService.getUserOrders(page: page, size: 10);
      _orders = orderList.content;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      
      // If API fails, try to load from local DB
      _orders = await _dbService.getOrders();
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _apiService.createOrder(
        items: List<Map<String, dynamic>>.from(orderData['items']),
        subtotal: orderData['subtotal'],
        taxAmount: orderData['taxAmount'],
        discountAmount: orderData['discountAmount'],
        totalAmount: orderData['totalAmount'],
        paymentMethod: orderData['paymentMethod'] as String,
        phoneNumber: orderData['phoneNumber'] as String?,
      );
      
      _lastOrder = order;
      _orders.insert(0, order);
      
      // Cache the new order locally
      await _dbService.saveOrder(order);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}