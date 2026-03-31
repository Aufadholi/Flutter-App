import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ShopProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> _hotCache = [];

  bool _loading = false;

  bool get loading => _loading;

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
      final List<Product> parsed = await ApiService.fetchProducts(limit: 30);
      _products.clear();
      _products.addAll(parsed);
      // reset hot cache so it is recalculated once
      _hotCache = [];
    } catch (e) {
      // ignore network errors for now
    } finally {
      _loading = false;
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

