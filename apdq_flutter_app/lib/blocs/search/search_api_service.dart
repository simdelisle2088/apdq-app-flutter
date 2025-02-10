// lib/services/vehicle_api_service.dart
import 'dart:convert';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/models/vehicle_models.dart';
import 'package:http/http.dart' as http;

class VehicleApiService {
  // Using a factory constructor to ensure single instance
  static final VehicleApiService _instance = VehicleApiService._internal();
  factory VehicleApiService() => _instance;
  VehicleApiService._internal();

  // Get base URL from environment configuration
  String get baseUrl => EnvConfig.apiUrl;

  // Creating a client instance that can be reused
  final http.Client _client = http.Client();

  // Headers that will be used in all requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Get available years
  Future<List<int>> getYears() async {
    try {
      final url = '$baseUrl/api/v1/years';

      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final years = List<int>.from(data['years']);
        // Sort years in descending order to show newest first
        years.sort((a, b) => b.compareTo(a));
        return years;
      } else {
        throw ApiException('Failed to load years', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error while loading years', 500);
    }
  }

  // Get brands for a specific year
  Future<List<String>> getBrands(int year) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/brands/$year'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['brands']);
      } else if (response.statusCode == 404) {
        // Return empty list if no brands found
        return [];
      } else {
        throw ApiException('Failed to load brands', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error while loading brands', 500);
    }
  }

  // Get models for a specific year and brand
  Future<List<String>> getModels(int year, String brand) async {
    try {
      // URL encode the brand name to handle special characters
      final encodedBrand = Uri.encodeComponent(brand);
      final response = await _client.get(
        Uri.parse('$baseUrl/api/v1/models/$year/$encodedBrand'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data);
      } else if (response.statusCode == 404) {
        // Return empty list if no models found
        return [];
      } else {
        throw ApiException('Failed to load models', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error while loading models', 500);
    }
  }

  // Get vehicles based on filters
  Future<List<Vehicle>> getVehicles({
    required int year,
    String? brand,
    String? model,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'year': year.toString(),
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
      };

      final uri = Uri.parse('$baseUrl/api/v1/vehicles')
          .replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ApiException('Failed to load vehicles', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error while loading vehicles', 500);
    }
  }

  // lib/services/vehicle_api_service.dart

  Future<List<Vehicle>> getVehicleDetails({
    required int year,
    required String brand,
    required String model,
  }) async {
    try {
      // Construct the query parameters for the API request
      final queryParams = {
        'year': year.toString(),
        'brand': brand,
        'model': model,
      };

      // Build the URI with the query parameters
      final uri = Uri.parse('$baseUrl/api/v1/vehicles')
          .replace(queryParameters: queryParams);

      print('Fetching vehicle details from: $uri');

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        // Parse the JSON response into a list of Vehicle objects
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Vehicle.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Return empty list if no vehicles found
        return [];
      } else {
        throw ApiException(
            'Failed to load vehicle details (Status: ${response.statusCode})',
            response.statusCode);
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
      throw ApiException('Network error while loading vehicle details', 500);
    }
  }

  // Cleanup method
  void dispose() {
    _client.close();
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
