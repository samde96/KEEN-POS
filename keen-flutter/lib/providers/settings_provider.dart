import 'package:flutter/material.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  MpesaSettings? _mpesaSettings;
  bool _isLoading = false;
  String? _error;

  MpesaSettings? get mpesaSettings => _mpesaSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMpesaSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mpesaSettings = await _apiService.getMpesaSettings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMpesaSettings(MpesaSettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mpesaSettings = await _apiService.updateMpesaSettings(settings);
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