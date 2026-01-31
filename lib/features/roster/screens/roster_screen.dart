// features/roster/screens/roster_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/managers/agent_cache.dart';
import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';
import 'package:go_router/go_router.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final SavedAgentsRepository _savedAgentsRepo = SavedAgentsRepository();
  bool _isLoading = true;

  /// Full models kept so added to cache on tap.
  List<AgentModel> _fullAgents = [];

  /// ViewModel summaries for the cards.
  List<AgentSummary> _summaries = [];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  /// Loads all saved agents from Firestore.
  Future<void> _loadAgents() async {
    try {
      final agents = await _savedAgentsRepo.getAllSavedAgents();

      if (!mounted) return;

      setState(() {
        _fullAgents = agents;
        _summaries = AgentSummaryMapper.toSummaryList(agents);
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ RosterScreen._loadAgents: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// Removes an agent from Firestore.
  Future<void> _removeAgent(int index) async {
    final removed = _fullAgents[index];

    // Remove from UI immediately
    setState(() {
      _fullAgents.removeAt(index);
      _summaries.removeAt(index);
    });

    try {
      await _savedAgentsRepo.removeAgent(removed.agentId);
    } catch (e, st) {
      debugPrint('❌ RosterScreen._removeAgent: $e\n$st');
      // If Firestore fails, put it back
      if (!mounted) return;
      setState(() {
        _fullAgents.insert(index, removed);
        _summaries.insert(index, AgentSummaryMapper.toSummary(removed));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove agent. Try again.")),
        );
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : _summaries.isEmpty
              ? _buildEmptyState()
              : _buildRosterList(),
    );
  }

  // VY 1: TOM ROSTER
  Widget _buildEmptyState() {
    return Center(
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
            "GO TO SEARCH TO FIND NEW ALLIES",
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // VY 2: ROSTER LIST — uses shared AgentCard
  Widget _buildRosterList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        return AgentCard(
          agent: summary,
          layout: AgentCardLayout.list,
          onTap: () {
            // Cache the full model, then navigate
            AgentCache.put(_fullAgents[index]);
            context.go('/details/${summary.id}');
          },
          onDismiss: () {
            final name = summary.name;
            _removeAgent(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$name REMOVED FROM ROSTER")),
            );
          },
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_herodex3000/barrel_files/models.dart';
// import 'package:flutter_herodex3000/barrel_files/screens.dart';

// class RosterScreen extends StatefulWidget {
//   const RosterScreen({super.key});
//   @override
//   State<RosterScreen> createState() => _RosterScreen();
// }

// class _RosterScreen extends State<RosterScreen> {
//   // Simulera sparade karaktärer
//   // final List<Map<String, dynamic>> _savedAgents = [
//   //   {"id" : "1", "name": "MAGNETO", "power": 0.95, "speed": 0.60, "type": "VILLAIN"},
//   //   {"id" : "2", "name": "WOLVERINE", "power": 0.88, "speed": 0.75, "type": "HERO"},
//   //   {"id" : "3", "name": "STORM", "power": 0.92, "speed": 0.70, "type": "HERO"},
//   // ];

//   final List<AgentModel> _savedAgents = [
//     AgentModel(name: "MAGNETO", powerstats: PowerstatsModel(intelligence: 50, strength: 80, speed: 60, durability: 40, power: 46, combat: combat), biography: biography, appearance: appearance)
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: const Text(
//           "AGENTS ROSTER",
//           style: TextStyle(letterSpacing: 2, fontSize: 18, color: Colors.cyan),
//         ),
//       ),
// body: _savedAgents.isEmpty
//     ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Opacity(
//               opacity: 0.5,
//               child: Image.asset(
//                 "assets/icons/app_icon.png",
//                 width: 120,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "NO AGENTS IN ROSTER",
//               style: TextStyle(
//                 color: Colors.cyan,
//                 letterSpacing: 2,
//                 fontSize: 17,
//               ),
//             ),
//             const Text(
//               "GO TO SCAN TO FIND NEW ALLIES",
//               style: TextStyle(
//                 color: Colors.grey,
//                 letterSpacing: 1,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       )
//     : ListView.builder( // TODO add details view on click check code in search_screen --> // VY 3: RESULTAT-LÄGE
//         padding: const EdgeInsets.all(16),
//         scrollDirection: .vertical,
//         itemCount: _savedAgents.length,
//         itemBuilder: (context, index) {
//           final agent = _savedAgents[index];
//           return GestureDetector(onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AgentDetailsScreen(agent),
//             ),
//           ),
//           child: _buildDismissibleTile(agent, index),
//           );
//         },
//       ),

//     );
//   }

//   Widget _buildDismissibleTile(Map<String, dynamic> agent, int index) {
//     return Dismissible(
//       key: Key(agent['name']),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         setState(() => _savedAgents.removeAt(index));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("${agent['name']} REMOVED FROM ROSTER")),
//         );
//       },
//       background: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.redAccent.withAlpha(20),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
//       ),
//       child: _buildCharacterListTile(agent),
//     );
//   }

//   Widget _buildCharacterListTile(Map<String, dynamic> agent) {
//     bool isHero = agent['type'] == "HERO";
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isHero
//               ? Colors.cyan.withAlpha(20)
//               : Colors.redAccent.withAlpha(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Mindre Avatar-bild (som i sök)
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFF0A111A),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               Icons.person,
//               color: isHero ? Colors.cyan : Colors.redAccent,
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Info & Stats
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       agent['name'],
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       agent['type'],
//                       style: TextStyle(
//                         color: isHero ? Colors.cyan : Colors.redAccent,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Kompakta Stats-bars
//                 _buildMiniStatBar(
//                   "PWR",
//                   agent['power'],
//                   isHero ? Colors.cyan : Colors.redAccent,
//                 ),
//                 const SizedBox(height: 4),
//                 _buildMiniStatBar("SPD", agent['speed'], Colors.grey),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMiniStatBar(String label, double value, Color color) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 30,
//           child: Text(
//             label,
//             style: const TextStyle(color: Colors.grey, fontSize: 8),
//           ),
//         ),
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(2),
//             child: LinearProgressIndicator(
//               value: value,
//               minHeight: 3,
//               backgroundColor: Colors.black26,
//               color: color,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


