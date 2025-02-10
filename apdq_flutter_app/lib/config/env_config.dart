import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Define available environments
  static const local = 'local';
  static const dev = 'dev';
  static const prod = 'prod';

  // Get the API URL from environment variables with a fallback
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://192.168.1.172:8000';

  // Get the base URL for files - this will be the same in all environments
  // since it's your production domain that serves the files
  static String get filesBaseUrl =>
      dotenv.env['FILES_BASE_URL'] ?? 'http://apps.remorqueurbranche.com';

  // Get the current environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? local;

  static Future<void> initialize([String? environment]) async {
    try {
      // If no environment is specified, default to local
      final env = environment ?? local;
      await dotenv.load(fileName: '.env.$env');

      // Log the loaded configuration for debugging
      print('Loaded environment: $env');
      print('API URL: ${dotenv.env['API_URL']}');
      print('Files Base URL: ${dotenv.env['FILES_BASE_URL']}');
    } catch (e) {
      print('Failed to load environment file. Using default settings.');
      // Set default values if environment file fails to load
      dotenv.env['API_URL'] = 'http://192.168.1.172:8000';
      dotenv.env['FILES_BASE_URL'] = 'http://apps.remorqueurbranche.com';
      dotenv.env['ENVIRONMENT'] = local;
    }
  }
}
