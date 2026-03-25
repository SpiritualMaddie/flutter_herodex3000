import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/authentication.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/utils.dart';

///
/// Login screen with terminal/command center aesthetic.
/// 
/// Features:
/// - Email/password authentication via Firebase
/// - Sign-up modal dialog for new users
/// - Responsive design (centered on tablet/desktop)
/// 
/// Navigation:
/// - On successful login: AuthCubit emits AuthAuthenticated → Router redirects to /home
/// - On sign-up success: Modal closes automatically via BlocListener
/// 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Shows the sign-up modal dialog.
  /// Modal is dismissible by tapping outside (barrierDismissible: true).
  void _showEnlistModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const EnlistAgentModal(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles sign-in button press.
  /// 
  /// Validates form → calls AuthCubit.signIn() → shows errors if any.
  /// On success, AuthCubit automatically emits AuthAuthenticated and
  /// the router redirects to /home (no manual navigation needed).
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await context.read<AuthCubit>().signIn(email, password);
      // On success, AuthCubit emits authenticated → router handles redirect
    } on FirebaseAuthException catch (e) {
      // Firebase-specific errors (wrong password, user not found, etc.)
      if (!mounted) return;
      AppSnackbar.error(context, "❌ Sign in failed. \n${e.message}");
    } catch (e) {
      // Unexpected errors (network issues, etc.)
      if (!mounted) return;
      AppSnackbar.error(context, "❌ Sign in failed. \n${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return ResponsiveScaffold(
      backgroundColor: const Color(0xFF0A111A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              // Ensures content fills screen height for proper centering
              constraints: BoxConstraints(
                minHeight: height - MediaQuery.of(context).padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      // App logo
                      Image(
                        image: const AssetImage("assets/icons/app_icon.png"),
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 16),
                      // App title and tagline
                      const Text(
                        "HERODEX 3000",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        "REBUILDING THE WORLD, ONE HERO AT A TIME",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.cyan[200],
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Email field
                      _buildTerminalField(
                        "EMAIL ADDRESS",
                        _emailController,
                        false,
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      _buildTerminalField(
                        "PASSWORD",
                        _passwordController,
                        true,
                      ),
                      const SizedBox(height: 32),
                      // Sign in button
                      _buildPrimaryButton("ACCESS TERMINAL", _handleSignIn),
                      const SizedBox(height: 12),

                      // Sign up button
                      _buildSecondaryButton(
                        "SIGN UP NEW AGENT",
                        _showEnlistModal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a terminal-styled text field with label.
  /// 
  /// [label] - Field label (e.g., "EMAIL ADDRESS")
  /// [controller] - TextEditingController for form management
  /// [isPassword] - If true, obscures text input
  Widget _buildTerminalField(
    String label,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Input field with validation
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            // Email validation for non-password fields
            if (!isPassword && !value.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF121F2B),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF1A2E3D)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF00E5FF)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

/// Primary action button (cyan background, black text).
  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E5FF),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

 /// Secondary action button (outlined, no fill).
  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Color(0xFF1A2E3D)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ===========================================================================
// SIGN-UP MODAL
// ===========================================================================

/// Modal dialog for new agent enrollment (sign-up).
/// 
/// Features:
/// - Blur backdrop effect
/// - Form validation (email format, password length)
/// - Loading state during sign-up
/// - Auto-closes on successful authentication via BlocListener
/// 
/// Why StatefulWidget:
/// - Need local state for form controllers and loading indicator
/// - BlocListener triggers navigation only on AuthAuthenticated state
/// 
class EnlistAgentModal extends StatefulWidget {
  const EnlistAgentModal({super.key});

  @override
  State<EnlistAgentModal> createState() => _EnlistAgentModalState();
}

class _EnlistAgentModalState extends State<EnlistAgentModal> {
  final _formKeySignUp = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles sign-up form submission.
  /// 
  /// Validates → calls AuthCubit.signUp() → shows feedback.
  /// On success, BlocListener (in build()) auto-closes the dialog.
  Future<void> _handleSignUp() async {
    if (!_formKeySignUp.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().signUp(email, password);
      if (!mounted) return;
      AppSnackbar.success(context, "✅ Agent enrolled successfully. \nWelcome!");
    } on FirebaseAuthException catch (e) {
      // Firebase errors (email already in use, weak password, etc.)
      AppSnackbar.error(context, "❌ Sign up failed. \n${e.message}");
      
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, "❌ Enlistment failed. \n${e.toString()}");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Auto-close dialog when user becomes authenticated
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            try {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            } catch (_) {
              // Swallow navigation errors during simultaneous navigations (to avoid crashes)
            }
          });
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          constraints: BoxConstraints(
            maxWidth: context.maxContentWidth, // Responsive width
            maxHeight: double.infinity,
          ),
          backgroundColor: const Color(0xFF0D1721),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00E5FF), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  "NEW AGENT ENLISTMENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Form fields
                Form(
                  key: _formKeySignUp,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModalField("EMAIL ADDRESS", _emailController),
                      const SizedBox(height: 12),
                      _buildModalField(
                        "PASSWORD",
                        _passwordController,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button with loading indicator
                ElevatedButton(
                  onPressed: _loading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  ) 
                  : const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a simple underlined text field for the modal.
  /// 
  /// Validates:
  /// - Required fields
  /// - Email format (@ symbol)
  /// - Password length (minimum 6 characters)
  Widget _buildModalField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (!isPassword && !value.contains('@')) return 'Enter a valid email';
        if (isPassword && value.length < 6) return 'Password too short';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A2E3D)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00E5FF)),
        ),
      ),
    );
  }
}
