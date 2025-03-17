// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ApiService {
  // ورود به سیستم
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      //این خط پایینیا 4 خط رو بعد پاک کن
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print("Decoded Response Data: $responseData");
      print("Extracted Access Token: ${responseData['access_token']}");
      print("Extracted Refresh Token: ${responseData['refresh_token']}");


      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // ارسال پیام به AuthController
        final String serverMessage = responseData['message'] ?? 'Login successful!';
        // ترکیب توکن‌ها و داده‌های کاربر
        final Map<String, dynamic> userData = {
          ...responseData['user'] as Map<String, dynamic>,
          'access_token': responseData['access_token'],
          'refresh_token': responseData['refresh_token'],
        };

        print('Server Message: $serverMessage');
        Get.snackbar(
          'Success',
          serverMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );


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

//این خط پایینیا 4 خط رو بعد پاک کن
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print("Decoded Response Data: $responseData");
      print("Extracted Access Token: ${responseData['access_token']}");
      print("Extracted Refresh Token: ${responseData['refresh_token']}");


      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);


        final String serverMessage = responseData['message'] ?? 'SignUp successful!';

        final userData= User.fromJson({
          ...responseData['user'] as Map<String, dynamic>,
          'access_token': responseData['access_token'] ?? '',
          'refresh_token': responseData['refresh_token'] ?? '',
        });

        print('Server Message: $serverMessage');
        Get.snackbar(
          'Success',
          serverMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          margin: EdgeInsets.all(10),
        );

        return userData;

      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Register Error: $e');
    }
  }

  Future<void> logout(String accessToken,String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // ارسال توکن برای احراز هویت
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      throw Exception('Logout Error: $e');
    }
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['access']; // دریافت توکن جدید
      } else {
        throw Exception('Failed to refresh access token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Refresh Token Error: $e');
    }
  }

  Future<Map<String, dynamic>> getProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (accessToken == null || accessToken.isEmpty) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        accessToken = await refreshAccessToken(refreshToken);
        await prefs.setString('access_token', accessToken);
      } else {
        throw Exception('No valid tokens found, please login again.');
      }
    }

    final response = await http.get(
      Uri.parse('${Constants.productUrl}$productId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        accessToken = await refreshAccessToken(refreshToken);
        await prefs.setString('access_token', accessToken);

        return getProduct(productId); // درخواست را مجدداً ارسال کن
      } else {
        throw Exception('Session expired, please login again.');
      }
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get product: ${response.body}');
    }
  }




}