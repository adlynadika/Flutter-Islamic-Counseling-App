import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_upload_screen.dart';
import 'resource_detail_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isAdmin = false;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(user.uid)
        .get();

    if (!_mounted) return;

    setState(() {
      _isAdmin = doc.exists && (doc.data()?['isAdmin'] == true);
    });
  }

  Stream<List<ResourceItem>> _resourcesStream() {
    return FirebaseFirestore.instance
        .collection('resources')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ResourceItem.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Column(
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
                    if (_isAdmin)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminUploadScreen(),
                            ),
                          );
                        },
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearch(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildResources(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search resources...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('All', Icons.menu_book),
          _filterChip('Mental Health', Icons.psychology),
          _filterChip('Grief', Icons.favorite),
          _filterChip('Anxiety', Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    final selected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        selectedColor: const Color(0xFF2E7D32),
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
        label: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => setState(() => _selectedFilter = label),
      ),
    );
  }

  Widget _buildResources() {
    return StreamBuilder<List<ResourceItem>>(
      stream: _resourcesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data ?? [];
        final query = _searchController.text.toLowerCase();

        final items = data.where((r) {
          final matchesFilter =
              _selectedFilter == 'All' || r.category == _selectedFilter;
          final matchesSearch = r.title.toLowerCase().contains(query) ||
              r.quote.toLowerCase().contains(query) ||
              r.source.toLowerCase().contains(query);
          return matchesFilter && matchesSearch;
        }).toList();

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Text('No resources found'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount(context),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _resourceCard(context, items[index]),
        );
      },
    );
  }

  Widget _resourceCard(BuildContext context, ResourceItem r) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResourceDetailScreen(
              resource: r,
              isAdmin: _isAdmin,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isAdmin)
                Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminUploadScreen(resource: r),
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Resource?'),
                            content: const Text(
                                'Are you sure you want to delete this resource?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('resources')
                              .doc(r.id)
                              .delete();
                        }
                      }
                    },
                  ),
                ),

              // 🔥 MEDIA (IMAGE / VIDEO THUMBNAIL)
              if (r.mediaUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.network(
                          r.mediaType == 'video'
                              ? (_getYoutubeId(r.mediaUrl).isNotEmpty
                                  ? 'https://img.youtube.com/vi/${_getYoutubeId(r.mediaUrl)}/0.jpg'
                                  : 'https://via.placeholder.com/480x270.png?text=No+Thumbnail')
                              : r.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        if (r.mediaType == 'video')
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 60,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // 🔥 TITLE
              Text(
                r.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // 🔥 QUOTE
              Text(
                r.quote,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              // 🔥 SOURCE (GREEN + BOLD ITALIC)
              Text(
                r.source.isNotEmpty ? 'Source: ${r.source}' : 'Source: Unknown',
                style: const TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32), // GREEN
                ),
              ),

              const SizedBox(height: 6),

              // 🔥 CATEGORY CHIP
              Chip(
                label: Text(r.category, style: const TextStyle(fontSize: 10)),
                backgroundColor: const Color(0xFFE8F5E9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }

    final match = RegExp(r"v=([a-zA-Z0-9_-]{11})").firstMatch(url);
    return match?.group(1) ?? '';
  }
}

class ResourceItem {
  final String id;
  final String title;
  final String category;
  final String quote;
  final String source;
  final String mediaUrl;
  final String mediaType;

  ResourceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.quote,
    required this.source,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory ResourceItem.fromFirestore(String id, Map<String, dynamic> data) {
    return ResourceItem(
      id: id,
      title: (data['title'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      quote: (data['quote'] ?? '').toString(),
      source: (data['source'] ?? '').toString(),
      mediaUrl: (data['mediaUrl'] ?? '').toString(),
      mediaType: (data['mediaType'] ?? 'image').toString(),
    );
  }
}
