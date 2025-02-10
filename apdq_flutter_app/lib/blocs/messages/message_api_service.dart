import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/models/message_models.dart';

class MessageApiService {
  // Create storage instance to get the token
  final _storage = const FlutterSecureStorage();

  Future<List<GarageMessageResponse>> getRemorqueurMessages(
      int remorqueurId) async {
    try {
      // First, get the token that was stored during login
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('No authentication token found. Please log in again.');
      }

      // Create the full URL
      final url =
          '${EnvConfig.apiUrl}/garages/api/v1/get_remoqueurs_fromGarage_messages';

      // Make the request with the authentication header
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Deliver-Auth': token,
        },
        body: jsonEncode({'remorqueur_id': remorqueurId}),
      );

      // Check response status
      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) =>
                GarageMessageResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception(
            'Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<bool> markMessageAsRead(int messageId, int remorqueurId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('No authentication token found. Please log in again.');
      }

      // Create the full URL using the new endpoint
      final url = '${EnvConfig.apiUrl}/garages/garage-messages/$messageId/read';

      // Make the PUT request with the authentication header
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Deliver-Auth': token,
        },
        body: jsonEncode({'remorqueur_id': remorqueurId}),
      );

      // Check response status
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception(
            'Failed to mark message as read. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }
}
