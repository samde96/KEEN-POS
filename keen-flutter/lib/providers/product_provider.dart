import 'package:flutter/material.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/services/api_service.dart';
import 'package:keen_pos/services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<Product> _products = [];
  ProductMetadata? _metadata;
  bool _isLoading = false;
  String? _error;
  
  // Pagination and filtering state
  int _totalElements = 0;
  int _totalPages = 0;
  int _currentPage = 0;
  
  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedSize;
  String? _selectedColor;
  String? _searchTerm;

  List<Product> get products => _products;
  ProductMetadata? get metadata => _metadata;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get totalElements => _totalElements;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  
  String? get selectedCategory => _selectedCategory;
  String? get selectedBrand => _selectedBrand;
  String? get selectedSize => _selectedSize;
  String? get selectedColor => _selectedColor;

  Future<void> fetchProducts({int page = 0}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final productList = await _apiService.getProducts(page: page);
      _products = productList.content;
      _totalElements = productList.totalElements;
      _totalPages = productList.totalPages;
      
      // Cache in local DB
      await _dbService.saveProducts(_products);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      
      // If API fails, try to load from local DB
      _products = await _dbService.getProducts();
      _totalElements = _products.length;
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String searchTerm) async {
    _searchTerm = searchTerm;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final productList = await _apiService.searchProducts(searchTerm);
      _products = productList.content;
      _totalElements = productList.totalElements;
      _totalPages = productList.totalPages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    String? category,
    String? brand,
    String? size,
    String? color,
  }) async {
    _selectedCategory = category;
    _selectedBrand = brand;
    _selectedSize = size;
    _selectedColor = color;
    
    // For now, let's just re-fetch products. 
    // Ideally, the API would support these as query params.
    await fetchProducts(page: 0);
  }

  Future<void> clearFilters() async {
    _selectedCategory = null;
    _selectedBrand = null;
    _selectedSize = null;
    _selectedColor = null;
    _searchTerm = null;
    await fetchProducts(page: 0);
  }

  Future<Product> getProductById(int id) async {
    try {
      return await _apiService.getProductById(id);
    } catch (e) {
      // Try to find in local list if API fails
      return _products.firstWhere((p) => p.id == id);
    }
  }

  Future<void> fetchMetadata() async {
    try {
      _metadata = await _apiService.getProductMetadata();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    }
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createProduct(productData);
      await fetchProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateProduct(id, productData);
      await fetchProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteProduct(id);
      await fetchProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}