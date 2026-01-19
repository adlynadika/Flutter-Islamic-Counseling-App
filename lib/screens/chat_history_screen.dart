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

// ChatHistoryScreen is a StatefulWidget that displays the history of chat messages
class ChatHistoryScreen extends StatefulWidget {
  // Constructor for ChatHistoryScreen with optional key
  const ChatHistoryScreen({super.key});

  // Override createState to return the state class
  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

// _ChatHistoryScreenState is the state class for ChatHistoryScreen, managing the chat history display
class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // List to hold loaded chat messages
  final List<Map<String, String>> _messages = [];
  // Boolean to indicate if messages are being loaded
  bool _isLoading = true;

  // Override initState to initialize the state when the widget is created
  @override
  void initState() {
    // Call super.initState() for proper initialization
    super.initState();
    // Load the chat messages
    _loadMessages();
  }

  // Asynchronous method to load chat messages from Firestore
  Future<void> _loadMessages() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });
    // Try to load messages
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      // If no user, stop loading and return
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

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
        // Update the state to add loaded messages and stop loading
        setState(() {
          _messages.addAll(loadedMessages);
          _isLoading = false;
        });
      } else {
        // If response not successful, stop loading
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, stop loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Override build to return the widget tree for the screen
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold with app bar and body
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      // Body content based on loading state and messages
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(child: Text('No chat history available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(
                      context: context,
                      message: message['content']!,
                      isUser: message['role'] == 'user',
                      time: message['time']!,
                    );
                  },
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
