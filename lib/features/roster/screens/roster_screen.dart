// features/roster/screens/roster_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/managers/agent_cache.dart';
import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';
import 'package:flutter_herodex3000/features/agent_details/screens/agent_details_screen.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';

// Which alignments are currently visible.
enum AgentAlignment { good, bad, neutral }

// How the list is sorted by power.
enum PowerSort { none, highest, lowest }

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final SavedAgentsRepository _savedAgentsRepo = SavedAgentsRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  // All agents fetched from Firestore — never mutated by filters.
  List<AgentModel> _allAgents = [];

  // Which alignment checkboxes are active. Start with all selected.
   Set<AgentAlignment> _selectedAlignments = {AgentAlignment.good, AgentAlignment.bad, AgentAlignment.neutral};

 // Current power sort mode.
  PowerSort _powerSort = PowerSort.none;

 // The current search query (lowercased).
 String _searchQuery = "";

  // ViewModel summaries for the cards. // TODO save the local list in a DataManager and focus on SOC
 // List<AgentSummary> _summaries = [];

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAgents();
    _searchController.addListener((){
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase(),);
    });
  }

  /// Derives the visible list by applying search, alignment filter, then sort.
  /// This runs on every build — it's cheap since roster lists are small.
  List<AgentModel> get _filteredAgents {
    var list = _allAgents.toList();

    // 1. Search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((a) => a.name.toLowerCase().contains(_searchQuery)).toList();
    }

    // 2. AgentAlignment filter
    list = list.where((a) {
      final alignment = a.biography.alignment.trim().toLowerCase();
      if (alignment == 'good') return _selectedAlignments.contains(AgentAlignment.good);
      if (alignment == 'bad') return _selectedAlignments.contains(AgentAlignment.bad);
      // Anything else (neutral, empty, unknown) maps to neutral
      return _selectedAlignments.contains(AgentAlignment.neutral);
    }).toList();

    // 3. Power sort
    switch (_powerSort) {
      case PowerSort.highest:
        list.sort((a, b) => b.powerstats.power.compareTo(a.powerstats.power));
      case PowerSort.lowest:
        list.sort((a, b) => a.powerstats.power.compareTo(b.powerstats.power));
      case PowerSort.none:
        break;
    }

    return list;
  }

  // Loads all saved agents from Firestore.
  Future<void> _loadAgents() async {
    try {
      final agents = await _savedAgentsRepo.getAllSavedAgents();

      if (!mounted) return;

      setState(() {
        _allAgents = agents;
        //_summaries = AgentSummaryMapper.toSummaryList(agents);
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ RosterScreen._loadAgents: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Removes an agent from Firestore.
  Future<void> _removeAgent(AgentModel agent) async {

    // Remove from UI immediately
    setState(() {
      _allAgents.removeWhere((a) => a.agentId == agent.agentId);
      //_summaries.removeWhere((a) => a.id == agent.agentId);
    });

    try {
      await _savedAgentsRepo.removeAgent(agent.agentId);
    } catch (e, st) {
      debugPrint('❌ RosterScreen._removeAgent: $e\n$st');
      // If Firestore fails, put it back
      if (!mounted) return;
      setState(() {
        _allAgents.add(agent);
        //_summaries.add(AgentSummaryMapper.toSummary(agent));
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
      body: Column(
        children: [
          // --- TOP SECTION: title + search + filters ---
          _buildTopBar(),
          // --- AGENT LIST or states ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.cyan),
                  )
                : _filteredAgents.isEmpty
                    ? _buildEmptyState()
                    : _buildRosterList(),
          ),
        ],
      ),
    );
  }

  // --- TOP BAR ---
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF0A111A),
      padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            "AGENTS ROSTER",
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 18,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF121F2B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyan.withAlpha(40)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyan.withAlpha(100)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyan.withAlpha(40)),
                ),
                hintText: "Search roster...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.cyan, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // AgentAlignment filter — multi-select
          SegmentedButton<AgentAlignment>(
            segments: const [
              ButtonSegment(
                value: AgentAlignment.good,
                label: Text("GOOD", style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.shield, size: 14),
              ),
              ButtonSegment(
                value: AgentAlignment.bad,
                label: Text("BAD", style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.warning_amber, size: 14),
              ),
              ButtonSegment(
                value: AgentAlignment.neutral,
                label: Text("NEUTRAL", style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.remove_circle_outline, size: 14),
              ),
            ],
            selected: _selectedAlignments,
            onSelectionChanged: (newSelection) {
              // Don't allow deselecting everything
              if (newSelection.isEmpty) return;
              setState(() => _selectedAlignments = newSelection);
            },
            multiSelectionEnabled: true,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.cyan.withAlpha(30);
                }
                return const Color(0xFF121F2B);
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.cyan;
                }
                return Colors.grey;
              }),
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.cyan.withAlpha(40)),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Power sort — single select
          SegmentedButton<PowerSort>(
            segments: const [
              ButtonSegment(
                value: PowerSort.none,
                label: Text("DEFAULT", style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: PowerSort.highest,
                label: Text("HIGHEST", style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.arrow_upward, size: 14),
              ),
              ButtonSegment(
                value: PowerSort.lowest,
                label: Text("LOWEST", style: TextStyle(fontSize: 11)),
                icon: Icon(Icons.arrow_downward, size: 14),
              ),
            ],
            selected: {_powerSort},
            onSelectionChanged: (newSelection) {
              setState(() => _powerSort = newSelection.first);
            },
            multiSelectionEnabled: false,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.cyan.withAlpha(30);
                }
                return const Color(0xFF121F2B);
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.cyan;
                }
                return Colors.grey;
              }),
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.cyan.withAlpha(40)),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFF0A111A),
  //     appBar: AppBar(
  //       backgroundColor: Colors.transparent,
  //       title: const Text(
  //         "AGENTS ROSTER",
  //         style: TextStyle(letterSpacing: 2, fontSize: 18, color: Colors.cyan),
  //       ),
  //     ),
  //     body: _isLoading
  //         ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
  //         : _summaries.isEmpty
  //             ? _buildEmptyState()
  //             : _buildRosterList(),
  //   );
  // }

  // // VY 1: TOM ROSTER
  // Widget _buildEmptyState() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Opacity(
  //           opacity: 0.5,
  //           child: Image.asset(
  //             "assets/icons/app_icon.png",
  //             width: 120,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           "NO AGENTS IN ROSTER",
  //           style: TextStyle(
  //             color: Colors.cyan,
  //             letterSpacing: 2,
  //             fontSize: 17,
  //           ),
  //         ),
  //         const Text(
  //           "GO TO SEARCH TO FIND NEW ALLIES",
  //           style: TextStyle(
  //             color: Colors.grey,
  //             letterSpacing: 1,
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

    // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    // Different message depending on whether it's empty roster or empty filter result
    final hasAgentsButFiltered = _allAgents.isNotEmpty && _filteredAgents.isEmpty;

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
          Text(
            hasAgentsButFiltered ? "NO MATCHING AGENTS" : "NO AGENTS IN ROSTER",
            style: const TextStyle(
              color: Colors.cyan,
              letterSpacing: 2,
              fontSize: 17,
            ),
          ),
          Text(
            hasAgentsButFiltered
                ? "TRY ADJUSTING YOUR FILTERS"
                : "GO TO SEARCH TO FIND NEW ALLIES",
            style: const TextStyle(
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

//   // VY 2: ROSTER LIST — uses shared AgentCard
//   Widget _buildRosterList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _summaries.length,
//       itemBuilder: (context, index) {
//         final summary = _summaries[index];
//         return AgentCard(
//           agent: summary,
//           layout: AgentCardLayout.list,
//           onTap: () {
//             // Cache the full model, then navigate
//             AgentCache.put(_allAgents[index]);
//             Navigator.push(
//               context, 
//             MaterialPageRoute(
//               builder: (context) => 
//                AgentDetailsScreen(agent: _allAgents[index], showSaveButton: false,)));
//             //context.go('/details/${summary.id}');
//           },
//           onDismiss: () {
//             final name = summary.name;
//             _removeAgent(index);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("$name REMOVED FROM ROSTER")),
//             );
//           },
//         );
//       },
//     );
//   }
// }

  // --- ROSTER LIST ---
  Widget _buildRosterList() {
    final visible = _filteredAgents;
    final summaries = AgentSummaryMapper.toSummaryList(visible);

    return RefreshIndicator(
      color: Colors.cyan,
      backgroundColor: const Color(0xFF121F2B),
      onRefresh: _loadAgents,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: summaries.length,
        itemBuilder: (context, index) {
          final summary = summaries[index];
          return AgentCard(
            agent: summary,
            layout: AgentCardLayout.list,
            onTap: () {
              //Cache the full model, then navigate
              AgentCache.put(_allAgents[index]);
              Navigator.push(
                context, 
              MaterialPageRoute(
                builder: (context) => 
                 AgentDetailsScreen(agent: _allAgents[index], showSaveButton: false,))
              );
            },
            onDismiss: () {
              _removeAgent(visible[index]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${visible[index].name} REMOVED FROM ROSTER")),
              );
            },
          );
        },
      ),
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
//         alignment: AgentAlignment.centerRight,
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


