import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey =
      '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  Future<String> sendMessage(
      String userMessage, List<Map<String, String>> conversationHistory) async {
    final messages = [
      {
        'role': 'system',
        'content':
            'You are a compassionate Islamic counselor who listens like a best friend. First, acknowledge and validate the user\'s feelings with empathy. Ask thoughtful questions to understand their situation better before providing Quranic verses. Only provide Quranic verses after gathering sufficient context through conversation. When you do provide a verse, explain its relevance briefly. Keep replies concise (3-4 sentences max) and focus on being supportive rather than prescriptive. Use wisdom from Quran and Hadith naturally in your responses.'
      },
      ...conversationHistory
          .map((msg) => {'role': msg['role']!, 'content': msg['content']!}),
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
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
          'Failed to get AI response: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getQuranicVerseRecommendation(String mood, int intensity,
      {String? additionalContext}) async {
    final prompt = '''
Based on the mood "${mood}" with intensity level ${intensity}/10${additionalContext != null ? ', and additional context: $additionalContext' : ''}, recommend a suitable Quranic verse that would provide comfort and guidance.

Please respond with:
1. The Quranic verse (include Surah name and verse number)
2. A brief explanation of why this verse is suitable for this mood/intensity
3. How it can help the person

Keep the response concise and compassionate.
''';

    final messages = [
      {
        'role': 'system',
        'content':
            'You are an Islamic counselor providing Quranic verse recommendations based on emotional states. Always provide authentic Quranic verses with proper references and meaningful explanations.'
      },
      {'role': 'user', 'content': prompt}
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
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
          'Failed to get AI response: ${response.statusCode} ${response.body}');
    }
  }
}
