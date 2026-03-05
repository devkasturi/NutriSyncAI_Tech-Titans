// lib/screens/chat/chatbot_screen.dart
// AI Chatbot powered by Gemini API with user-profile-aware responses

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';

// 🔑 Replace with your actual Gemini API key
const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = false;

  // Quick prompt suggestions
  final List<String> _suggestions = [
    'What should I eat today?',
    'Is this meal good for PCOS?',
    'Why is my HRV low?',
    'Suggest Jain high protein meal',
    'How much water should I drink?',
    'Foods for better sleep',
  ];

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final state = context.read<AppState>();
    state.addChatMessage('user', text);
    _ctrl.clear();
    setState(() => _loading = true);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final reply = await _callGemini(text, state);
      state.addChatMessage('assistant', reply);
    } catch (e) {
      state.addChatMessage('assistant',
          'Sorry, I couldn\'t connect to the AI. Please check your API key and try again.');
    }

    setState(() => _loading = false);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<String> _callGemini(String userMessage, AppState state) async {
    final profile = state.userProfile;
    final bio = state.biometrics;

    // Build context-aware system prompt
    final systemPrompt = '''
You are NutriSync AI, a personal nutrition and health assistant.

User Profile:
- Name: ${profile.name}
- Age: ${profile.age}, Gender: ${profile.gender}
- Height: ${profile.height}cm, Weight: ${profile.weight}kg
- Goals: ${profile.goals.join(', ')}
- Diet: ${profile.dietTypes.join(', ')}
- Allergies: ${profile.allergies.join(', ')}
- Activity: ${profile.activityLevel}
- Cuisine preferences: ${profile.cuisinePrefs.join(', ')}

Today's Biometrics:
- Heart Rate: ${bio.heartRate.round()} BPM
- HRV: ${bio.hrv.round()} ms
- Steps: ${bio.steps}
- Sleep: ${bio.sleepHours}h
- Calories burned: ${bio.caloriesBurned.round()} kcal

Provide concise, personalized nutrition and health advice. Keep responses under 150 words. Use emojis sparingly.
''';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\nUser: $userMessage'},
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': 256, 'temperature': 0.7},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          'No response generated.';
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.chatHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NutriSync AI', style: TextStyle(fontSize: 14)),
                Text('Powered by Gemini',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              state.chatHistory.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: history.isEmpty
                ? _EmptyState(
                    suggestions: _suggestions, onTap: _send)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == history.length) {
                        return const _TypingIndicator();
                      }
                      final msg = history[i];
                      return _MessageBubble(
                        text: msg['content']!,
                        isUser: msg['role'] == 'user',
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06), blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Ask about nutrition, health...',
                      isDense: true,
                    ),
                    onSubmitted: _send,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: _loading ? null : () => _send(_ctrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onTap;

  const _EmptyState({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.chat_bubble_outline,
              size: 56, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text('Ask NutriSync AI',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Get personalized nutrition & health guidance',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Try asking:',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
          ),
          const SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onTap(s),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(s,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isUser ? Colors.white : AppColors.textPrimary,
              fontSize: 14),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.primary),
      ),
    );
  }
}
