import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../models/creator_profile.dart';
import '../../models/reel.dart';
import '../../widgets/reel_card.dart';
import 'edit_profile_screen.dart';
import 'upload_reel_screen.dart';

class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFirestore();
  }

  Future<void> _addSampleReels() async {
    try {
      print('Adding sample reels...');
      final collectionRef = FirebaseFirestore.instance.collection('reels');
      
      final sampleReels = [
        {
          'creatorId': FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
          'videoUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          'caption': 'Big Buck Bunny - A Classic Animation',
          'thumbnailUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
          'createdAt': FieldValue.serverTimestamp(),
          'likes': '0',
          'views': '0',
        },
        {
          'creatorId': FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
          'videoUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          'caption': 'Elephants Dream - Creative Commons',
          'thumbnailUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
          'createdAt': FieldValue.serverTimestamp(),
          'likes': '0',
          'views': '0',
        },
        {
          'creatorId': FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
          'videoUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
          'caption': 'Tears of Steel - Sci-Fi Short',
          'thumbnailUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
          'createdAt': FieldValue.serverTimestamp(),
          'likes': '0',
          'views': '0',
        },
        {
          'creatorId': FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
          'videoUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'caption': 'For Bigger Blazes',
          'thumbnailUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
          'createdAt': FieldValue.serverTimestamp(),
          'likes': '0',
          'views': '0',
        },
        {
          'creatorId': FirebaseAuth.instance.currentUser?.uid ?? 'test_user',
          'videoUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          'caption': 'For Bigger Escapes',
          'thumbnailUrl': 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
          'createdAt': FieldValue.serverTimestamp(),
          'likes': '0',
          'views': '0',
        }
      ];

      // Add each reel with a slight delay to maintain order
      for (var i = 0; i < sampleReels.length; i++) {
        await Future.delayed(Duration(milliseconds: 500 * i));
        await collectionRef.add(sampleReels[i]);
        print('Added reel ${i + 1}/${sampleReels.length}');
      }
      print('All sample reels added successfully');
    } catch (e) {
      print('Error adding sample reels: $e');
    }
  }

  Future<void> _checkFirestore() async {
    try {
      print('Checking Firestore access...');
      final collectionRef = FirebaseFirestore.instance.collection('reels');
      
      // Try to get all documents
      final querySnapshot = await collectionRef.get();
      print('Collection exists: ${querySnapshot.docs.isNotEmpty}');
      print('Number of documents: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('No reels found. Adding sample reels...');
        await _addSampleReels();
      }

      // Try to access the test reel
      final docRef = collectionRef.doc('test_reel');
      final docSnapshot = await docRef.get();
      print('Test document exists: ${docSnapshot.exists}');
      if (docSnapshot.exists) {
        print('Test document data: ${docSnapshot.data()}');
      }
    } catch (e, stackTrace) {
      print('Firestore access error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Creator Dashboard' : 'Profile'),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome, ${user?.email ?? 'Creator'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Reels',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reels')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      print('Debug: Firestore connection details:');
                      print('Connection state: ${snapshot.connectionState}');
                      print('Has data: ${snapshot.hasData}');
                      print('Has error: ${snapshot.hasError}');
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final reels = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        try {
                          return Reel.fromMap(data, doc.id);
                        } catch (e) {
                          print('Error parsing reel ${doc.id}: $e');
                          return null;
                        }
                      })
                      .where((reel) => reel != null)
                      .cast<Reel>()
                      .toList();

                      if (reels.isEmpty) {
                        return const Center(
                          child: Text('No reels found. Create your first reel!'),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reels.length,
                        itemBuilder: (context, index) {
                          final reel = reels[index];
                          return SizedBox(
                            width: 300,  
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ReelCard(reel: reel),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UploadReelScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Create New Reel'),
                  ),
                ),
              ],
            ),
          ),
          // Profile Tab
          if (user != null)
            StreamBuilder<CreatorProfile?>(
              stream: authService.creatorProfileStream(user.uid),
              builder: (context, snapshot) {
                print('Profile stream state: ${snapshot.connectionState}');
                print('Profile stream data: ${snapshot.data}');
                print('Profile stream error: ${snapshot.error}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No profile data found'),
                  );
                }

                final profile = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profile.photoUrl != null
                              ? NetworkImage(profile.photoUrl!)
                              : null,
                          child: profile.photoUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            profile.bio!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                profile: profile,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: const Text('Email'),
                                subtitle: Text(profile.email),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Member Since'),
                                subtitle: Text(
                                  profile.createdAt.toLocal().toString().split(' ')[0],
                                ),
                              ),
                              const ListTile(
                                leading: Icon(Icons.star),
                                title: Text('Account Type'),
                                subtitle: Text('Creator'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
