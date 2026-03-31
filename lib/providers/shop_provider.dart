import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ShopProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> _hotCache = [];

  bool _loading = false;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get loading => _loading;

  // paging
  final int _pageSize = 10;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  final Map<String, int> _cart = {};
  String? _selectedCategory;

  List<Product> get products => List.unmodifiable(_products);
  Map<String, int> get cart => Map.unmodifiable(_cart);
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final set = <String>{};
    for (var p in _products) set.add(p.category);
    return set.toList();
  }

  // Return cached hot products to avoid heavy work on every build
  List<Product> hotProducts({int count = 5}) {
    if (_hotCache.isNotEmpty) return _hotCache.take(min(count, _hotCache.length)).toList();
    final rnd = Random();
    final list = List<Product>.from(_products);
    list.shuffle(rnd);
    _hotCache = list.take(min(count, list.length)).toList();
    return _hotCache;
  }

  List<Product> productsByCategory(String? category) {
    if (category == null) return products;
    return _products.where((p) => p.category == category).toList();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      // try load cache first
      final cached = await ApiService.loadCache(limit: _pageSize);
      if (cached.isNotEmpty) {
        _products.clear();
        _products.addAll(cached);
      }

      // fetch first page
      _offset = 0;
      _hasMore = true;
      final res = await ApiService.fetchProducts(limit: _pageSize, offset: _offset, retries: 2);
      if (res.isSuccess) {
        _products.clear();
        _products.addAll(res.data!);
        _hotCache = [];
        _errorMessage = null;
        _offset += res.data!.length;
        _hasMore = res.data!.length == _pageSize;
      } else {
        _errorMessage = res.error;
        debugPrint('ApiService error: ${res.error}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('fetchProducts exception: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final res = await ApiService.fetchProducts(limit: _pageSize, offset: _offset, retries: 1);
      if (res.isSuccess) {
        _products.addAll(res.data!);
        _offset += res.data!.length;
        _hasMore = res.data!.length == _pageSize;
      } else {
        debugPrint('loadMore error: ${res.error}');
      }
    } catch (e) {
      debugPrint('loadMore exception: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void addToCart(String productId) {
    _cart.update(productId, (v) => v + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (!_cart.containsKey(productId)) return;
    final cur = _cart[productId]!;
    if (cur > 1) {
      _cart[productId] = cur - 1;
    } else {
      _cart.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

