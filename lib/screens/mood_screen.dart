// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import Firebase Auth for user authentication
import 'package:firebase_auth/firebase_auth.dart';
// Import Firestore service for database operations
import '../services/firestore_service.dart';
// Import AI service for generating recommendations
import '../services/ai_service.dart';

// MoodScreen is a StatefulWidget that allows users to track their mood and get AI recommendations
class MoodScreen extends StatefulWidget {
  // Constructor for MoodScreen with optional key
  const MoodScreen({super.key});

  // Override createState to return the state class
  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

// _MoodScreenState is the state class for MoodScreen, managing mood tracking and AI recommendations
class _MoodScreenState extends State<MoodScreen> {
  // Selected mood name
  String? _selectedMood;
  // Intensity level of the mood (1-5)
  double _intensity = 3.0;
  // Flag to show second step (context selection)
  bool _secondStep = false;
  // AI recommendation text
  String? _aiRecommendation;
  // Flag for loading AI recommendation
  bool _isLoadingRecommendation = false;

  // Selected trigger for the mood
  String? _selectedTrigger;
  // Selected location for the mood
  String? _selectedLocation;

  // Text controller for additional notes
  final TextEditingController _noteController = TextEditingController();

  // List of available moods with icons and colors
  final List<Map<String, dynamic>> _moods = [
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.green},
    {'name': 'Peaceful', 'icon': Icons.cloud, 'color': Colors.blue},
    {'name': 'Hopeful', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {
      'name': 'Calm',
      'icon': Icons.nightlight_round,
      'color': Colors.pinkAccent
    },
    {'name': 'Anxious', 'icon': Icons.warning, 'color': Colors.orange},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.grey},
    {'name': 'Angry', 'icon': Icons.flash_on, 'color': Colors.red},
    {'name': 'Stressed', 'icon': Icons.work, 'color': Colors.deepOrange},
    {'name': 'Confused', 'icon': Icons.help_outline, 'color': Colors.teal},
    {'name': 'Content', 'icon': Icons.tag_faces, 'color': Colors.indigo},
  ];

  // List of possible triggers for moods
  final List<String> _triggers = [
    'Work',
    'Family',
    'Health',
    'Financial',
    'Social Media',
    'Spiritual',
    'Other',
    'Not sure',
  ];

  // List of possible locations for moods
  final List<String> _locations = [
    'Home',
    'Work',
    'Mosque',
    'Commute',
    'Online',
    'Outside',
    'Other',
    'Not sure',
  ];

  // Override dispose to clean up resources
  @override
  void dispose() {
    // Dispose the text controller
    _noteController.dispose();
    // Call super.dispose()
    super.dispose();
  }

