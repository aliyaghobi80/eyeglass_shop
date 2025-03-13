import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';

class ApiService {
  // ورود به سیستم
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // ترکیب توکن‌ها و داده‌های کاربر
        final Map<String, dynamic> userData = {
          ...responseData['user'] as Map<String, dynamic>,
          'token': responseData['token'],
          'refresh_token': responseData['refresh_token'],
        };

        return User.fromJson(userData);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }
  Future<User> register({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return User.fromJson({
          ...responseData['user'] as Map<String, dynamic>,
          'token': responseData['token'] ?? '',
          'refresh_token': responseData['refresh_token'] ?? '',
        });
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Register Error: $e');
    }
  }
  // دریافت جزئیات محصول
  Future<Map<String, dynamic>> getProduct(int productId) async {
    final response = await http.get(
      Uri.parse('${Constants.productUrl}$productId/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Product Response Status: ${response.statusCode}');
    print('Product Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get product: ${response.body}');
    }
  }
}