import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/auth_service.dart';
import '../../models/reel.dart';

class UploadReelScreen extends StatefulWidget {
  const UploadReelScreen({super.key});

  @override
  State<UploadReelScreen> createState() => _UploadReelScreenState();
}

class _UploadReelScreenState extends State<UploadReelScreen> {
  File? _videoFile;
  bool _isUploading = false;
  double _uploadProgress = 0;
  final _captionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = File(result.files.first.path!);
      });
    }
  }

  Future<void> _uploadReel() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Generate unique ID for the reel
      final reelId = const Uuid().v4();
      
      // Upload video to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reels')
          .child(user.uid)
          .child('$reelId.mp4');

      final uploadTask = storageRef.putFile(
        _videoFile!,
        SettableMetadata(contentType: 'video/mp4'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get video URL
      final videoUrl = await snapshot.ref.getDownloadURL();

      // Create reel document in Firestore
      final reel = Reel(
        id: reelId,
        creatorId: user.uid,
        videoUrl: videoUrl,
        caption: _captionController.text.trim(),
        createdAt: DateTime.now(), // This will be overwritten by server timestamp
      );

      await FirebaseFirestore.instance
          .collection('reels')
          .doc(reelId)
          .set(reel.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reel uploaded successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading reel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Reel'),
        actions: [
          if (_videoFile != null && !_isUploading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _uploadReel,
              tooltip: 'Upload Reel',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_videoFile == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickVideo,
                  icon: const Icon(Icons.video_library),
                  label: const Text('Select Video'),
                ),
              )
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/video_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                      Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (_isUploading)
                        Container(
                          color: Colors.black45,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  value: _uploadProgress,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write a caption for your reel...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
              enabled: !_isUploading,
            ),
          ],
        ),
      ),
    );
  }
}
