import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    'Islamic Resources',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Guidance from Quran and Hadith for mental wellness.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  TextField(
                    controller: _searchController,
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
                    onSubmitted: (value) async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final ok = await FirestoreService()
                            .addDocument('resource_searches', {
                          'query': value,
                          'timestamp': DateTime.now().toUtc(),
                          'uid': user?.uid,
                        });
                        if (!mounted) return;
                        if (ok) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Search recorded'),
                              backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        // ignore
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('All', Icons.menu_book),
                        const SizedBox(width: 12),
                        _buildFilterButton('Mental Health', Icons.psychology),
                        const SizedBox(width: 12),
                        _buildFilterButton('Grief', Icons.favorite),
                        const SizedBox(width: 12),
                        _buildFilterButton('Anxiety', Icons.cloud),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Resource Cards
                  _buildResourceCard(
                    title: 'Finding Peace in Anxiety',
                    category: 'Mental Health',
                    quote:
                        'Those who believe and whose hearts find rest in the remembrance of Allah. Verily, in the remembrance of Allah do hearts find rest.',
                    source: '— Quran 13:28',
                  ),
                  const SizedBox(height: 16),
                  _buildResourceCard(
                    title: 'Patience in Hardship',
                    category: 'Mental Health',
                    quote:
                        'And We will surely test you with something of fear and hunger and a loss of wealth and lives and fruits, but give good tidings to the patient.',
                    source: '— Quran 2:155',
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildFilterButton(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return ElevatedButton.icon(
      onPressed: () async {
        setState(() {
          _selectedFilter = label;
        });
        final messenger = ScaffoldMessenger.of(context);
        try {
          final user = FirebaseAuth.instance.currentUser;
          final ok = await FirestoreService().addDocument('resource_filters', {
            'filter': label,
            'timestamp': DateTime.now().toUtc(),
            'uid': user?.uid,
          });
          if (!mounted) return;
          if (ok) {
            messenger.showSnackBar(const SnackBar(
                content: Text('Filter selected'),
                backgroundColor: Colors.green));
          }
        } catch (e) {
          // ignore
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
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
