import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorHomeScreen extends StatelessWidget {
  const CreatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authService.signOut();
                // No need to navigate, AuthWrapper will handle it
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${authService.currentUser?.email ?? 'Creator'}!'),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home'),
    );
  }
}

class CreatorProfileTab extends StatefulWidget {
  const CreatorProfileTab({super.key});

  @override
  State<CreatorProfileTab> createState() => _CreatorProfileTabState();
}

class _CreatorProfileTabState extends State<CreatorProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    print('Loading profile for user: ${user?.uid}');
    
    if (user == null) {
      print('No user found during profile load');
      if (mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        print('Redirecting to login...');
        authService.signOut();
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _nameController.text = user.displayName ?? '';
          _bioController.text = userDoc.data()?['bio'] ?? '';
          _isInitialized = true;
          print('Profile loaded successfully');
          print('Display Name: ${_nameController.text}');
          print('Bio: ${_bioController.text}');
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    print('Update profile button pressed');
    
    if (_formKey.currentState!.validate()) {
      print('Form validation passed');
      setState(() {
        _isLoading = true;
        print('Set loading state to true');
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        print('Current user: ${user?.uid}');
        
        if (user != null) {
          print('Updating profile for user: ${user.uid}');
          print('New display name: ${_nameController.text}');
          print('New bio: ${_bioController.text}');

          // Update Firebase Auth display name
          await user.updateDisplayName(_nameController.text);
          print('Firebase Auth display name updated successfully');

          // Update Firestore data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'displayName': _nameController.text,
            'bio': _bioController.text,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('Firestore profile data updated successfully');

          if (mounted) {
            print('Showing success message');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          print('Error: No user found');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No user found'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            print('Set loading state back to false');
          });
        }
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = FirebaseAuth.instance.currentUser;
    print('Building profile screen for user: ${user?.uid}');

    // Redirect if not authenticated
    if (user == null) {
      print('User is null, redirecting to login...');
      Future.microtask(() => authService.signOut());
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show loading while initializing
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show loading during updates
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    print('Display name validation failed: empty value');
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    print('Update button tapped');
                    _updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Email: ${user!.email}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
