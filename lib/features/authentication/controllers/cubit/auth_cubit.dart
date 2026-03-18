import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/firebase.dart';
import 'package:flutter_herodex3000/barrel_files/authentication.dart';
import 'package:flutter_herodex3000/barrel_files/services.dart';

///
/// Cubit to handle Firebase Authentication via [AuthRepository]
///

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    /// Listen to firebase auth changes safely
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        try {
          debugPrint(
            '🔁 AuthCubit.authStateChanges -> uid=${user?.uid} email=${user?.email}',
          );
          if (user != null) {
            /// Set user ID in Crashlytics
            FirebaseService.setUserId(user.uid);
            emit(AuthAuthenticated(user));
          } else {
            FirebaseService.setUserId(null);
            emit(AuthUnauthenticated());
          }
        } catch (e, st) {
          debugPrint('⚠️ AuthCubit handler error: $e\n$st');
          FirebaseService.recordError(e, st, reason: 'authStateChanges handler');
          emit(AuthUnauthenticated());
        }
      },
      onError: (err, st) {
        debugPrint('⚠️ AuthCubit authStateChanges stream error: $err\n$st');
        FirebaseService.recordError(err, st, reason: 'authStateChanges stream');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email: email, password: password);
      /// Log successful login to Analytics
      await FirebaseService.logLogin("email");
      /// Success -> authStateChanges stream will emit authenticated
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔴 AuthCubit.signIn FirebaseAuthException: ${e.code} ${e.message}',
      );
      /// Log auth failures to Crashlytics (non-fatal)
      await FirebaseService.recordError(e, StackTrace.current, reason: 'signIn failed');
      /// Rethrow so UI can show user-facing messages, but don't crash here
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthCubit.signIn unexpected: $e\n$st');
      await FirebaseService.recordError(e, st, reason: 'signIn unexpected error');
      throw Exception('Sign in failed: $e'); // TODO - make sure better user message
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e, st) {
      /// Log but don't let signOut failure crash the app
      debugPrint('⚠️ AuthCubit.signOut error (repo): $e\n$st');
      await FirebaseService.recordError(e, st, reason: 'signOut failed'); // TODO - make sure better user message
    }

    try {
      /// WORKAROUND: Clearing SharedPreferences to prevent auth state confusion/stale state
      /// on re-login. This is NOT ideal but resolves a suspected race condition.
      // TODO: Investigate proper fix - likely related to
      // SharedPreferencesWithCache and Firebase Auth state interaction
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ AuthCubit: cleared SharedPreferences on signOut');
    } catch (e, st) {
      debugPrint('⚠️ AuthCubit: failed clearing SharedPreferences: $e\n$st');
      await FirebaseService.recordError(e, st, reason: 'SharedPreferences clear failed');
    }

    /// Ensure UI sees unauthenticated state
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
      /// Log successful signup to Analytics
      await FirebaseService.logSignUp("email");
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '🔴 AuthCubit.signUp FirebaseAuthException: ${e.code} ${e.message}',
      );
      await FirebaseService.recordError(e, StackTrace.current, reason: 'signUp failed');
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 AuthCubit.signUp unexpected: $e\n$st');
      await FirebaseService.recordError(e, st, reason: 'signUp unexpected error');
      throw Exception('Sign up failed: $e'); // TODO - make sure better user message
    }
  }
}
