import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Column(
        spacing: 16,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildSingleStatCard("HEROES", "1,240", Colors.cyan),
                const SizedBox(width: 12, height: 8),
                _buildSingleStatCard("VILLAINS", "890", Colors.red),
                const SizedBox(width: 12, height: 8),
                _buildSingleStatCard("POWER", "15,4M", Colors.cyan),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: _buildCardWithTitleAndText(
                "Invationen",
                "Hittils har invationen påverkat....",
                Colors.black,
                const Color.fromARGB(255, 19, 104, 116),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: _buildCardWithTitleAndText(
                "Framsteg",
                "Det som har hänt är: ......",
                Colors.black,
                const Color.fromARGB(255, 19, 104, 116),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSingleStatCard(String label, String value, Color accentColor) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: .bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: .w900,
              color: accentColor,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCardWithTitleAndText(
  String label,
  String text,
  Color textColor,
  Color labelColor,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 21,
              fontWeight: .bold,
              color: labelColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: .w500, color: textColor),
          ),
        ],
      ),
    ),
  );
}
