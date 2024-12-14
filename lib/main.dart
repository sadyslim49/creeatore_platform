import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/creator/creator_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Initializing Firebase...');
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
      print('Firebase initialized for web');
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized for other platforms');
    }

    // Test Firebase connection
    final auth = FirebaseAuth.instance;
    print('Firebase Auth instance created: ${auth.hashCode}');
    
    // Test auth state
    auth.authStateChanges().listen((User? user) {
      print('Auth state changed. Current user: ${user?.email ?? 'None'}');
    });
    
    final firestore = FirebaseFirestore.instance;
    print('Firestore instance created: ${firestore.hashCode}');
  } catch (e) {
    print('Error initializing Firebase: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(
            auth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            firestore: FirebaseFirestore.instance,
          ),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Creeatore Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    print('AuthWrapper - Current user: ${user?.uid}');

    if (user == null) {
      return const LoginScreen();
    }
    return const CreatorHomeScreen();
  }
}
