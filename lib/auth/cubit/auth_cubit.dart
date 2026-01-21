import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_state.dart';
import 'package:flutter_herodex3000/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    await analytics.logLogin(loginMethod: "email");
    await analytics.logEvent(
      name: "login_email_user",
      parameters: {
        "method": "email",
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    );
    await _authRepository.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  Future<void> signUp(String email, String password) async{
    await _authRepository.signUp(email: email, password: password);
  }
}