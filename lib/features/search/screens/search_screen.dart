// features/search/screens/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';
import 'package:flutter_herodex3000/data/managers/agent_cache.dart';
import 'package:flutter_herodex3000/data/managers/agent_data_manager.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';

// TODO cant do another search quick after first search now, worked before

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AgentDataManager _dataManager = AgentDataManager();
  Timer? _debounce;
  bool _isLoading = false;

  /// The full models, kept so we can cache them on tap.
  List<AgentModel> _fullAgents = [];

  /// The lightweight summaries that the cards actually display.
  List<AgentSummary> _summaries = [];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _fullAgents = [];
        _summaries = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 900), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final agents = await _dataManager.getAgentByNameApi(query);

      if (!mounted) return;

      setState(() {
        _fullAgents = agents;
        _summaries = AgentSummaryMapper.toSummaryList(agents);
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ SearchScreen._performSearch: $e\n$st');
      if (!mounted) return;
      setState(() {
        _fullAgents = [];
        _summaries = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "SEARCH FOR FELLOW AGENTS...",
            hintStyle: TextStyle(color: Colors.cyan, fontSize: 12),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.cyan),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _summaries.isEmpty
              ? _buildInitialState()
              : _buildResultsState(),
    );
  }

  // VY 1: INITIALT LÄGE
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 150, color: Colors.cyan.withAlpha(20)),
          const SizedBox(height: 16),
          const Text(
            "AWAITING INPUT",
            style: TextStyle(color: Colors.cyan, letterSpacing: 2, fontSize: 17),
          ),
          const Text(
            "READY TO SEARCH",
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

  // VY 2: LADDNINGS-LÄGE (SHIMMER)
  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFF121F2B),
        highlightColor: const Color(0xFF1A2E3D),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // VY 3: RESULTAT-LÄGE — uses shared AgentCard
   Widget _buildResultsState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        return AgentCard(
          agent: summary,
          layout: AgentCardLayout.grid,
          onTap: () {
             // Cache the full model, then navigate
            AgentCache.put(_fullAgents[index]);
            Navigator.push(
              context, 
            MaterialPageRoute(
              builder: (context) => AgentDetailsScreen(agent: _fullAgents[index], showSaveButton: true,)));
            //context.go('/details/${summary.id}');
          },
        );
      },
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   bool _isLoading = false;
//   List<String> _results = []; // Simulera data // DEBOUNCE LOGIK
//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     if (query.isEmpty) {
//       setState(() {
//         _results = [];
//         _isLoading = false;
//       });
//       return;
//     }
//     setState(() => _isLoading = true);
//     _debounce = Timer(const Duration(milliseconds: 600), () {
//       _performSearch(query);
//     });
//   }

//   // SIMULERA API ANROP
//   Future<void> _performSearch(String query) async {
//     await Future.delayed(
//       const Duration(seconds: 2),
//     ); // Simulera nätverksfördröjning

//     setState(() {
//       _results = List.generate(
//         6,
//         (index) => "Agent ${query.toUpperCase()} $index",
//       );
//       _isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: TextField(
//           controller: _searchController,
//           onChanged: _onSearchChanged,
//           style: const TextStyle(color: Colors.white),
//           decoration: const InputDecoration(
//             hintText: "SEARCH FOR FELLOW AGENTS...",
//             hintStyle: TextStyle(color: Colors.cyan, fontSize: 12),
//             border: InputBorder.none,
//             prefixIcon: Icon(Icons.search, color: Colors.cyan,),
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? _buildLoadingState()
//           : _results.isEmpty
//           ? _buildInitialState()
//           : _buildResultsState(),
//     );
//   }

//   // VY 1: INITIALT LÄGE
//   Widget _buildInitialState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.radar, size: 150, color: Colors.cyan.withAlpha(20)),
//           const SizedBox(height: 16),
//           const Text(
//             "AWAITING INPUT",
//             style: TextStyle(color: Colors.cyan, letterSpacing: 2, fontSize: 17),
//           ),
//           const Text(
//             "READY TO SEARCH",
//             style: TextStyle(color: Colors.grey, letterSpacing: 1, fontSize: 12, fontWeight: .bold),
//           ),
//         ],
//       ),
//     );
//   }

//   // VY 2: LADDNINGS-LÄGE (SHIMMER)
//   Widget _buildLoadingState() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: 6,
//       itemBuilder: (context, index) => Shimmer.fromColors(
//         baseColor: const Color(0xFF121F2B),
//         highlightColor: const Color(0xFF1A2E3D),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   // VY 3: RESULTAT-LÄGE
//   Widget _buildResultsState() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: _results.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AgentDetailView(name: _results[index]),
//             ),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFF121F2B),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.cyan.withAlpha(24)),
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     _results[index],
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// //3. Detalj-vy (Agent Intelligence Report)
// class AgentDetailView extends StatelessWidget {
//   final String name;
//   const AgentDetailView({super.key, required this.name});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             backgroundColor: Colors.transparent,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
//               onPressed: () => Navigator.pop(context),
//             ),
//             expandedHeight: 300,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.cyan.withAlpha(30), Colors.transparent],
//                   ),
//                 ),
//                 child: const Icon(Icons.shield, size: 120, color: Colors.cyan),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "AGENT CODENAME",
//                     style: TextStyle(color: Colors.cyan[200], fontSize: 12),
//                   ),
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   _buildStatRow("STRENGTH", 0.85),
//                   _buildStatRow("INTELLIGENCE", 0.92),
//                   _buildStatRow("SPEED", 0.65),
//                   const SizedBox(height: 48),
//                   ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.cyan,
//                       minimumSize: const Size(double.infinity, 56),
//                     ),
//                     child: const Text(
//                       "SAVE TO ROSTER",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatRow(String label, double value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: value,
//             backgroundColor: const Color(0xFF1A2E3D),
//             color: Colors.cyan,
//             minHeight: 8,
//           ),
//         ],
//       ),
//     );
//   }
// }
