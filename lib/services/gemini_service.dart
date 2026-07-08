import 'dart:convert';

import 'package:http/http.dart' as http;

/// Optional AI upgrade: when the user adds a Gemini API key in Settings,
/// daily prompts are generated live instead of picked from the built-in bank.
///
/// Note for the Firebase version: this call should move into a Cloud
/// Function so the key never ships inside the app.
class GeminiService {
  static const _model = 'gemini-2.5-flash';

  static Future<String?> generateActPrompt({
    required String apiKey,
    required String weekday,
    required String daypart,
    required List<String> interests,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
    );

    final instruction = 'You suggest one small, concrete act of kindness that '
        'an ordinary person can do today in under 10 minutes, at no or almost '
        'no cost. Context: it is $daypart on $weekday. The person cares '
        'about: ${interests.join(", ")}. '
        'Reply with ONLY the suggestion itself, maximum 20 words, no quotes, '
        'no emoji, no preamble.';

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': instruction}
                  ]
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;
      return text?.trim().replaceAll(RegExp(r'^"|"$'), '');
    } catch (_) {
      // Any network/parse failure: caller falls back to the offline bank.
      return null;
    }
  }
}
