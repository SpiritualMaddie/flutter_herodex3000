import 'dart:ui';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: const AssetImage('assets/icons/app_icon.png'), // Valfritt
        //     opacity: 0.1,
        //     repeat: ImageRepeat.noRepeat,
        //   ),
        // ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("assets/icons/app_icon.png"),
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
                _buildTerminalField("ACCESS CODE", _passwordController, true),
                const SizedBox(height: 32),
                _buildPrimaryButton("ACCESS TERMINAL", () {
                  // Login logik här
                }),
                const SizedBox(height: 12),
                _buildSecondaryButton("ENLIST NEW AGENT", _showEnlistModal),
              ],
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
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
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

// 2. Enlist New Agent (Modal med Blur & Snackbar) Denna widget visas som en popup och hanterar bekräftelse via Snackbars.

class EnlistAgentModal extends StatelessWidget {
  const EnlistAgentModal({super.key});

  void _showStatusSnackbar(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.greenAccent : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Text(
          success
              ? "AGENT ENROLLED SUCCESSFULLY. WELCOME."
              : "ENLISTMENT FAILED: CODE MATCH ERROR",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
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
              _buildModalField("AGENT CODENAME"),
              const SizedBox(height: 12),
              _buildModalField("EMAIL ADDRESS"),
              const SizedBox(height: 12),
              _buildModalField("ACCESS CODE", isPassword: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _showStatusSnackbar(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF).withAlpha(20),
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                ),
                child: const Text(
                  "COMMENCE ENLISTMENT",
                  style: TextStyle(color: Color(0xFF00E5FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalField(String label, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
