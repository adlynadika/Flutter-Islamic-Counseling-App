// Import Flutter's material design widgets
import 'package:flutter/material.dart';
// Import Firebase Auth for user authentication
import 'package:firebase_auth/firebase_auth.dart';
// Import http for API calls
import 'package:http/http.dart' as http;
// Import convert for JSON
import 'dart:convert';
// Import Firestore service for database operations
import '../services/firestore_service.dart';

// ResourcesScreen is a StatefulWidget that displays Islamic resources like videos, images, and Quranic verses
class ResourcesScreen extends StatefulWidget {
  // Constructor for ResourcesScreen with optional key
  const ResourcesScreen({super.key});

  // Override createState to return the state class
  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

// _ResourcesScreenState is the state class for ResourcesScreen, managing resources display and interactions
class _ResourcesScreenState extends State<ResourcesScreen> {
  // Selected filter for resources
  String _selectedFilter = 'All';
  // Text controller for search input
  final TextEditingController _searchController = TextEditingController();
  // Daily image URL
  String _dailyImageUrl =
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
  // Daily verse
  String _dailyVerse =
      '"Those who believe and whose hearts find rest in the remembrance of Allah. Verily, in the remembrance of Allah do hearts find rest."';
  String _verseSource = '— Quran 13:28';

  // Override initState to initialize
  @override
  void initState() {
    // Call super.initState()
    super.initState();
    // Fetch daily image and verse
    _fetchDailyImage();
    _fetchDailyVerse();
  }

  // Override dispose to clean up resources
  @override
  void dispose() {
    // Dispose search controller
    _searchController.dispose();
    // Call super.dispose()
    super.dispose();
  }

  // Fetch daily image from Unsplash
  Future<void> _fetchDailyImage() async {
    // For now, use a static Islamic image
    setState(() {
      _dailyImageUrl =
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
    });
  }

  // Fetch daily verse from Quran API
  Future<void> _fetchDailyVerse() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.alquran.cloud/v1/ayah/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['data']['text'];
        final surah = data['data']['surah']['englishName'];
        final number = data['data']['numberInSurah'];
        setState(() {
          _dailyVerse = '"$text"';
          _verseSource = '— $surah $number';
        });
      }
    } catch (e) {
      // Keep default
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
              padding: const EdgeInsets.all(16),
              // Child is a column with various sections
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text
                  const Text(
                    'Islamic Resources',
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
                    'Guidance from Quran and Hadith for mental wellness.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Search Bar section
                  TextField(
                    // Attach controller
                    controller: _searchController,
                    // Decoration for the text field
                    decoration: InputDecoration(
                      hintText: 'Search resources...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    // On submit, record search
                    onSubmitted: (value) async {
                      // Get scaffold messenger
                      final messenger = ScaffoldMessenger.of(context);
                      // Try to record search
                      try {
                        // Get current user
                        final user = FirebaseAuth.instance.currentUser;
                        // Add search document
                        final ok = await FirestoreService()
                            .addDocument('resource_searches', {
                          'query': value,
                          'timestamp': DateTime.now().toUtc(),
                          'uid': user?.uid,
                        });
                        // Return if not mounted
                        if (!mounted) return;
                        // Show snackbar if successful
                        if (ok) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Search recorded'),
                              backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        // Ignore errors
                      }
                    },
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Filter Buttons section
                  SingleChildScrollView(
                    // Horizontal scroll
                    scrollDirection: Axis.horizontal,
                    // Child is a row of filter buttons
                    child: Row(
                      children: [
                        // All filter button
                        _buildFilterButton('All', Icons.menu_book),
                        // Spacing
                        const SizedBox(width: 12),
                        // Mental Health filter button
                        _buildFilterButton('Mental Health', Icons.psychology),
                        // Spacing
                        const SizedBox(width: 12),
                        // Grief filter button
                        _buildFilterButton('Grief', Icons.favorite),
                        // Spacing
                        const SizedBox(width: 12),
                        // Anxiety filter button
                        _buildFilterButton('Anxiety', Icons.cloud),
                      ],
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Media Section header
                  const Text(
                    'Inspiring Media',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Spacing
                  const SizedBox(height: 24),
                  // Daily Image section
                  const Text(
                    'Islamic Wallpaper of the Day',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Daily image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_dailyImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Quranic Verse of the Day section
                  const Text(
                    'Quranic Verse of the Day',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Verse image or text
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        Text(
                          _dailyVerse,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _verseSource,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  // Resource Cards section header
                  const Text(
                    'Quranic Verses for Wellness',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // First resource card
                  _buildResourceCard(
                    title: 'Finding Peace in Anxiety',
                    category: 'Mental Health',
                    quote:
                        'Those who believe and whose hearts find rest in the remembrance of Allah. Verily, in the remembrance of Allah do hearts find rest.',
                    source: '— Quran 13:28',
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Second resource card
                  _buildResourceCard(
                    title: 'Patience in Hardship',
                    category: 'Mental Health',
                    quote:
                        'And We will surely test you with something of fear and hunger and a loss of wealth and lives and fruits, but give good tidings to the patient.',
                    source: '— Quran 2:155',
                  ),
                  // Spacing
                  const SizedBox(height: 16),
                  // Third resource card
                  _buildResourceCard(
                    title: 'Hope and Gratitude',
                    category: 'Mental Health',
                    quote:
                        'If you are grateful, I will surely increase you [in favor].',
                    source: '— Quran 14:7',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build a filter button
  Widget _buildFilterButton(String label, IconData icon) {
    // Check if this filter is selected
    final isSelected = _selectedFilter == label;
    // Return ElevatedButton with icon
    return ElevatedButton.icon(
      // On pressed, update filter and record selection
      onPressed: () async {
        // Update selected filter
        setState(() {
          _selectedFilter = label;
        });
        // Get scaffold messenger
        final messenger = ScaffoldMessenger.of(context);
        // Try to record filter selection
        try {
          // Get current user
          final user = FirebaseAuth.instance.currentUser;
          // Add filter document
          final ok = await FirestoreService().addDocument('resource_filters', {
            'filter': label,
            'timestamp': DateTime.now().toUtc(),
            'uid': user?.uid,
          });
          // Return if not mounted
          if (!mounted) return;
          // Show snackbar if successful
          if (ok) {
            messenger.showSnackBar(const SnackBar(
                content: Text('Filter selected'),
                backgroundColor: Colors.green));
          }
        } catch (e) {
          // Ignore errors
        }
      },
      // Icon for the button
      icon: Icon(icon, size: 18),
      // Label text
      label: Text(label),
      // Button style based on selection
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF2E7D32) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        side: BorderSide(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String category,
    required String quote,
    required String source,
  }) {
    return InkWell(
      onTap: () async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          await FirestoreService().addDocument('resource_views', {
            'title': title,
            'category': category,
            'timestamp': DateTime.now().toUtc(),
            'uid': user?.uid,
          });
        } catch (e) {
          // ignore
        }
        if (!mounted) return;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('"$quote"'),
                    const SizedBox(height: 8),
                    Text(source,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close')),
                ],
              );
            });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
                const Icon(
                  Icons.menu_book,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32)
                              .withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"$quote"',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              source,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
