import 'dart:convert';
import 'package:http/http.dart' as http;

import 'alumini.dart';

class ApiService {
  // Update this URL with your computer's IP address when testing on a physical device
  // (Don't use localhost as it refers to the device itself)
  final String baseUrl =
      'http://10.0.2.2:3000/api'; // Use this for Android emulator
  // final String baseUrl = 'http://localhost:3000/api'; // Use this for iOS simulator

  Future<List<Alumni>> getAlumni() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alumni'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Alumni.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alumni data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<void> saveAlumni(Map<String, dynamic> alumniData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alumni'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(alumniData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save alumni data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
