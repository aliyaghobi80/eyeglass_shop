import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';


class ApiService {
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginUrl),  // باید /api/auth/login/ باشه
        headers: {
          'Content-Type': 'application/json',
        },

        body: jsonEncode({'username': username, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');


      if (response.statusCode == 200) {
        print(User.fromJson(jsonDecode(response.body)));
        return User.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to login: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(e.toString());
      throw Exception('Login Error: $e');
    }
  }

  Future<User> register({required String username,required String password,required String phoneNumber,required String address,}) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'phone_number': phoneNumber,
          'address': address,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      throw Exception('Register Error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}auth/user/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    print('User Profile Response Status: ${response.statusCode}');
    print('User Profile Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile: ${response.body}');
    }
  }
}