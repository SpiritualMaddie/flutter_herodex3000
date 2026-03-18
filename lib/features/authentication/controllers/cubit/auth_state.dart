import "package:equatable/equatable.dart";
import "package:firebase_auth/firebase_auth.dart";

/// Base class for all authentication states in the app.
/// 
/// Uses Equatable for easy state comparison in BLoC pattern.
/// This allows AuthCubit to efficiently determine when to rebuild widgets.
/// 
/// The app has three possible auth states:
/// - [AuthInitial]: App just started, checking auth status
/// - [AuthAuthenticated]: User is logged in
/// - [AuthUnauthenticated]: User is logged out or session expired
/// 
abstract class AuthState extends Equatable {
  const AuthState();
 
  @override
  List<Object?> get props => [];
}
 
/// Initial state when app starts.
/// 
/// Used briefly while AuthCubit checks if there's an existing
/// Firebase session. Shows splash screen.
class AuthInitial extends AuthState {}
 
/// State when user is successfully authenticated.
/// 
/// Contains the [User] object with user information (email, uid, etc.).
/// This state grants access to the main app features (search, roster, etc.).
class AuthAuthenticated extends AuthState {
  /// The currently logged-in Firebase user.
  /// 
  /// Contains:
  /// - uid: Unique user ID (used for Firestore security rules)
  /// - email: User's email address
  /// - emailVerified: Whether email is verified (not used in this app)
  final User user;
 
  const AuthAuthenticated(this.user);
 
  /// Equatable comparison - two AuthAuthenticated states are equal
  /// if they contain the same user.
  @override
  List<Object?> get props => [user];
}
 
/// State when no user is logged in.
/// 
/// Shows the login screen and blocks access to authenticated features.
/// User must sign in or sign up to access the app.
class AuthUnauthenticated extends AuthState {}