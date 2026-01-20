import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/resources_screen.dart';

class EditResourceDialog extends StatefulWidget {
  final ResourceItem resource;

  const EditResourceDialog({super.key, required this.resource});

  @override
  State<EditResourceDialog> createState() => _EditResourceDialogState();
}

class _EditResourceDialogState extends State<EditResourceDialog> {
  late TextEditingController _titleController;
  late TextEditingController _quoteController;
  late TextEditingController _sourceController;
  late TextEditingController _mediaUrlController;

  String _category = 'Mental Health';
  String _mediaType = 'image';

  final List<String> _categories = [
    'Mental Health',
    'Grief',
    'Anxiety',
  ];

  final List<String> _mediaTypes = [
    'image',
    'video',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.resource.title);
    _quoteController = TextEditingController(text: widget.resource.quote);
    _sourceController = TextEditingController(text: widget.resource.source);
    _mediaUrlController = TextEditingController(text: widget.resource.mediaUrl);

    _category = widget.resource.category;
    _mediaType = widget.resource.mediaType;
  }

  Future<void> _updateResource() async {
    await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.resource.id)
        .update({
      'title': _titleController.text.trim(),
      'quote': _quoteController.text.trim(),
      'source': _sourceController.text.trim(),
      'category': _category,
      'mediaUrl': _mediaUrlController.text.trim(),
      'mediaType': _mediaType,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resource updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Resource'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _inputField('Title', _titleController),
            const SizedBox(height: 12),
            _inputField('Quote / Verse', _quoteController, maxLines: 3),
            const SizedBox(height: 12),
            _inputField('Source', _sourceController),
            const SizedBox(height: 12),
            _inputField('Media URL', _mediaUrlController),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mediaType,
              items: _mediaTypes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _mediaType = v!),
              decoration: const InputDecoration(
                labelText: 'Media Type',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
          ),
          onPressed: _updateResource,
          child: const Text('Update'),
        ),
      ],
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
