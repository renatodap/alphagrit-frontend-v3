import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alphagrit/app/theme/theme.dart';
import 'package:alphagrit/features/community/community_controller.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final int programId;

  const CreatePostScreen({
    super.key,
    required this.programId,
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(communityFeedControllerProvider(widget.programId).notifier);

      // Upload image if selected
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await controller.uploadImage(_selectedImage!);
      }

      // Create post
      await controller.createPost(
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
        photoUrl: photoUrl,
      );

      if (mounted) {
        context.pop(); // Go back to feed
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GritColors.black,
      appBar: AppBar(
        title: const Text(
          'CREATE POST',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _submitPost,
              child: const Text(
                'POST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Error Message
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GritColors.red.withOpacity(0.1),
                      border: Border.all(color: GritColors.red, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: GritColors.red, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: GritColors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title Field (Optional)
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title (optional)',
                    hintStyle: TextStyle(
                      color: GritColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C34),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF4A4A52),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF4A4A52),
                        width: 2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Message Field
                TextFormField(
                  controller: _messageController,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share your progress, thoughts, or motivation...',
                    hintStyle: TextStyle(
                      color: GritColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C34),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF4A4A52),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF4A4A52),
                        width: 2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 2,
                      ),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _selectedImage == null &&
                        _titleController.text.trim().isEmpty) {
                      return 'Please add a title, message, or image';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Image Picker
                if (_imageBytes == null) ...[
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C34),
                        border: Border.all(
                          color: const Color(0xFF4A90E2).withOpacity(0.5),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 64,
                            color: const Color(0xFF4A90E2).withOpacity(0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ADD IMAGE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: const Color(0xFF4A90E2).withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Optional - Max 1920x1920px',
                            style: TextStyle(
                              fontSize: 12,
                              color: GritColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Image Preview
                  Stack(
                    children: [
                      ClipRect(
                        child: Image.memory(
                          _imageBytes!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: _isUploading ? null : _removeImage,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: GritColors.black.withOpacity(0.7),
                            foregroundColor: GritColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Guidelines Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C34).withOpacity(0.5),
                    border: Border.all(
                      color: const Color(0xFF4A4A52),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF4A90E2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'POSTING GUIDELINES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: GritColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Be respectful and supportive\n'
                        '• Share genuine progress and experiences\n'
                        '• No spam or promotional content\n'
                        '• Keep it relevant to Winter Arc',
                        style: TextStyle(
                          fontSize: 12,
                          color: GritColors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isUploading)
            Container(
              color: GritColors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF4A90E2),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'POSTING...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
