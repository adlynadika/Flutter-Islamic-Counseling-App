// Import dart:async for handling asynchronous operations like timers and futures
import 'dart:async';
// Import dart:convert for JSON encoding and decoding
import 'dart:convert';
// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import Firebase Auth for user authentication
import 'package:firebase_auth/firebase_auth.dart';
// Import HTTP package for making network requests
import 'package:http/http.dart' as http;
// Import Firebase options for configuration
import '../firebase_options.dart';
// Import AI service for interacting with AI
import '../services/ai_service.dart';
// Import Firestore service for database operations
import '../services/firestore_service.dart';
// Import Chat History Screen for navigation
import 'chat_history_screen.dart';

// AIChatScreen is a StatefulWidget that represents the screen for AI chat functionality
class AIChatScreen extends StatefulWidget {
  // Constructor for AIChatScreen with optional key
  const AIChatScreen({super.key});

  // Override createState to return the state class
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

// _AIChatScreenState is the state class for AIChatScreen, managing the chat interface
class _AIChatScreenState extends State<AIChatScreen> {
  // List to hold chat messages, each message is a map with role, content, and time
  final List<Map<String, String>> _messages = [];
  // TextEditingController for the input text field
  final TextEditingController _controller = TextEditingController();
  // ScrollController for the chat messages list view
  final ScrollController _scrollController = ScrollController();
  // Boolean to indicate if a message is being sent (for loading state)
  bool _isLoading = false;

  @override
  @override
  void initState() {
    // Call super.initState() to ensure proper initialization
    super.initState();
    // Add an initial welcome message from the assistant
    _messages.add({
      'role': 'assistant',
      'content':
          'As-salamu alaykum! I\'m here to listen to you like a close friend. Share what\'s on your heart, and I\'ll respond with understanding and a verse from the Quran to comfort you.',
      'time': _getCurrentTime(),
    });
    // Load previous messages from the database
    _loadMessages();
  }

  // Override dispose to clean up resources when the widget is removed
  @override
  void dispose() {
    // Dispose the text controller to free resources
    _controller.dispose();
    // Dispose the scroll controller to free resources
    _scrollController.dispose();
    // Call super.dispose() for proper cleanup
    super.dispose();
  }

  // Method to get the current time in 12-hour format with AM/PM
  String _getCurrentTime() {
    // Get the current date and time
    final now = DateTime.now();
    // Convert hour to 12-hour format
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    // Determine AM or PM
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    // Return formatted time string
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm';
  }

