import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;
  double _intensity = 3.0;
  bool _secondStep = false;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.green},
    {'name': 'Peaceful', 'icon': Icons.cloud, 'color': Colors.blue},
    {'name': 'Hopeful', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'name': 'Calm', 'icon': Icons.nightlight_round, 'color': Colors.purple},
    {'name': 'Anxious', 'icon': Icons.warning, 'color': Colors.orange},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.grey},
    {'name': 'Angry', 'icon': Icons.flash_on, 'color': Colors.red},
    {'name': 'Stressed', 'icon': Icons.work, 'color': Colors.deepOrange},
    {'name': 'Confused', 'icon': Icons.help_outline, 'color': Colors.teal},
    {'name': 'Content', 'icon': Icons.tag_faces, 'color': Colors.indigo},
  ];

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

  String? _selectedTrigger;
  String? _selectedLocation;

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodEntry() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // second step context fields are optional but helpful
    final messenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now().toUtc();
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
    try {
      final ok = await FirestoreService().addDocument('mood_entries', payload);
      if (!mounted) return;
      if (ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Mood logged successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedMood = null;
          _intensity = 3.0;
          _noteController.clear();
          _secondStep = false;
          _selectedTrigger = null;
          _selectedLocation = null;
        });
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not save mood entry right now'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save mood entry right now'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Column(
              children: [
                Text(
                  'Qalby2Heart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
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
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your emotional well-being with faith-based insights.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Quick calendar / view entries
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (!context.mounted) return;
                          if (picked != null) {
                            final items = await FirestoreService()
                                .getMoodEntriesForDate(picked);
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                    'Entries for ${picked.month}/${picked.day}/${picked.year}'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: items.isEmpty
                                      ? const Text('No entries for this date')
                                      : ListView.builder(
                                          shrinkWrap: true,
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
                      const SizedBox(width: 12),
                      const Text('Quick Check-in',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (!_secondStep) ...[
                    const Text(
                      'Select your mood',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        final mood = _moods[index];
                        final isSelected = _selectedMood == mood['name'];
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
                                Icon(
                                  mood['icon'],
                                  color:
                                      isSelected ? Colors.white : mood['color'],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
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
                    const SizedBox(height: 20),
                    const Text('Intensity level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 8),
                    Text('Level ${_intensity.toInt()}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedMood == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Select a mood first'),
                                        backgroundColor: Colors.orange));
                                return;
                              }
                              setState(() {
                                _secondStep = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32)),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('Next',
                                    style: TextStyle(fontSize: 16))),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text('Context (quick)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('What triggered this mood? (tap one)'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _triggers.map((t) {
                        final isSel = _selectedTrigger == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _selectedTrigger = t;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Where were you? (tap one)'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locations.map((l) {
                        final isSel = _selectedLocation == l;
                        return ChoiceChip(
                          label: Text(l),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _selectedLocation = l;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _secondStep = false;
                                _selectedTrigger = null;
                                _selectedLocation = null;
                              });
                            },
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Back')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveMoodEntry,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32)),
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Save')),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Quranic verse
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  const SizedBox(height: 24),
                  // Log Mood Entry Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMoodEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Mood Entry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
