import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class BrandHomeScreen extends StatefulWidget {
  const BrandHomeScreen({super.key});

  @override
  State<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends State<BrandHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BrandDashboardTab(),
    const ContentRequestsTab(),
    const BrandProfileTab(),
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Content',
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

class BrandDashboardTab extends StatelessWidget {
  const BrandDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Brand Dashboard'),
    );
  }
}

class ContentRequestsTab extends StatelessWidget {
  const ContentRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Content Requests'),
    );
  }
}

class BrandProfileTab extends StatelessWidget {
  const BrandProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Brand Profile'),
          ElevatedButton(
            onPressed: () => authService.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
