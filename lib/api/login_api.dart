import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final String _baseUrl = 'https://vot.co.tm/api/login';

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token'] ?? '');
        print('Token saved: ${responseData['token']}');
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Invalid credentials';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception(e.toString());
    }
  }
}

class LoginModel {
  final String message;
  final String token;

  LoginModel({required this.message, required this.token});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'] ?? 'No message provided',
      token: json['token'] ?? '',
    );
  }
}
