import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Patient> getPatientData(String bearerToken) async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $bearerToken'},
    );

    if (response.statusCode == 200) {
      print(response.body);

      final Map<String, dynamic> jsonBody = json.decode(response.body);
      return Patient.fromJson(jsonBody['data']);
    } else {
      throw Exception('Failed to load patient data');
    }
  }
}

class Patient {
  final int id;
  final String name;
  final List<dynamic> videos;

  Patient({
    required this.id,
    required this.name,
    required this.videos,
  });

  // Factory constructor to create an instance from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as int,
      name: json['name'] as String,
      videos: json['videos'] as List<dynamic>,
    );
  }
}
