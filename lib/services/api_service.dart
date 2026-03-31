import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const _endpoint = 'https://api.escuelajs.co/api/v1/products';

  /// Fetch products and parse them in a background isolate.
  static Future<List<Product>> fetchProducts({int limit = 30}) async {
    final res = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Failed to load products: ${res.statusCode}');
    final parsed = await compute(_parseProducts, {'body': res.body, 'limit': limit});
    return List<Product>.from(parsed);
  }
}

// Top-level parser for compute
List<Product> _parseProducts(Map<String, dynamic> payload) {
  final String body = payload['body'] as String;
  final int limit = payload['limit'] as int;
  final List<dynamic> data = json.decode(body) as List<dynamic>;
  final List<Product> out = [];
  var count = 0;
  for (var item in data) {
    if (count >= limit) break;
    try {
      out.add(Product.fromJson(item as Map<String, dynamic>));
      count++;
    } catch (_) {
      // skip malformed
    }
  }
  return out;
}
