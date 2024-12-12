import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ExploreTab(),
    const UploadTab(),
    const CreatorProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Explore Brands'),
    );
  }
}

class UploadTab extends StatelessWidget {
  const UploadTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Upload Content'),
    );
  }
}

class CreatorProfileTab extends StatelessWidget {
  const CreatorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Creator Profile'),
          ElevatedButton(
            onPressed: () => authService.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
