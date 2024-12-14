import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthService({
    required this.auth,
    required this.googleSignIn,
    required this.firestore,
  });

  // Get current user
  User? get currentUser => auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      print('Attempting to create account with email: $email');
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Account created successfully for user: ${result.user?.uid}');
      
      // Create user document in Firestore
      await _createUserDocument(result.user!);
      print('User document created in Firestore');
      
      return result;
    } catch (e) {
      print('Error in signUpWithEmail: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          throw 'An account already exists with this email';
        } else if (e.code == 'invalid-email') {
          throw 'Invalid email address';
        } else if (e.code == 'operation-not-allowed') {
          throw 'Email/password accounts are not enabled';
        } else if (e.code == 'weak-password') {
          throw 'Password is too weak';
        }
        throw 'Authentication error: ${e.message}';
      }
      throw 'Account creation failed: $e';
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }
      
      final result = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      print('Sign in successful for user: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Error in signInWithEmail: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          throw 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          throw 'Wrong password provided';
        } else if (e.code == 'invalid-email') {
          throw 'Invalid email address';
        } else if (e.code == 'user-disabled') {
          throw 'This account has been disabled';
        }
        throw 'Authentication error: ${e.message}';
      }
      throw 'Authentication error: $e';
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      
      // Create user document in Firestore if it's a new user
      if (result.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(result.user!);
      }
      
      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    await firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName ?? user.email?.split('@')[0],
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Handle Authentication Exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'operation-not-allowed':
          return 'This sign in method is not enabled.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred: $e';
  }
}
