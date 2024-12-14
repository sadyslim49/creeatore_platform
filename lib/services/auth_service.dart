import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/creator_profile.dart';

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

  // Get creator profile stream
  Stream<CreatorProfile?> creatorProfileStream(String uid) {
    print('Fetching profile stream for uid: $uid');
    return firestore
        .collection('creators')
        .doc(uid)
        .snapshots()
        .map((doc) {
          print('Got profile snapshot: ${doc.exists ? 'exists' : 'does not exist'}');
          if (!doc.exists) {
            print('Creating new profile for user');
            final user = auth.currentUser;
            if (user != null) {
              final newProfile = CreatorProfile(
                uid: user.uid,
                email: user.email!,
                displayName: user.displayName ?? user.email!.split('@')[0],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              firestore
                  .collection('creators')
                  .doc(uid)
                  .set(newProfile.toMap())
                  .then((_) => print('New profile created successfully'))
                  .catchError((e) => print('Error creating profile: $e'));
              return newProfile;
            }
            return null;
          }
          return CreatorProfile.fromMap(doc.data()!);
        });
  }

  // Get creator profile
  Future<CreatorProfile?> getCreatorProfile(String uid) async {
    final doc = await firestore.collection('creators').doc(uid).get();
    return doc.exists ? CreatorProfile.fromMap(doc.data()!) : null;
  }

  // Update creator profile
  Future<void> updateCreatorProfile(CreatorProfile profile) async {
    await firestore
        .collection('creators')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    print('Creating user document for: ${user.uid}');
    final creatorProfile = CreatorProfile(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName ?? user.email!.split('@')[0],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await firestore
          .collection('creators')
          .doc(user.uid)
          .set(creatorProfile.toMap());
      print('User document created successfully');
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

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

  String _handleAuthException(dynamic e) {
    print('Auth Error: $e');
    if (e is FirebaseAuthException) {
      return e.message ?? 'Authentication error occurred';
    }
    return e.toString();
  }
}