  // Asynchronous method to send a message to the AI
  Future<void> _sendMessage() async {
    // Get the trimmed text from the controller
    final text = _controller.text.trim();
    // Return if text is empty or already loading
    if (text.isEmpty || _isLoading) return;

    // Get the current time for the user message
    final userTime = _getCurrentTime();
    // Update the state to add the user message and set loading
    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'time': userTime,
      });
      _isLoading = true;
    });
    // Clear the text controller
    _controller.clear();
    // Scroll to the bottom of the chat
    _scrollToBottom();
    // Save the user message to the database
    await _saveMessage('user', text, userTime);

    // Try to send the message and get a response
    try {
      // Prepare conversation history, excluding the initial assistant message
      final conversationHistory = _messages
          .where(
              (msg) => msg['role'] != 'assistant' || _messages.indexOf(msg) > 0)
          .map((msg) => {'role': msg['role']!, 'content': msg['content']!})
          .toList();

      // Send the message to the AI service and get response
      final response = await AIService().sendMessage(text, conversationHistory);

      // Get the current time for the assistant message
      final assistantTime = _getCurrentTime();
      // Update the state to add the assistant message and stop loading
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response,
          'time': assistantTime,
        });
        _isLoading = false;
      });
      // Scroll to the bottom
      _scrollToBottom();
      // Save the assistant message to the database
      await _saveMessage('assistant', response, assistantTime);
    } catch (e) {
      // If there's an error, show an error message
      final errorTime = _getCurrentTime();
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              'Sorry, I\'m having trouble connecting right now. Please try again later.',
          'time': errorTime,
        });
        _isLoading = false;
      });
      // Scroll to the bottom
      _scrollToBottom();
      // Save the error message to the database
      await _saveMessage(
          'assistant',
          'Sorry, I\'m having trouble connecting right now. Please try again later.',
          errorTime);
    }
  }

  // Asynchronous method to load previous messages from Firestore
  Future<void> _loadMessages() async {
    // Try to load messages
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      // Return if no user is logged in
      if (user == null) return;

      // Note: For simplicity, load all messages; in production, paginate or limit
      // Construct the Firestore REST API URL
      final url = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/${DefaultFirebaseOptions.android.projectId}/databases/(default)/documents:runQuery');

      // Define the query to get messages for the user, ordered by timestamp
      final query = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'chat_messages'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'uid'},
              'op': 'EQUAL',
              'value': {'stringValue': user.uid}
            }
          },
          'orderBy': [
            {
              'field': {'fieldPath': 'timestamp'},
              'direction': 'ASCENDING'
            }
          ]
        }
      };

      // Get the user's ID token for authentication
      final idToken = await user.getIdToken();
      // Make the HTTP POST request to Firestore
      final resp = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
          body: json.encode(query));

      // If the response is successful
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Decode the JSON response
        final List<dynamic> rows = json.decode(resp.body);
        // List to hold loaded messages
        final List<Map<String, String>> loadedMessages = [];
        // Loop through each document in the response
        for (final item in rows) {
          // Check if the document exists
          if (item['document'] != null) {
            // Get the document
            final doc = item['document'];
            // Get the fields from the document
            final fields = doc['fields'] as Map<String, dynamic>;
            // Extract role, content, and time
            final role = fields['role']['stringValue'];
            final content = fields['content']['stringValue'];
            final time = fields['time']['stringValue'];
            // Add to loaded messages list
            loadedMessages.add({
              'role': role,
              'content': content,
              'time': time,
            });
          }
        }
        // Update the state to add loaded messages
        setState(() {
          _messages.addAll(loadedMessages);
        });
      }
    } catch (e) {
      // Ignore load errors to avoid disrupting the UI
    }
  }

  // Method to scroll the chat to the bottom
  void _scrollToBottom() {
    // Schedule a callback after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the scroll controller has clients
      if (_scrollController.hasClients) {
        // Animate to the maximum scroll extent (bottom)
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Asynchronous method to save a message to Firestore
  Future<void> _saveMessage(String role, String content, String time) async {
    // Try to save the message
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      // Return if no user is logged in
      if (user == null) return;

      // Prepare the payload for the document
      final payload = {
        'role': role,
        'content': content,
        'time': time,
        'timestamp': DateTime.now().toUtc(),
        'uid': user.uid,
      };

      // Add the document to Firestore
      await FirestoreService().addDocument('chat_messages', payload);
    } catch (e) {
      // Ignore save errors to avoid interrupting the chat flow
    }
  }

  // Override build to return the widget tree for the screen
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold with the app structure
    return Scaffold(
      // Body of the scaffold is a column
      body: Column(
        children: [
          // Header section
          Container(
            // Full width
            width: double.infinity,
            // Padding for the header
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            // Decoration with green background and rounded bottom corners
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            // Child is a column with app title and subtitle
            child: const Column(
              children: [
                // App title text
                Text(
                  'Qalby2Heart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Spacing
                SizedBox(height: 4),
                // Subtitle text
                Text(
                  'Your Faith-Based Mental Wellness Companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Chat Header section
          Container(
            // Padding around the header
            padding: const EdgeInsets.all(16),
            // Child is a row with avatar, info, and history button
            child: Row(
              children: [
                // Circular avatar container
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  // Icon inside the avatar
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                  ),
                ),
                // Spacing
                const SizedBox(width: 12),
                // Expanded column for counselor info
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Counselor name
                      Text(
                        'AI Islamic Counselor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Spacing
                      SizedBox(height: 4),
                      // Status text
                      Text(
                        'Online • Confidential',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                // History button
                IconButton(
                  icon: const Icon(Icons.history, color: Color(0xFF2E7D32)),
                  onPressed: () {
                    // Navigate to ChatHistoryScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatHistoryScreen(),
                      ),
                    );
                  },
                  tooltip: 'View Chat History',
                ),
              ],
            ),
          ),
          // Chat Messages section
          Expanded(
            // ListView to display messages
            child: ListView.builder(
              // Attach the scroll controller
              controller: _scrollController,
              // Padding around the list
              padding: const EdgeInsets.all(16),
              // Item count includes messages and loading indicator
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              // Builder for each item
              itemBuilder: (context, index) {
                // If it's the loading item
                if (index == _messages.length && _isLoading) {
                  // Return a loading indicator
                  return const Center(child: CircularProgressIndicator());
                }
                // Get the message at this index
                final message = _messages[index];
                // Return the message bubble widget
                return _buildMessageBubble(
                  context: context,
                  message: message['content']!,
                  isUser: message['role'] == 'user',
                  time: message['time']!,
                );
              },
            ),
          ),
          // Input Area section
          Container(
            // Padding around the input area
            padding: const EdgeInsets.all(16),
            // Decoration with white background and shadow
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            // Child is a column with text field, button, and disclaimer
            child: Column(
              children: [
                // Row with text field and send button
                Row(
                  children: [
                    // Expanded text field
                    Expanded(
                      child: TextField(
                        // Attach the controller
                        controller: _controller,
                        // Decoration for the text field
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        // On submit, send the message
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    // Spacing
                    const SizedBox(width: 8),
                    // Send button
                    ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
                // Spacing
                const SizedBox(height: 8),
                // Disclaimer text
                const Text(
                  'AI-powered guidance. For emergencies, please contact a professional.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a message bubble for chat messages
  Widget _buildMessageBubble({
    required BuildContext context,
    required String message,
    required bool isUser,
    required String time,
  }) {
    // Align the bubble to the right for user, left for assistant
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      // Container for the bubble
      child: Container(
        // Margin below the bubble
        margin: const EdgeInsets.only(bottom: 16),
        // Padding inside the bubble
        padding: const EdgeInsets.all(16),
        // Decoration with color and rounded corners
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2E7D32) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        // Constraints for max width
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        // Child is a column with message text and time
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message text
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            // Spacing
            const SizedBox(height: 8),
            // Time text
            Text(
              time,
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
