import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitpro/auth/login_screen.dart';
import 'package:tiny_storage/tiny_storage.dart';
import 'package:tiny_locator/tiny_locator.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  User? _currentUser;
  String? _photoURL;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadStoredImage();
  }

  Future<void> _loadStoredImage() async {
    final storage = locator.get<TinyStorage>();

    // Try to load locally stored file
    final storedFile = storage.get('user_profile_image_file');
    if (storedFile is Map && storedFile['path'] != null) {
      final file = File(storedFile['path']);
      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
        return;
      }
    }

    // Fallback to stored URL
    final storedData = storage.get('user_profile_image');
    if (storedData is Map && storedData['url'] != null) {
      setState(() {
        _photoURL = storedData['url'];
      });
    } else {
      setState(() {
        _photoURL = _currentUser?.photoURL;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        _profileImage = imageFile;
      });

      await _uploadAndSaveImage(imageFile);
    }
  }

  Future<void> _uploadAndSaveImage(File image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${_currentUser!.uid}.jpg');

      await storageRef.putFile(image);
      final downloadURL = await storageRef.getDownloadURL();

      // Save image URL
      final localStorage = locator.get<TinyStorage>();
      localStorage.set('user_profile_image', {'url': downloadURL});

      // Save file locally
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/profile_${_currentUser!.uid}.jpg';
      final localFile = await image.copy(localPath);

      // Save local path
      localStorage.set('user_profile_image_file', {'path': localFile.path});

      // Update Firebase Auth profile
      await _currentUser!.updatePhotoURL(downloadURL);
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;

      setState(() {
        _profileImage = localFile;
        _photoURL = downloadURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = _currentUser?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : _photoURL != null
                          ? NetworkImage(_photoURL!)
                          : const AssetImage(
                              'assets/images/profile_placeholder.png',
                            ) as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.deepPurple, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            if (_isUploading) ...[
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
            ],
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Change Profile Photo'),
            ),
            const SizedBox(height: 16),
            Text(email,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                //backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
