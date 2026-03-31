import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.fetchUsers(retries: 1);
      if (!res.isSuccess) {
        _error = res.error ?? 'Failed to fetch users';
        return false;
      }
      final users = res.data!;
      final matches = users.where((u) => u.email == email && u.password == password).toList();
      if (matches.isNotEmpty) {
        _user = matches.first;
        _error = null;
        return true;
      } else {
        _error = 'Invalid credentials';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
