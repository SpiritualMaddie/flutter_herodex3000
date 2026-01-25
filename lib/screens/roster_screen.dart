import 'package:flutter/material.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});
  @override
  State<RosterScreen> createState() => _RosterScreen();
}

class _RosterScreen extends State<RosterScreen> {
  // Simulera sparade karaktärer
  final List<Map<String, dynamic>> _savedAgents = [
    {"name": "MAGNETO", "power": 0.95, "speed": 0.60, "type": "VILLAIN"},
    {"name": "WOLVERINE", "power": 0.88, "speed": 0.75, "type": "HERO"},
    {"name": "STORM", "power": 0.92, "speed": 0.70, "type": "HERO"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "AGENTS ROSTER",
          style: TextStyle(letterSpacing: 2, fontSize: 18, color: Colors.cyan),
        ),
      ),
body: _savedAgents.isEmpty
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/icons/app_icon.png",
                width: 120,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "NO AGENTS IN ROSTER",
              style: TextStyle(
                color: Colors.cyan,
                letterSpacing: 2,
                fontSize: 17,
              ),
            ),
            const Text(
              "GO TO SCAN TO FIND NEW ALLIES",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
    : ListView.builder( // TODO add details view on click check code in search_screen --> // VY 3: RESULTAT-LÄGE
        padding: const EdgeInsets.all(16),
        scrollDirection: .vertical,
        itemCount: _savedAgents.length,
        itemBuilder: (context, index) {
          final agent = _savedAgents[index];
          return GestureDetector(onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgentDetailViewRoster(name: agent['name']),
            ),
          ),
          child: _buildDismissibleTile(agent, index),
          );
        },
      ),

    );
  }

  Widget _buildDismissibleTile(Map<String, dynamic> agent, int index) {
    return Dismissible(
      key: Key(agent['name']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() => _savedAgents.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${agent['name']} REMOVED FROM ROSTER")),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
      ),
      child: _buildCharacterListTile(agent),
    );
  }

  Widget _buildCharacterListTile(Map<String, dynamic> agent) {
    bool isHero = agent['type'] == "HERO";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHero
              ? Colors.cyan.withAlpha(20)
              : Colors.redAccent.withAlpha(20),
        ),
      ),
      child: Row(
        children: [
          // Mindre Avatar-bild (som i sök)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0A111A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: isHero ? Colors.cyan : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 16),
          // Info & Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      agent['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      agent['type'],
                      style: TextStyle(
                        color: isHero ? Colors.cyan : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Kompakta Stats-bars
                _buildMiniStatBar(
                  "PWR",
                  agent['power'],
                  isHero ? Colors.cyan : Colors.redAccent,
                ),
                const SizedBox(height: 4),
                _buildMiniStatBar("SPD", agent['speed'], Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 8),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.black26,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}


// Detalj-vy (Agent Intelligence Report)
// TODO villians need red stats
class AgentDetailViewRoster extends StatelessWidget {
  final String name;
  const AgentDetailViewRoster({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.cyan.withAlpha(30), Colors.transparent],
                  ),
                ),
                child: const Icon(Icons.shield, size: 120, color: Colors.cyan),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AGENT CODENAME",
                    style: TextStyle(color: Colors.cyan[200], fontSize: 12),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatRow("STRENGTH", 0.85),
                  _buildStatRow("INTELLIGENCE", 0.92),
                  _buildStatRow("SPEED", 0.65),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      "SAVE TO ROSTER",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildStatRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFF1A2E3D),
            color: Colors.cyan,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}