  // Asynchronous method to save the mood entry to Firestore
  Future<void> _saveMoodEntry() async {
    // Check if a mood is selected
    if (_selectedMood == null) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Note: Second step context fields are optional but helpful
    // Get scaffold messenger for showing snackbars
    final messenger = ScaffoldMessenger.of(context);
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    // Get current UTC time
    final now = DateTime.now().toUtc();
    // Prepare payload for Firestore
    final payload = {
      'mood': _selectedMood,
      'intensity': _intensity.toInt(),
      'trigger': _selectedTrigger ?? 'Not provided',
      'location': _selectedLocation ?? 'Not provided',
      'note': _noteController.text.trim(),
      'timestamp': now,
      'date': now.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'uid': user?.uid,
    };
    // Try to save the document
    try {
      // Add document to Firestore
      final ok = await FirestoreService().addDocument('mood_entries', payload);
      // Return if widget is not mounted
      if (!mounted) return;
      // If successful
      if (ok) {
        // Show success snackbar
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Mood logged successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Get AI recommendation after saving
        await _getAIRecommendation();
        // Reset state
        setState(() {
          _selectedMood = null;
          _intensity = 3.0;
          _noteController.clear();
          _secondStep = false;
          _selectedTrigger = null;
          _selectedLocation = null;
        });
      } else {
        // Show error snackbar
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not save mood entry right now'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Return if widget is not mounted
      if (!mounted) return;
      // Show error snackbar
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save mood entry right now'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Asynchronous method to get AI recommendation based on mood
  Future<void> _getAIRecommendation() async {
    // Return if no mood selected
    if (_selectedMood == null) return;

    // Set loading state
    setState(() {
      _isLoadingRecommendation = true;
    });

    // Try to get recommendation
    try {
      // Build additional context string
      final additionalContext = [
        if (_selectedTrigger != null) 'Trigger: $_selectedTrigger',
        if (_selectedLocation != null) 'Location: $_selectedLocation',
        if (_noteController.text.trim().isNotEmpty)
          'Note: ${_noteController.text.trim()}',
      ].join(', ');

      // Get recommendation from AI service
      final recommendation = await AIService().getQuranicVerseRecommendation(
        _selectedMood!,
        _intensity.toInt(),
        additionalContext:
            additionalContext.isNotEmpty ? additionalContext : null,
      );

      // Update state with recommendation
      setState(() {
        _aiRecommendation = recommendation;
        _isLoadingRecommendation = false;
      });
    } catch (e) {
      // On error, set fallback message
      setState(() {
        _aiRecommendation =
            'Unable to get recommendation right now. Please try again later.';
        _isLoadingRecommendation = false;
      });
    }
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
          // Main Content section
          Expanded(
            // SingleChildScrollView for scrollable content
            child: SingleChildScrollView(
              // Padding around the content
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              // Child is a column with various sections
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 8),
                  // Subtitle text
                  const Text(
                    'Track your emotional well-being with faith-based insights.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Quick calendar / view entries section
                  Row(
                    children: [
                      // Button to view entries by date
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Show date picker
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          // Return if context not mounted
                          if (!context.mounted) return;
                          // If date picked
                          if (picked != null) {
                            // Get mood entries for the date
                            final items = await FirestoreService()
                                .getMoodEntriesForDate(picked);
                            // Return if context not mounted
                            if (!context.mounted) return;
                            // Show dialog with entries
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                    'Entries for ${picked.month}/${picked.day}/${picked.year}'),
                                content: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                    maxWidth: double.maxFinite,
                                  ),
                                  child: items.isEmpty
                                      ? const Text('No entries for this date')
                                      : ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (c, i) {
                                            final it = items[i];
                                            return ListTile(
                                              title:
                                                  Text(it['mood'] ?? 'Unknown'),
                                              subtitle: Text(
                                                  'Intensity: ${it['intensity'] ?? '-'} - ${it['note'] ?? ''}'),
                                            );
                                          },
                                        ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Close'))
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('View by date',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      // Spacing
                      const SizedBox(width: 12),
                      // Quick Check-in text
                      const Text('Quick Check-in',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // Spacing
                  const SizedBox(height: 16),

                  // Conditional rendering based on _secondStep
                  if (!_secondStep) ...[
                    // First step: Select mood
                    const Text(
                      'Select your mood',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Spacing
                    const SizedBox(height: 12),
                    // Grid view for mood selection
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        // Get mood data
                        final mood = _moods[index];
                        // Check if selected
                        final isSelected = _selectedMood == mood['name'];
                        // Return InkWell for selection
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood['name'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Mood icon
                                Icon(
                                  mood['icon'],
                                  color:
                                      isSelected ? Colors.white : mood['color'],
                                  size: 32,
                                ),
                                // Spacing
                                const SizedBox(height: 8),
                                // Mood name text
                                Text(
                                  mood['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Spacing
                    const SizedBox(height: 16),
                    // Intensity level text
                    const Text('Intensity level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // Spacing
                    const SizedBox(height: 12),
                    // Slider for intensity
                    Slider(
                      value: _intensity,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          _intensity = value;
                        });
                      },
                    ),
                    // Spacing
                    const SizedBox(height: 8),
                    // Display current intensity level
                    Text('Level ${_intensity.toInt()}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    // Spacing
                    const SizedBox(height: 16),
                    // Next button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Check if mood selected
                              if (_selectedMood == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Select a mood first'),
                                        backgroundColor: Colors.orange));
                                return;
                              }
                              // Go to second step
                              setState(() {
                                _secondStep = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('Next',
                                    style: TextStyle(fontSize: 16))),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Second step: Context selection
                    const Text('Context (quick)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // Spacing
                    const SizedBox(height: 12),
                    // Trigger selection text
                    const Text('What triggered this mood? (tap one)'),
                    // Spacing
                    const SizedBox(height: 8),
                    // Wrap for trigger chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _triggers.map((t) {
                        // Check if selected
                        final isSel = _selectedTrigger == t;
                        // Return ChoiceChip
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSel,
                          selectedColor: Colors.pinkAccent,
                          onSelected: (_) {
                            setState(() {
                              _selectedTrigger = t;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    // Spacing
                    const SizedBox(height: 12),
                    // Location selection text
                    const Text('Where were you? (tap one)'),
                    // Spacing
                    const SizedBox(height: 8),
                    // Wrap for location chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locations.map((l) {
                        // Check if selected
                        final isSel = _selectedLocation == l;
                        // Return ChoiceChip
                        return ChoiceChip(
                          label: Text(l),
                          selected: isSel,
                          selectedColor: Colors.pinkAccent,
                          onSelected: (_) {
                            setState(() {
                              _selectedLocation = l;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    // Spacing
                    const SizedBox(height: 16),
                    // Note input text
                    const Text('Add a note (optional)'),
                    // Spacing
                    const SizedBox(height: 8),
                    // Text field for note
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'How are you feeling? Share more details...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // Spacing
                    const SizedBox(height: 16),
                    // Back and Save buttons
                    Row(
                      children: [
                        // Back button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _secondStep = false;
                                _selectedTrigger = null;
                                _selectedLocation = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.pinkAccent,
                            ),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Back')),
                          ),
                        ),
                        // Spacing
                        const SizedBox(width: 12),
                        // Save button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveMoodEntry,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Save')),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Spacing
                  const SizedBox(height: 24),
                  // Quranic verse section
                  Container(
                    // Full width
                    width: double.infinity,
                    // Padding inside
                    padding: const EdgeInsets.all(20),
                    // Decoration with green background
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Verse text
                    child: const Text(
                      '"If you are grateful, I will surely increase you [in favor]." (Quran 14:7)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // AI Recommendation Section
          if (_isLoadingRecommendation || _aiRecommendation != null)
            Container(
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
              child: _isLoadingRecommendation
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Getting your Quranic recommendation...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AI Quranic Recommendation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
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
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
