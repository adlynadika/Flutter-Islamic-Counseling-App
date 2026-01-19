import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  Future<String> sendMessage(String userMessage, List<Map<String, String>> conversationHistory) async {
    final messages = [
      {
        'role': 'system',
        'content': 'You are an Islamic counselor providing faith-based mental health support. Respond with compassion, Islamic wisdom from Quran and Hadith, and encourage positive actions. Keep responses concise and supportive.'
      },
      ...conversationHistory.map((msg) => {'role': msg['role']!, 'content': msg['content']!}),
      {'role': 'user', 'content': userMessage}
    ];

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'deepseek/deepseek-chat',
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode} ${response.body}');
    }
  }
}