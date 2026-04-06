import 'dart:convert';
import 'package:http/http.dart' as http;

import '../auth/secrets.dart';

class TranslationService {
  // Replace with your actual API Key from Google Cloud Console
  static String _apiKey = translateApiKey;
  static String _baseUrl = 'translation.googleapis.com';

  static Future<String> translateText({
    required String text,
    required String targetLanguage, // e.g., 'en', 'de', 'es'
    String sourceLanguage = 'de',    // Optional source language
  }) async {
    final url = Uri.https(_baseUrl, '/language/translate/v2', {
      'key': _apiKey,
    });

    try {
      final response = await http.post(
        headers:{'Content-Type': 'application/json'},
        url,
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': sourceLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Path: data['data']['translations'][0]['translatedText']
        return data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Failed to translate: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during translation: $e');
    }
  }
}