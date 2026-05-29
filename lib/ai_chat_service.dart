import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String _persona =
      "You are an AI chatbot that helps stroke patients communicate and supports them on their healing journey in a hospital. "
      "Answer the questions as if a stroke patient was asking them.";

  final String _baseUrl = "https://api.openai.com/v1/chat/completions";

  String _apiKey() {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      throw Exception("Missing OPENAI_API_KEY. Check your .env file.");
    }
    return key.trim();
  }

  Map<String, String> _headers() => {
    "Authorization": "Bearer ${_apiKey()}",
    "Content-Type": "application/json",
  };

  Future<String> generateAssistantReply({
    required List<Map<String, dynamic>> chatMessages,
  }) async {
    final convo = _formatConversation(chatMessages);

    final userPrompt = """
Rules:
- Be calm, kind, and practical.
- Keep answers clear and easy to understand.
- Do NOT provide a medical diagnosis.
- Encourage safety: if symptoms are severe or urgent, advise asking a nurse/doctor immediately.
- Ask 1 short follow-up question if it helps.

Conversation so far:
$convo

Now respond to the patient's last message.
""";

    final json = await _postToOpenAI(system: _persona, user: userPrompt);
    final text = _extractChatCompletionText(json);

    if (text.isEmpty) {
      if (kDebugMode) debugPrint("OpenAI raw JSON (empty): ${jsonEncode(json)}");
      throw Exception("Empty AI response.");
    }

    return text;
  }

  Future<String> generateRecommendation({
    required List<Map<String, dynamic>> chatMessages,
  }) async {
    final convo = _formatConversation(chatMessages);

    final userPrompt = """
Task:
Analyze the conversation and give a short supportive recommendation for the patient.

Rules:
- 3 to 6 sentences max.
- Practical, calming, hospital-appropriate.
- Do NOT provide a medical diagnosis.
- If urgent red flags are present, tell them to seek immediate help from nurse/doctor.
- Keep language simple.

Conversation:
$convo
""";

    final json = await _postToOpenAI(system: _persona, user: userPrompt);
    final text = _extractChatCompletionText(json);

    if (text.isEmpty) {
      if (kDebugMode) debugPrint("OpenAI raw JSON (empty rec): ${jsonEncode(json)}");
      throw Exception("Empty AI response.");
    }

    return text;
  }

  Future<String> generateChatTitle({
    required List<Map<String, dynamic>> chatMessages,
  }) async {
    final convo = _formatConversation(chatMessages);

    final sys = "You create short chat titles.";
    final userPrompt = """
Create a short title (2 to 6 words) based on the conversation.
No quotes. No punctuation at the end.
Avoid personal data. Keep it general.

Conversation:
$convo
""";

    final json = await _postToOpenAI(system: sys, user: userPrompt);
    final text = _extractChatCompletionText(json);

    final cleaned = text.replaceAll(RegExp(r'["\n]'), '').trim();
    if (cleaned.isEmpty) return "";
    return cleaned.split(RegExp(r'\s+')).take(6).join(' ');
  }

  Future<Map<String, dynamic>> _postToOpenAI({
    required String system,
    required String user,
  }) async {
    final body = {
      // Safe default model for Chat Completions
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
      ],
      "temperature": 0.7,
    };

    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (kDebugMode) debugPrint("OpenAI status=${res.statusCode}");

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("OpenAI error ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  String _extractChatCompletionText(Map<String, dynamic> json) {
    final choices = json["choices"];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final msg = first["message"];
        if (msg is Map) {
          final content = (msg["content"] ?? "").toString().trim();
          return content;
        }
      }
    }
    return "";
  }

  String _formatConversation(List<Map<String, dynamic>> msgs) {
    final sb = StringBuffer();
    for (final m in msgs) {
      final isUser = (m["isUser"] ?? false) == true;
      final text = (m["text"] ?? "").toString().trim();
      if (text.isEmpty) continue;
      sb.writeln(isUser ? "Patient: $text" : "Assistant: $text");
    }
    return sb.toString().trim();
  }
}