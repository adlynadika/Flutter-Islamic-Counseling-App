import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'resources_screen.dart';

class ResourceDetailScreen extends StatefulWidget {
  final ResourceItem resource;
  final bool isAdmin;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
    required this.isAdmin,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    // INIT ASSET VIDEO
    if (widget.resource.mediaType == 'video' &&
        widget.resource.mediaUrl.startsWith('assets/')) {
      _videoController = VideoPlayerController.asset(widget.resource.mediaUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Info'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedia(r),
            const SizedBox(height: 20),
            Chip(
              label: Text(r.category),
              backgroundColor: const Color(0xFFE8F5E9),
            ),
            const SizedBox(height: 12),
            Text(
              r.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"${r.quote}"',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              r.source,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MEDIA =================
  Widget _buildMedia(ResourceItem r) {
    // IMAGE ASSET
    if (r.mediaType == 'image' && r.mediaUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(r.mediaUrl, fit: BoxFit.cover),
      );
    }

    // IMAGE URL
    if (r.mediaType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          r.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      );
    }

    // ASSET VIDEO
    if (r.mediaType == 'video' && _videoController != null) {
      if (!_videoController!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              IconButton(
                iconSize: 60,
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    // YOUTUBE VIDEO
    if (r.mediaType == 'video') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              'https://img.youtube.com/vi/${_getYoutubeId(r.mediaUrl)}/0.jpg',
              fit: BoxFit.cover,
            ),
            IconButton(
              iconSize: 60,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
              onPressed: () => _openUrl(r.mediaUrl),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ================= DELETE =================
  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await FirebaseFirestore.instance
          .collection('resources')
          .doc(widget.resource.id)
          .delete();

      Navigator.pop(context);
    }
  }

  // ================= HELPERS =================
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _getYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    return uri.host.contains('youtu.be')
        ? uri.pathSegments.first
        : uri.queryParameters['v'] ?? '';
  }
}
