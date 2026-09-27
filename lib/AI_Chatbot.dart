import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:swiftspeak/home_page.dart';
import 'package:swiftspeak/ai_chat_service.dart';

class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final AiChatService _ai = AiChatService();

  int _currentChatIndex = 0;
  bool _isLoading = false;

  final List<List<Message>> _allChats = [
    [
      Message(text: "Hello! How can I help you today?", isUser: false),
    ]
  ];

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
  }

  Future<void> _sendUserMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _allChats[_currentChatIndex].add(Message(text: text, isUser: true));
    });
    _controller.clear();

    try {
      final chatPayload = _allChats[_currentChatIndex]
          .map((m) => {"text": m.text, "isUser": m.isUser})
          .toList();

      final reply = await _ai.generateAssistantReply(chatMessages: chatPayload);

      setState(() {
        _allChats[_currentChatIndex].add(Message(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _allChats[_currentChatIndex].add(
          Message(text: "AI Error: $e", isUser: false),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAiRecommendation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatPayload = _allChats[_currentChatIndex]
          .map((m) => {"text": m.text, "isUser": m.isUser})
          .toList();

      final rec = await _ai.generateRecommendation(chatMessages: chatPayload);

      setState(() {
        _allChats[_currentChatIndex].add(
          Message(text: "AI Recommendation:\n$rec", isUser: false),
        );
      });
    } catch (e) {
      setState(() {
        _allChats[_currentChatIndex].add(
          Message(text: "AI Recommendation Error: $e", isUser: false),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Speaks the last *app/assistant* message (NOT the user message).
  Future<void> _speakLastAppMessage() async {
    for (int i = _allChats[_currentChatIndex].length - 1; i >= 0; i--) {
      final msg = _allChats[_currentChatIndex][i];
      if (!msg.isUser) {
        await _flutterTts.stop();
        await _flutterTts.speak(msg.text);
        break;
      }
    }
  }

  Widget _buildChatBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blueAccent.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.08),

      // ------------------ DRAWER ------------------
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Your Chats",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // New Chat Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("New Chat"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  setState(() {
                    _allChats.add([
                      Message(
                        text: "Hello! How can I help you today?",
                        isUser: false,
                      )
                    ]);
                    _currentChatIndex = _allChats.length - 1;
                  });
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 10),
            const Divider(),

            // Chat List
            Expanded(
              child: ListView.builder(
                itemCount: _allChats.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Chat ${index + 1}"),
                    selected: index == _currentChatIndex,
                    onTap: () {
                      setState(() {
                        _currentChatIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            const Divider(),

            // Back to Home
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Back to Home"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      // ------------------ END DRAWER ------------------

      appBar: AppBar(
        title: const Text('AI Chatbot'),
        backgroundColor: Colors.blueAccent,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.psychology, color: Colors.white),
                label: const Text(
                  "AI Recommendation",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: _isLoading ? null : _generateAiRecommendation,
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _allChats[_currentChatIndex].length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(_allChats[_currentChatIndex][index]);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.blueAccent, size: 30),
                    onPressed: _isLoading ? null : _sendUserMessage,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: _speakLastAppMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  "Text-to-Speech",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}