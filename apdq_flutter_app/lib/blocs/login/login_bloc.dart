import 'dart:convert';

import 'package:apdq_flutter_app/blocs/login/login.state.dart';
import 'package:apdq_flutter_app/blocs/login/login_event.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:apdq_flutter_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final _storage = const FlutterSecureStorage();
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      // Here you would make the API call to your backend
      final response = await _authenticateUser(
        event.username,
        event.password,
      );

      await _saveAuthData(response);

      emit(LoginSuccess(
        token: response['access_token'] ?? '',
        userType: response['role']['name'] ?? 'unknown',
        garageName: response['garage_name'] ?? '',
      ));
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    try {
      // Store access token
      final token = response['access_token'];
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
        print(
            'Token saved successfully: $token'); // Debug print to verify token
      } else {
        print('Warning: No token received from login response');
      }

      // Store user ID
      await _storage.write(
        key: 'user_id',
        value: response['user']['id'].toString(),
      );

      // Store garage name (if available)
      if (response['user']['garage_name'] != null) {
        await _storage.write(
          key: 'garage_name',
          value: response['user']['garage_name'],
        );
      }

      // Store user role for future reference
      await _storage.write(
        key: 'user_role',
        value: response['role']['name'],
      );

      // Store token expiration
      await _storage.write(
        key: 'token_expires_at',
        value: response['expires_at'],
      );

      debugPrint('Authentication data saved successfully');
    } catch (e) {
      debugPrint('Error saving authentication data: $e');
      // You might want to handle this error appropriately
      rethrow;
    }
  }

  Future<Map<String, String?>> getStoredAuthData() async {
    try {
      return {
        'access_token': await _storage.read(key: 'access_token'),
        'user_id': await _storage.read(key: 'user_id'),
        'garage_name': await _storage.read(key: 'garage_name'),
        'user_role': await _storage.read(key: 'user_role'),
        'token_expires_at': await _storage.read(key: 'token_expires_at'),
      };
    } catch (e) {
      debugPrint('Error retrieving authentication data: $e');
      return {};
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await clearAuthData();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> clearAuthData() async {
    try {
      await _storage.deleteAll();
      debugPrint('Authentication data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing authentication data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _authenticateUser(
    String username,
    String password,
  ) async {
    try {
      // Get the API URL from environment configuration
      final apiUrl = EnvConfig.apiUrl;

      // Construct the complete login endpoint URL
      final uri = Uri.parse('$apiUrl/auth/api/v1/login');

      // Log the environment and URL in debug mode
      debugPrint('Current environment: ${EnvConfig.environment}');
      debugPrint('Making login request to: $uri');

      // Make the POST request with proper headers
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      // Parse and handle the response
      if (response.statusCode == 200) {
        // Successfully logged in
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Validate the response structure
        if (!responseData.containsKey('access_token')) {
          throw Exception('Invalid response format: missing access token');
        }

        return {
          'access_token': responseData['access_token'],
          'token_type': responseData['token_type'],
          'user': responseData['user'],
          'role': responseData['role'],
          'expires_at': responseData['expires_at'],
          'garage_name': responseData['garage_name'],
        };
      } else if (response.statusCode == 401) {
        // Authentication failed
        throw Exception('Invalid credentials');
      } else {
        // Other errors
        final errorBody = json.decode(response.body);
        throw Exception(
            errorBody['detail'] ?? 'An error occurred during login');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: please check your internet connection');
      }
      rethrow;
    }
  }
}
