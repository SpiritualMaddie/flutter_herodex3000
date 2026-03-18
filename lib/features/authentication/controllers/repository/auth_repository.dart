import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

///  
/// Repository pattern for Firebase Authentication operations.
/// 
/// Handles all authentication logic including sign in, sign up, and sign out.
/// This class abstracts Firebase Auth from the rest of the app, making it
/// easier to test and maintain.
/// 

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// Creates an AuthRepository.
  /// 
  /// [firebaseAuth] can be injected for testing purposes.
  /// If not provided, uses the default FirebaseAuth instance.
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
 
  /// Returns the currently signed-in user, or null if no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;
 
  /// Stream that emits the current user whenever auth state changes.
  /// 
  /// Emits null when user signs out, and User object when user signs in.
  /// Used by AuthCubit to automatically update app state on auth changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
 
  /// Signs in a user with email and password.
  /// 
  /// Throws [FirebaseAuthException] if credentials are invalid or other
  /// Firebase-specific errors occur (wrong password, user not found, etc.).
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('🔴 AuthRepository.signIn FirebaseAuthException: code=${e.code} message=${e.message}\n$st');
      rethrow; // Let the UI handle specific error codes
    } catch (e, st) {
      debugPrint('🔴 AuthRepository.signIn unexpected error: $e\n$st');
      throw Exception('Sign in failed: $e');
    }
  }
 
  /// Creates a new user account with email and password.
  /// 
  /// Throws [FirebaseAuthException] if account creation fails.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('🔴 AuthRepository.signUp FirebaseAuthException: code=${e.code} message=${e.message}\n$st');
      rethrow; // Let the UI handle specific error codes
    } catch (e, st) {
      debugPrint('🔴 AuthRepository.signUp unexpected error: $e\n$st');
      throw Exception('Sign up failed: $e');
    }
  }
 
  /// Signs out the current user.
  /// 
  /// Clears the user session and triggers authStateChanges to emit null.
  /// Safe to call even if no user is currently signed in.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e, st) {
      debugPrint('🔴 AuthRepository.signOut FirebaseAuthException: code=${e.code} message=${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthRepository.signOut unexpected error: $e\n$st');
      throw Exception('Sign out failed: $e');
    }
  }
}