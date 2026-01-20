import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'resources_screen.dart'; // Import this to access ResourceItem model

class AdminUploadScreen extends StatefulWidget {
  final ResourceItem? resource; // <-- for editing

  const AdminUploadScreen({super.key, this.resource});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  // ================= CONTROLLERS =================
  final _titleController = TextEditingController();
  final _quoteController = TextEditingController();
  final _sourceController = TextEditingController();
  final _mediaUrlController = TextEditingController();

  String _category = 'Mental Health';
  String _mediaType = 'image'; // image | video
  String _uploadMode = 'url'; // url | file
  String? _selectedAsset;

  bool _isUploading = false;

  // ================= LISTS =================
  final List<String> _categories = [
    'Mental Health',
    'Grief',
    'Anxiety',
  ];

  final List<String> _mediaTypes = ['image', 'video'];
  final List<String> _uploadModes = ['url', 'file'];

  // ASSETS
  final List<String> _imageAssets = [
    'assets/images/pray.png',
    'assets/images/duainnerpeace.png',
  ];

  final List<String> _videoAssets = [
    'assets/videos/dhizkrmate.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _loadResourceData();
  }

  void _loadResourceData() {
    if (widget.resource != null) {
      _titleController.text = widget.resource!.title;
      _quoteController.text = widget.resource!.quote;
      _sourceController.text = widget.resource!.source;
      _category = widget.resource!.category;
      _mediaType = widget.resource!.mediaType;
      _mediaUrlController.text = widget.resource!.mediaUrl;

      // If it was uploaded from file
      if (widget.resource!.mediaUrl.startsWith('assets/')) {
        _uploadMode = 'file';
        _selectedAsset = widget.resource!.mediaUrl;
      }
    }
  }

  // ================= VALIDATION =================
  bool _isValidImageUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath == true &&
        (url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif'));
  }

  bool _isValidYoutubeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) return false;

    if (uri.host.contains('youtube.com') && uri.queryParameters['v'] != null) {
      return true;
    }

    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return true;
    }

    return false;
  }

  // ================= UPLOAD =================
  Future<void> _uploadResource() async {
    String? mediaValue;

    if (_titleController.text.isEmpty ||
        _quoteController.text.isEmpty ||
        _sourceController.text.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    // ===== URL MODE =====
    if (_uploadMode == 'url') {
      if (_mediaUrlController.text.isEmpty) {
        _showError('Please enter a media URL');
        return;
      }

      if (_mediaType == 'image' &&
          !_isValidImageUrl(_mediaUrlController.text)) {
        _showError('Invalid image URL');
        return;
      }

      if (_mediaType == 'video' &&
          !_isValidYoutubeUrl(_mediaUrlController.text)) {
        _showError('Invalid YouTube URL');
        return;
      }

      mediaValue = _mediaUrlController.text.trim();
    }

    // ===== FILE MODE =====
    else {
      if (_selectedAsset == null) {
        _showError('Please select a file');
        return;
      }

      mediaValue = _selectedAsset;
    }

    setState(() => _isUploading = true);

    try {
      // ================= EDIT MODE =================
      if (widget.resource != null) {
        await FirebaseFirestore.instance
            .collection('resources')
            .doc(widget.resource!.id)
            .update({
          'title': _titleController.text.trim(),
          'quote': _quoteController.text.trim(),
          'source': _sourceController.text.trim(),
          'category': _category,
          'mediaUrl': mediaValue,
          'mediaType': _mediaType,
          'uploadMode': _uploadMode,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource updated successfully')),
        );
      }

      // ================= ADD MODE =================
      else {
        await FirebaseFirestore.instance.collection('resources').add({
          'title': _titleController.text.trim(),
          'quote': _quoteController.text.trim(),
          'source': _sourceController.text.trim(),
          'category': _category,
          'mediaUrl': mediaValue,
          'mediaType': _mediaType,
          'uploadMode': _uploadMode,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource uploaded successfully')),
        );

        _titleController.clear();
        _quoteController.clear();
        _sourceController.clear();
        _mediaUrlController.clear();
        setState(() => _selectedAsset = null);
      }
    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quoteController.dispose();
    _sourceController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final assetList = _mediaType == 'image' ? _imageAssets : _videoAssets;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource == null ? 'Admin Upload' : 'Edit Resource'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField('Title', _titleController),
            const SizedBox(height: 12),
            _inputField('Quote / Verse', _quoteController, maxLines: 3),
            const SizedBox(height: 12),
            _inputField('Source', _sourceController),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Upload Mode
            DropdownButtonFormField<String>(
              value: _uploadMode,
              items: _uploadModes
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _uploadMode = v!),
              decoration: const InputDecoration(
                labelText: 'Upload Mode',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Media Type
            DropdownButtonFormField<String>(
              value: _mediaType,
              items: _mediaTypes
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _mediaType = v!;
                  _selectedAsset = null;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Media Type',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // URL or FILE
            if (_uploadMode == 'url')
              _inputField(
                'Media URL',
                _mediaUrlController,
                hint: 'https://...',
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedAsset,
                items: assetList
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.split('/').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedAsset = v),
                decoration: const InputDecoration(
                  labelText: 'Select File',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadResource,
                child: Text(_isUploading
                    ? 'Uploading...'
                    : widget.resource == null
                        ? 'Upload'
                        : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
