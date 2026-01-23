import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
 
  User? get currentUser => _firebaseAuth.currentUser;
 
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
 
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e, st) {
      debugPrint("🔴 Error: $e Stacktrace: $st");
      throw FirebaseAuthException(code: e.code, message: e.message, email: e.email);
    }catch(e, st){
      rethrow;
    }
  }
 
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
 
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}