import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/user.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResult._({this.data, this.error, this.statusCode});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.error(String message, {int? statusCode}) => ApiResult._(error: message, statusCode: statusCode);

  bool get isSuccess => data != null && error == null;
}

class ApiService {
  static const _endpoint = 'https://api.escuelajs.co/api/v1/products';

  /// Fetch products with retries, parse in background isolate, and return an ApiResult.
  /// Fetch products with optional pagination via `limit` and `offset`.
  /// Saves a local cache file on success.
  static Future<ApiResult<List<Product>>> fetchProducts({int limit = 30, int offset = 0, int retries = 2}) async {
    var attempt = 0;
    var delayMs = 500;
    while (true) {
      attempt++;
      try {
        final url = '$_endpoint?limit=$limit&offset=$offset';
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final parsed = await compute(_parseProducts, {'body': res.body, 'limit': limit});
          final List<Product> products = List<Product>.from(parsed);
          // save cache only when offset == 0 (initial page)
          if (offset == 0) {
            try {
              await _saveCache(res.body);
            } catch (_) {}
          }
          return ApiResult.success(products);
        } else {
          final msg = 'HTTP ${res.statusCode}';
          if (attempt > retries) return ApiResult.error('Failed to fetch products: $msg', statusCode: res.statusCode);
        }
      } catch (e) {
        if (attempt > retries) return ApiResult.error('Failed to fetch products: ${e.toString()}');
      }

      // exponential backoff
      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }
  }

  /// Fetch users list and parse in background isolate
  static Future<ApiResult<List<UserModel>>> fetchUsers({int retries = 1}) async {
    var attempt = 0;
    var delayMs = 400;
    while (true) {
      attempt++;
      try {
        final url = 'https://api.escuelajs.co/api/v1/users';
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final parsed = await compute(_parseUsers, res.body);
          return ApiResult.success(List<UserModel>.from(parsed));
        } else {
          final msg = 'HTTP ${res.statusCode}';
          if (attempt > retries) return ApiResult.error('Failed to fetch users: $msg', statusCode: res.statusCode);
        }
      } catch (e) {
        if (attempt > retries) return ApiResult.error('Failed to fetch users: ${e.toString()}');
      }
      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }
  }

  /// Load cached products from disk. Returns empty list if not present or parse fails.
  static Future<List<Product>> loadCache({int limit = 30}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/products_cache.json');
      if (!await file.exists()) return <Product>[];
      final body = await file.readAsString();
      final parsed = await compute(_parseProducts, {'body': body, 'limit': limit});
      return List<Product>.from(parsed);
    } catch (_) {
      return <Product>[];
    }
  }

  static Future<void> _saveCache(String body) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products_cache.json');
    await file.writeAsString(body, flush: true);
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

List<UserModel> _parseUsers(String body) {
  final List<dynamic> data = json.decode(body) as List<dynamic>;
  final List<UserModel> out = [];
  for (var item in data) {
    try {
      out.add(UserModel.fromJson(item as Map<String, dynamic>));
    } catch (_) {}
  }
  return out;
}
