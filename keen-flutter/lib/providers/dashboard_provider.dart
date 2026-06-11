import 'package:flutter/material.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardMetrics? _metrics;
  SalesReport? _report;
  String _selectedPeriod = 'weekly';
  bool _isLoading = false;
  String? _error;

  DashboardMetrics? get metrics => _metrics;
  SalesReport? get report => _report;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _metrics = await _apiService.getDashboardMetrics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesReport({String? period}) async {
    _selectedPeriod = period ?? _selectedPeriod;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _report = await _apiService.getSalesReport(_selectedPeriod);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}