import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/creator_profile.dart';
import 'edit_profile_screen.dart';

class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  int _selectedIndex = 0;

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
          Center(
            child: Text('Welcome, ${user?.email ?? 'Creator'}!'),
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
