import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_state.dart';
import 'package:flutter_herodex3000/auth/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    // listen to firebase auth changes safely
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        try {
          debugPrint(
            '🔁 AuthCubit.authStateChanges -> uid=${user?.uid} email=${user?.email}',
          );
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        } catch (e, st) {
          debugPrint('⚠️ AuthCubit handler error: $e\n$st');
          emit(AuthUnauthenticated());
        }
      },
      onError: (err, st) {
        debugPrint('⚠️ AuthCubit authStateChanges stream error: $err\n$st');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    try {
      // TODO analytics
      await analytics.logLogin(loginMethod: "email");
      await _authRepository.signIn(email: email, password: password);
      // success -> authStateChanges stream will emit authenticated
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔴 AuthCubit.signIn FirebaseAuthException: ${e.code} ${e.message}',
      );
      // rethrow so UI can show user-facing messages, but don't crash here
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthCubit.signIn unexpected: $e\n$st');
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e, st) {
      // log but don't let signOut failure crash the app
      debugPrint('⚠️ AuthCubit.signOut error (repo): $e\n$st');
    }

    try {
      // WORKAROUND: Clearing SharedPreferences to prevent auth state confusion/stale state
      // on re-login. This is NOT ideal but resolves a suspected race condition.
      // TODO: Investigate proper fix - likely related to
      // SharedPreferencesWithCache and Firebase Auth state interaction
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ AuthCubit: cleared SharedPreferences on signOut');
    } catch (e, st) {
      debugPrint('⚠️ AuthCubit: failed clearing SharedPreferences: $e\n$st');
    }

    // Ensure UI sees unauthenticated state
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authRepository.signUp(email: email, password: password);
      // if additional profile writes happen elsewhere, they must handle their own errors
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔴 AuthCubit.signUp FirebaseAuthException: ${e.code} ${e.message}',
      );
      throw e;
    } catch (e, st) {
      debugPrint('🔴 AuthCubit.signUp unexpected: $e\n$st');
      throw Exception('Sign up failed: $e');
    }
  }
}
