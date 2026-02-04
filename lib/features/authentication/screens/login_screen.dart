import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/features/authentication/controllers/cubit/auth_state.dart';
import 'package:flutter_herodex3000/presentation/widgets/responsive_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await context.read<AuthCubit>().signIn(email, password);
      // On success, AuthCubit should emit authenticated and router will redirect.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in failed: ${e.code} - ${e.message}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // show error to user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in faile: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
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
              constraints: BoxConstraints(minHeight: height - MediaQuery.of(context).padding.vertical),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    
                    mainAxisAlignment: .center,
                    children: [
                      Image(
                        image: const AssetImage("assets/icons/app_icon.png"),
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 16),
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
                      _buildTerminalField("EMAIL ADDRESS", _emailController, false),
                      const SizedBox(height: 16),
                      _buildTerminalField("PASSWORD", _passwordController, true),
                      const SizedBox(height: 32),
                      _buildPrimaryButton("ACCESS TERMINAL", _handleSignIn),
                      const SizedBox(height: 12),
                      _buildSecondaryButton("SIGN UP NEW AGENT", _showEnlistModal),
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

  Widget _buildTerminalField(
    String label,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
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

// Enlist New Agent modal — keeps the original visual style but wires sign up logic.
// Converted to StatefulWidget so controllers are disposed and async signUp can be handled.
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

  void _showStatusSnackbar(BuildContext context, bool success, String message) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.greenAccent : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

// DO NOT pop synchronously here — defer to next frame to avoid navigator locked errors
    // if (success) {
    //   WidgetsBinding.instance.addPostFrameCallback((_){
    //     if(!mounted) return;
    //     if(Navigator.of(context).canPop()){
    //       Navigator.of(context).pop();
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKeySignUp.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().signUp(email, password);
      if (!mounted) return;
      _showStatusSnackbar(
        context,
        true,
        "AGENT ENROLLED SUCCESSFULLY. WELCOME.",
      );
    } on FirebaseAuthException catch (e) { // TODO sync all snackbars to look and work the same
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: ${e.code} - ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      _showStatusSnackbar(context, false, "ENLISTMENT FAILED: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state){
        if(state is AuthAuthenticated){
          WidgetsBinding.instance.addPostFrameCallback((_){
            if(!mounted) return;
            try{
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            } catch (_){
// swallow navigation errors to avoid crashes during simultaneous navigations
            }
          });
        }
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
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
                ElevatedButton(
                  onPressed: _loading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF).withAlpha(20),
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFF00E5FF)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "SIGN UP",
                          style: TextStyle(color: Color(0xFF00E5FF)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
