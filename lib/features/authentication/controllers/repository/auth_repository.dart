import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
class AuthRepository { // TODO error handling deluxe in detail it CAN NOT crash, ever
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
 
  User? get currentUser => _firebaseAuth.currentUser;
 
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
 
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('🔴 AuthRepository.signIn FirebaseAuthException: code=${e.code} message=${e.message}\n$st');
      // keep original exception so callers can inspect e.code
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthRepository.signIn unexpected error: $e\n$st');
      throw Exception('Sign in failed: $e');
    }
  }
 
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('🔴 AuthRepository.signUp FirebaseAuthException: code=${e.code} message=${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthRepository.signUp unexpected error: $e\n$st');
      throw Exception('Sign up failed: $e');
    }
  }
 
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