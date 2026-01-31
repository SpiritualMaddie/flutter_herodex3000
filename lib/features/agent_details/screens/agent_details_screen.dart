// features/agent_details/screens/agent_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/data/models/agent_model.dart';
import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';

/// Full detail view for an agent.
/// Receives the complete [AgentModel] so it can display all stats.
class AgentDetailsScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentDetailsScreen({super.key, required this.agent});

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  final SavedAgentsRepository _savedAgentsRepo = SavedAgentsRepository();
  bool _isSaved = false;
  bool _isSaving = false;

  bool get _isHero =>
      widget.agent.biography.alignment.trim().toLowerCase() == 'good';
  Color get _accentColor => _isHero ? Colors.cyan : Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  /// Checks Firestore to see if this agent is already in the roster.
  Future<void> _checkIfSaved() async {
    try {
      final saved = await _savedAgentsRepo.isAgentSaved(widget.agent.agentId);
      if (!mounted) return;
      setState(() => _isSaved = saved);
    } catch (e, st) {
      debugPrint('❌ AgentDetailsScreen._checkIfSaved: $e\n$st');
    }
  }

  /// Saves the agent to Firestore.
  Future<void> _saveAgent() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await _savedAgentsRepo.saveAgent(widget.agent);
      if (!mounted) return;
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.agent.name} SAVED TO ROSTER")),
        );
      }
    } catch (e, st) {
      debugPrint('❌ AgentDetailsScreen._saveAgent: $e\n$st');
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAllStats(),
                  const SizedBox(height: 24),
                  _buildBiography(),
                  const SizedBox(height: 48),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIVER APP BAR with image or placeholder ---
  Widget _buildSliverAppBar() {
    final imageUrl = widget.agent.image?.url;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
        onPressed: () {if (!mounted) return;}, // Navigator.pop(context), // TODO cant pop
      ),
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_accentColor.withAlpha(30), Colors.transparent],
            ),
          ),
          child: Center(
            child: hasImage
                ? Image.network(
                    imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.shield, size: 120, color: _accentColor),
                  )
                : Icon(Icons.shield, size: 120, color: _accentColor),
          ),
        ),
      ),
    );
  }

  // --- NAME + ALIGNMENT BADGE ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "AGENT CODENAME",
              style:
                  TextStyle(color: _accentColor.withAlpha(180), fontSize: 12),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentColor.withAlpha(80)),
              ),
              child: Text(
                widget.agent.biography.alignment.toUpperCase(),
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.agent.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- ALL POWERSTATS ---
  Widget _buildAllStats() {
    final stats = widget.agent.powerstats;
    return Column(
      children: [
        _buildStatRow("INTELLIGENCE", stats.intelligence),
        _buildStatRow("STRENGTH", stats.strength),
        _buildStatRow("SPEED", stats.speed),
        _buildStatRow("DURABILITY", stats.durability),
        _buildStatRow("POWER", stats.power),
        _buildStatRow("COMBAT", stats.combat),
      ],
    );
  }

  /// Single stat row. [value] is 0–100 from the API.
  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Text(
                '${value.clamp(0, 100)}',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0, 100) / 100.0,
              backgroundColor: const Color(0xFF1A2E3D),
              color: _accentColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

// TODO build the other sections too like connections and work

  // --- BIOGRAPHY SECTION ---
  Widget _buildBiography() {
    final bio = widget.agent.biography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "INTEL",
          style: TextStyle(color: _accentColor, fontSize: 12, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        _buildInfoRow("Place of Birth", bio.placeOfBirth),
        _buildInfoRow("First Appearance", bio.firstAppearance),
        _buildInfoRow("Publisher", bio.publisher),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- SAVE BUTTON — changes based on whether already saved ---
  Widget _buildSaveButton() {
    if (_isSaved) {
      return ElevatedButton(
        onPressed: null, // Disabled
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          disabledBackgroundColor: Colors.grey[700],
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text(
          "ALREADY IN ROSTER ✓",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isSaving ? null : _saveAgent,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        minimumSize: const Size(double.infinity, 56),
      ),
      child: _isSaving
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            )
          : Text(
              "SAVE TO ROSTER",
              style: TextStyle(
                color: _accentColor == Colors.cyan ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_herodex3000/barrel_files/models.dart';

// // Detalj-vy (Agent Intelligence Report)
// // TODO villians need red stats
// // TODO all details
// class AgentDetailsScreen extends StatelessWidget {
//   final AgentModel agent;
//   const AgentDetailsScreen({super.key, required this.agent});
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
//                     agent.name, // TODO name from id
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

//     Widget _buildStatRow(String label, double value) {
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
