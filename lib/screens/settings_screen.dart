import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_herodex3000/auth/cubit/auth_cubit.dart';
import 'package:flutter_herodex3000/widgets/custom_card.dart';
import 'package:go_router/go_router.dart';

// TODO Some error with ParatDataWidget, some Expanded thats at fault?
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SETTINGS", style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildSectionHeader("APP ALIGNMENT"),
            _buildThemeToggle(),
            SizedBox(height: 24),
            _buildSectionHeader("DATA PROTOCOLS"), // TODO analytics agreement
            _buildProtocolTile(
              Icons.analytics,
              "Analytics Tracking",
              "STATUS: OPERATIONAL",
              true,
            ),
            _buildProtocolTile(
              Icons.location_on,
              "Global Positioning",
              "STATUS: AUTHORIZED",
              true,
            ),
            _buildSectionHeader("SYSTEM MANIFEST"),
            _buildSystemManifest(),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      title,
      style: TextStyle(
        color: Color(0xFF00E5FF),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
  );
}

Widget _buildThemeToggle() {
  return Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Color(0xFF121F2B),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF1A2E3D)),
    ),
    child: Row(
      spacing: 33,
      children: [
        Expanded(child: _buildToggleButton("HERO (LIGHT)", false)),
        Expanded(child: _buildToggleButton("VILLAIN (DARK)", true)),
      ],
    ),
  );
}

Widget _buildToggleButton(String label, bool isSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFF00E5FF).withAlpha(20) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: isSelected ? Border.all(color: const Color(0xFF00E5FF).withAlpha(40)) : null,
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E5FF) : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    ),
  );
}

Widget _buildProtocolTile(
  IconData icon,
  String title,
  String subtitle,
  bool value,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Color(0xFF121F2B),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFF1A2E3D)),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0A111A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF00E5FF)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (val) {},
          activeThumbColor: Colors.white,
          activeTrackColor: Color(0xFF00E5FF),
        ),
      ],
    ),
  );
}

Widget _buildSystemManifest() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF121F2B),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1A2E3D)),
    ),
    child: Column(
      children: [
        _buildManifestRow("APPLICATION", "HERODEX 3000"),
        const Divider(color: Color(0xFF1A2E3D), height: 24),
        _buildManifestRow("VERSION", "v3.0.1-STABLE"), // TODO change version dynamically
        const Divider(color: Color(0xFF1A2E3D), height: 24),
        _buildManifestRow("CREATOR", "SPIRITUALMADDIE"), // TODO link to github?
        const Divider(color: Color(0xFF1A2E3D), height: 24),
        _buildManifestRow("YEAR", "2025 / 2026"),
      ],
    ),
  );
}

Widget _buildManifestRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
    ],
  );
}

Widget _buildLogoutButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
    child: OutlinedButton(
      onPressed: () {
        context.read<AuthCubit>().signOut();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Colors.redAccent, width: 1, style: BorderStyle.solid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent.withAlpha(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.redAccent, size: 20),
          SizedBox(width: 12),
          Text(
            "LOGOUT",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ],
      ),
    ),
  );
}