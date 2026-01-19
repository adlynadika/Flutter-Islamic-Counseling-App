import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isWriteMode = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];

  String _category = 'Free Writing';
  String? _attachedImagePath;
  String _searchQuery = '';
  String _historyCategoryFilter = 'All';
  String? _aiRecommendation;
  bool _isLoadingRecommendation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Override build to return the widget tree for the screen
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold with body as a column
    return Scaffold(
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
          // Journal Header section
          Container(
            // Padding around the header
            padding: const EdgeInsets.all(16),
            // Child is a column with title, buttons, and privacy notice
            child: Column(
              children: [
                // Row with lock icon, title, and mode buttons
                Row(
                  children: [
                    // Lock icon
                    Icon(
                      Icons.lock,
                      color: Colors.purple[700],
                      size: 24,
                    ),
                    // Spacing
                    const SizedBox(width: 8),
                    // Journal title text
                    const Text(
                      'Private Journal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Spacer to push buttons to the right
                    const Spacer(),
                    // Write mode button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isWriteMode = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isWriteMode ? Colors.purple : Colors.white,
                        foregroundColor:
                            _isWriteMode ? Colors.white : Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Write'),
                    ),
                    // Spacing
                    const SizedBox(width: 8),
                    // History mode button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isWriteMode = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !_isWriteMode ? Colors.purple : Colors.white,
                        foregroundColor:
                            !_isWriteMode ? Colors.white : Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('History'),
                    ),
                  ],
                ),
                // Spacing
                const SizedBox(height: 8),
                // Privacy notice row
                Row(
                  children: [
                    // Lock icon
                    Icon(
                      Icons.lock,
                      color: Colors.orange[700],
                      size: 16,
                    ),
                    // Spacing
                    const SizedBox(width: 4),
                    // Privacy text
                    Text(
                      'Your entries are private and confidential',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content section
          Expanded(
            // Conditional child based on write mode
            child: _isWriteMode
                ? Column(
                    children: [
                      // Expanded write view
                      Expanded(child: _buildWriteView()),
                      // AI recommendation section
                      _buildAIRecommendation(),
                    ],
                  )
                : _buildHistoryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                DateTime.now().toString().split(' ')[0],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Entry title (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          // Category selector
          Row(
            children: [
              const Text('Category: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _category,
                items: [
                  'Gratitude',
                  'Challenges',
                  'Prayer',
                  'Du\'a',
                  'Free Writing'
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _category = v;
                  });
                },
              ),
              const Spacer(),
              // Image attach
              IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                tooltip: 'Attach image (optional)',
              ),
            ],
          ),
          if (_attachedImagePath != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: Image.file(
                File(_attachedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Formatting toolbar
          Row(
            children: [
              IconButton(
                  onPressed: () => _wrapSelection('**', '**'),
                  icon: const Icon(Icons.format_bold)),
              IconButton(
                  onPressed: () => _wrapSelection('*', '*'),
                  icon: const Icon(Icons.format_italic)),
              IconButton(
                  onPressed: () => _wrapSelection('__', '__'),
                  icon: const Icon(Icons.format_underlined)),
              const SizedBox(width: 8),
              const Text('Formatting tools (inserts markdown markers)',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          // Content Input
          TextField(
            controller: _contentController,
            maxLines: 12,
            decoration: InputDecoration(
              hintText:
                  'Pour your heart out... This is a safe space between you and Allah.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          // Inspiration Prompts (faith-based)
          const Text(
            'Guided prompts:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPromptButton('What blessing am I grateful for today?'),
              _buildPromptButton(
                  'Which challenge can I bring to Allah in dua?'),
              _buildPromptButton('How did I feel close to Allah today?'),
              _buildPromptButton(
                  'Who needs my prayers and what should I ask for?'),
              _buildPromptButton('What verse comforts me today?'),
            ],
          ),
          const SizedBox(height: 16),
          // Save Entry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_contentController.text.isNotEmpty) {
                  // Show loading for AI recommendation
                  setState(() {
                    _isLoadingRecommendation = true;
                  });

                  final suggestedVerse =
                      await _suggestVerse(_contentController.text, _category);

                  final entry = {
                    'title': _titleController.text.isEmpty
                        ? 'Untitled Entry'
                        : _titleController.text,
                    'content': _contentController.text,
                    'date': DateTime.now(),
                    'category': _category,
                    'imagePath': _attachedImagePath,
                    'suggestedVerse': suggestedVerse,
                  };
                  setState(() {
                    _entries.add(entry);
                    _aiRecommendation = suggestedVerse;
                    _isLoadingRecommendation = false;
                    _titleController.clear();
                    _contentController.clear();
                    _attachedImagePath = null;
                  });

                  // Try saving to Firestore (via REST service)
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final ok = await FirestoreService()
                        .addDocument('journal_entries', {
                      'title': entry['title'],
                      'content': entry['content'],
                      'category': entry['category'],
                      'imagePath': entry['imagePath']?.toString(),
                      'suggestedVerse': entry['suggestedVerse'],
                      'timestamp': DateTime.now().toUtc(),
                      'uid': user?.uid,
                    });
                    if (!mounted) return;
                    if (ok) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Entry saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content:
                              Text('Saved locally, could not save remotely'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Saved locally, could not save remotely'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Save Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quranic Verse
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  '"And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me."',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '— Quran 2:186',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation() {
    if (_isLoadingRecommendation) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Getting AI Quranic recommendation...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_aiRecommendation != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF00897B),
                ),
                SizedBox(width: 8),
                Text(
                  'AI Quranic Recommendation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _aiRecommendation!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _aiRecommendation = null;
                  });
                },
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: Color(0xFF00897B)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHistoryView() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start writing to see your entries here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isWriteMode = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Write First Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _entries.where((e) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          ((e['title'] ?? '').toLowerCase().contains(q) ||
              (e['content'] ?? '').toLowerCase().contains(q));
      final matchesCategory = _historyCategoryFilter == 'All' ||
          (e['category'] ?? 'Free Writing') == _historyCategoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search entries...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() {
                    _searchQuery = v;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _historyCategoryFilter,
                items: [
                  'All',
                  'Gratitude',
                  'Challenges',
                  'Prayer',
                  'Du\'a',
                  'Free Writing'
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v != null) _historyCategoryFilter = v;
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[filtered.length - 1 - index]; // reverse
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(entry['title'] ?? 'Untitled'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry['content'] ?? ''),
                            const SizedBox(height: 12),
                            if ((entry['imagePath'] ?? '') != '') ...[
                              if (entry['imagePath'] != null)
                                Image.file(File(entry['imagePath'])),
                              const SizedBox(height: 8),
                            ],
                            if (entry['suggestedVerse'] != null) ...[
                              const Divider(),
                              Text(entry['suggestedVerse'],
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'))
                      ],
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.1 * 255).round()),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(entry['category'] ?? 'Free Writing',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry['content'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(entry['date']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _wrapSelection(String left, String right) {
    final sel = _contentController.selection;
    final fullText = _contentController.text;
    if (!sel.isValid || sel.isCollapsed) {
      // Insert markers at cursor
      final pos = sel.start >= 0 ? sel.start : fullText.length;
      final newText = fullText.replaceRange(pos, pos, '$left$right');
      _contentController.text = newText;
      _contentController.selection =
          TextSelection.collapsed(offset: pos + left.length);
    } else {
      final newText = fullText.replaceRange(sel.start, sel.end,
          '$left${fullText.substring(sel.start, sel.end)}$right');
      _contentController.text = newText;
      _contentController.selection = TextSelection(
          baseOffset: sel.start,
          extentOffset:
              sel.start + left.length + (sel.end - sel.start) + right.length);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 80);
      if (file != null) {
        setState(() {
          _attachedImagePath = file.path;
        });
      }
    } catch (e) {
      // ignoring errors for now
    }
  }

  Future<String> _suggestVerse(String content, String category) async {
    try {
      // Use AI to generate verse recommendation based on content and category
      final prompt = '''
Based on this journal entry content: "$content"
And category: "$category"

Recommend a suitable Quranic verse that would provide comfort, guidance, or reflection for this journal entry.

Please respond with:
1. The Quranic verse (include Surah name and verse number)
2. A brief explanation of why this verse is suitable for this journal entry
3. How it can help the person

Keep the response concise and compassionate.
''';

      final messages = [
        {
          'role': 'system',
          'content':
              'You are an Islamic counselor providing Quranic verse recommendations based on journal entries. Always provide authentic Quranic verses with proper references and meaningful explanations.'
        },
        {'role': 'user', 'content': prompt}
      ];

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization':
              'Bearer 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',
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
        // Fallback to simple suggestions if AI fails
        return _getFallbackVerse(content, category);
      }
    } catch (e) {
      // Fallback to simple suggestions
      return _getFallbackVerse(content, category);
    }
  }

  String _getFallbackVerse(String content, String category) {
    final lc = content.toLowerCase();
    if (lc.contains('grateful') || category == 'Gratitude') {
      return '"If you are grateful, I will surely increase you [in favor]." (Quran 14:7)';
    }
    if (lc.contains('fear') || lc.contains('anxious') || category == 'Prayer') {
      return '"And when My servants ask you concerning Me, indeed I am near..." (Quran 2:186)';
    }
    if (lc.contains('patience') ||
        lc.contains('trial') ||
        category == 'Challenges') {
      return '"So be patient. Indeed, the promise of Allah is truth." (Quran 30:60)';
    }
    if (lc.contains('forgive') || lc.contains('forgiveness')) {
      return '"And seek forgiveness of your Lord. Indeed, He is Forgiving." (Quran 11:3)';
    }
    return '"Indeed, with hardship comes ease." (Quran 94:6)';
  }

  Widget _buildPromptButton(String prompt) {
    return InkWell(
      onTap: () {
        _contentController.text = prompt;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: Text(
          prompt,
          style: TextStyle(
            fontSize: 12,
            color: Colors.purple[700],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}
