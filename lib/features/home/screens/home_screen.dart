
import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';
import 'package:flutter_herodex3000/presentation/widgets/section_header.dart';
import 'package:flutter_herodex3000/presentation/widgets/info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SavedAgentsRepository _repo = SavedAgentsRepository();

  bool _isLoading = true;
  int _heroCount = 0;
  int _villainCount = 0;
  int _totalStrength = 0;
  int _totalPower = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final agents = await _repo.getAllSavedAgents();
      if (!mounted) return;

      setState(() {
        _heroCount = agents
            .where((a) => a.biography.alignment.trim().toLowerCase() == 'good')
            .length;
        _villainCount = agents
            .where((a) => a.biography.alignment.trim().toLowerCase() == 'bad')
            .length;
        _totalStrength =
            agents.fold(0, (sum, a) => sum + a.powerstats.strength);
        _totalPower = agents.fold(0, (sum, a) => sum + a.powerstats.power);
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ HomeScreen._loadStats: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 56, bottom: 24, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const SectionHeader( // TODO maybe icon?
              title: "HUB",
              titleFontSize: 22,
              padding: EdgeInsets.only(bottom: 20),
            ),

            // Top row: hero count, villain count
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: "HEROES",
                    value: _isLoading ? "—" : _heroCount.toString(),
                    icon: Icons.shield,
                    accentColor: Colors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: "VILLAINS",
                    value: _isLoading ? "—" : _villainCount.toString(),
                    icon: Icons.warning_amber,
                    accentColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fighting power card
            _FightingPowerCard(
              isLoading: _isLoading,
              totalStrength: _totalStrength,
              totalPower: _totalPower,
            ),

            // War section
            const SectionHeader(title: "THE INVASION"),
            InfoCard(
              icon: Icons.public,
              title: "SITUATION REPORT",
              body: "The invasion continues to spread across the globe. "
                  "Communications are being restored sector by sector. "
                  "The resistance holds firm, but the enemy adapts quickly. "
                  "Every agent we deploy tips the balance further in our favor.",
            ),
            InfoCard(
              icon: Icons.timeline,
              title: "RECENT DEVELOPMENTS",
              body: "Infrastructure in major cities is coming back online. "
                  "Agent recruitment efforts have intensified. "
                  "Intelligence reports suggest the enemy's central command "
                  "may be vulnerable if we can assemble enough firepower. "
                  "Every hero and villain in your roster brings us closer to victory.",
            ),
            InfoCard(
              icon: Icons.trending_up,
              title: "YOUR CONTRIBUTION",
              body: _isLoading
                  ? "Loading your roster data..."
                  : _heroCount + _villainCount == 0
                      ? "Your roster is empty. Head to SEARCH and start recruiting agents to help fight the invasion."
                      : "Your roster contributes ${_heroCount + _villainCount} agent${(_heroCount + _villainCount) > 1 ? 's' : ''} "
                          "with a combined fighting power of ${_totalStrength + _totalPower}. "
                          "Keep recruiting to strengthen the resistance.",
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card (hero/villain count)
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withAlpha(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: accentColor, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: .bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fighting power card
// ---------------------------------------------------------------------------
class _FightingPowerCard extends StatelessWidget {
  final bool isLoading;
  final int totalStrength;
  final int totalPower;

  const _FightingPowerCard({
    required this.isLoading,
    required this.totalStrength,
    required this.totalPower,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FIGHTING POWER",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "COMBINED",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big total
          Text(
            isLoading ? "—" : (totalStrength + totalPower).toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),

          // Breakdown bar
          Row(
            children: [
              Expanded(
                flex: isLoading ? 1 : (totalStrength + 1),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      bottomLeft: Radius.circular(3),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: isLoading ? 1 : (totalPower + 1),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(120),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SubStat("STRENGTH", totalStrength, Theme.of(context).colorScheme.primary, isLoading),
              _SubStat("POWER", totalPower, Theme.of(context).colorScheme.primary.withAlpha(180), isLoading),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isLoading;

  const _SubStat(this.label, this.value, this.color, this.isLoading);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 0.9, fontWeight: .bold)),
        const SizedBox(width: 8),
        Text(
          isLoading ? "—" : value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: .bold,
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final SavedAgentsRepository _repo = SavedAgentsRepository();

//   bool _isLoading = true;
//   int _heroCount = 0;
//   int _villainCount = 0;
//   int _totalStrength = 0;
//   int _totalPower = 0;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadStats();
//   }

//   /// Single fetch, all stats derived from it.
//   Future<void> _loadStats() async {
//     try {
//       final agents = await _repo.getAllSavedAgents();
//       if (!mounted) return;

//       setState(() {
//         _heroCount = agents.where((a) => a.biography.alignment.trim().toLowerCase() == 'good').length;
//         _villainCount = agents.where((a) => a.biography.alignment.trim().toLowerCase() == 'bad').length;
//         _totalStrength = agents.fold(0, (sum, a) => sum + a.powerstats.strength);
//         _totalPower = agents.fold(0, (sum, a) => sum + a.powerstats.power);
//         _isLoading = false;
//       });
//     } catch (e, st) {
//       debugPrint('❌ HomeScreen._loadStats: $e\n$st');
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A111A),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(top: 56, bottom: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "HUB",
//                 style: TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 18,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // --- Top row: hero count, villain count ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildCountCard(
//                       label: "HEROES",
//                       value: _heroCount,
//                       icon: Icons.shield,
//                       accentColor: Colors.cyan,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildCountCard(
//                       label: "VILLAINS",
//                       value: _villainCount,
//                       icon: Icons.warning_amber,
//                       accentColor: Colors.redAccent,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),

//             // --- Fighting power card (strength + power combined) ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: _buildFightingPowerCard(),
//             ),
//             const SizedBox(height: 24),

//             // --- War section header ---
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 "THE INVASION",
//                 style: TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 12,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // --- War narrative cards ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: _buildWarCard(
//                 title: "SITUATION REPORT",
//                 icon: Icons.public,
//                 text:
//                     "The invasion continues to spread across the globe. "
//                     "Communications are being restored sector by sector. "
//                     "The resistance holds firm, but the enemy adapts quickly. "
//                     "Every agent we deploy tips the balance further in our favor.",
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: _buildWarCard(
//                 title: "RECENT DEVELOPMENTS",
//                 icon: Icons.timeline,
//                 text:
//                     "Infrastructure in major cities is coming back online. "
//                     "Agent recruitment efforts have intensified. "
//                     "Intelligence reports suggest the enemy's central command "
//                     "may be vulnerable if we can assemble enough firepower. "
//                     "Every hero and villain in your roster brings us closer to victory.",
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: _buildWarCard(
//                 title: "YOUR CONTRIBUTION",
//                 icon: Icons.trending_up,
//                 text: _isLoading
//                     ? "Loading your roster data..."
//                     : _heroCount + _villainCount == 0
//                         ? "Your roster is empty. Head to SEARCH and start recruiting agents to help fight the invasion."
//                         : "Your roster contributes ${_heroCount + _villainCount} agent${(_heroCount + _villainCount) > 1 ? 's' : ''} "
//                           "with a combined fighting power of ${_totalStrength + _totalPower}. "
//                           "Keep recruiting to strengthen the resistance.",
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- COUNT CARD (Heroes / Villains) ---
//   Widget _buildCountCard({
//     required String label,
//     required int value,
//     required IconData icon,
//     required Color accentColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: accentColor.withAlpha(24)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: accentColor.withAlpha(20),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Icon(icon, color: accentColor, size: 22),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 10,
//                   letterSpacing: 1.2,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: Text(
//                   _isLoading ? "—" : value.toString(),
//                   key: ValueKey(value),
//                   style: TextStyle(
//                     color: accentColor,
//                     fontSize: 26,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // --- FIGHTING POWER CARD (combined strength + power) ---
//   Widget _buildFightingPowerCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.cyan.withAlpha(24)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "FIGHTING POWER",
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 10,
//                   letterSpacing: 1.2,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.cyan.withAlpha(20),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: const Text(
//                   "COMBINED",
//                   style: TextStyle(
//                     color: Colors.cyan,
//                     fontSize: 9,
//                     letterSpacing: 1,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           // Big total number
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               _isLoading ? "—" : ((_totalStrength + _totalPower)).toString(),
//               key: ValueKey(_totalStrength + _totalPower),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 36,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//           const SizedBox(height: 14),

//           // Breakdown bar
//           Row(
//             children: [
//               // Strength portion
//               Expanded(
//                 flex: _isLoading ? 1 : (_totalStrength + 1),
//                 child: Container(
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: Colors.cyan,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(3),
//                       bottomLeft: Radius.circular(3),
//                     ),
//                   ),
//                 ),
//               ),
//               // Power portion
//               Expanded(
//                 flex: _isLoading ? 1 : (_totalPower + 1),
//                 child: Container(
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: Colors.brown,
//                     borderRadius: const BorderRadius.only(
//                       topRight: Radius.circular(3),
//                       bottomRight: Radius.circular(3),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Labels under the bar
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildSubStat("STRENGTH", _totalStrength, Colors.cyan),
//               _buildSubStat("POWER", _totalPower, Colors.brown),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// Small label + value pair used in the fighting power breakdown.
//   Widget _buildSubStat(String label, int value, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey, fontSize: 10),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           _isLoading ? "—" : value.toString(),
//           style: TextStyle(
//             color: color,
//             fontSize: 10,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   // --- WAR NARRATIVE CARD ---
//   Widget _buildWarCard({
//     required String title,
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121F2B),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.cyan.withAlpha(24)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: Colors.cyan, size: 16),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//               height: 1.6,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_herodex3000/data/models/agent_model.dart';
// import 'package:flutter_herodex3000/data/repositories/saved_agents_repository.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home")),
//       body: Column(
//         spacing: 16,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildSingleStatCard("HEROES", _numerOfHeroesInRoster, Colors.cyan),
//                 ),
//                 const SizedBox(width: 12, height: 8),
//                 Expanded(
//                   child: _buildSingleStatCard("VILLAINS", _numerOfVillainsInRoster, Colors.red),
//                 ),
//                 const SizedBox(width: 12, height: 8),
//                 Expanded(
//                   child: _buildSingleStatCard("POWER", _amountOfPowerInRoster, Colors.cyan),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Card(
//               child: _buildCardWithTitleAndText(
//                 "Invationen",
//                 "Hittils har invationen påverkat....",
//                 Colors.black,
//                 const Color.fromARGB(255, 19, 104, 116),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Card(
//               child: _buildCardWithTitleAndText(
//                 "Framsteg",
//                 "Det som har hänt är: ......",
//                 Colors.black,
//                 const Color.fromARGB(255, 19, 104, 116),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Future<int> _numerOfHeroesInRoster() async {
//   final SavedAgentsRepository savedAgentsRepo = SavedAgentsRepository();
//   List<AgentModel> allAgents = await savedAgentsRepo.getAllSavedAgents();
//   return allAgents.where((h) => h.biography.alignment == "good").length;
// }

// Future<int> _numerOfVillainsInRoster() async {
//   final SavedAgentsRepository savedAgentsRepo = SavedAgentsRepository();
//   List<AgentModel> allAgents = await savedAgentsRepo.getAllSavedAgents();
//   return allAgents.where((h) => h.biography.alignment == "bad").length;
// }

// // Future<int> _amountOfPowerInRoster() async {
// //   final SavedAgentsRepository savedAgentsRepo = SavedAgentsRepository();
// //   List<AgentModel> allAgents = await savedAgentsRepo.getAllSavedAgents();
// //   allAgents.
// // }


// Widget _buildSingleStatCard(String label, int value, Color accentColor) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: .circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withAlpha(15),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: .start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: .bold,
//             color: Colors.grey[600],
//             letterSpacing: 1.2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value.toString(),
//           style: TextStyle(fontSize: 22, fontWeight: .w900, color: accentColor),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildCardWithTitleAndText(
//   String label,
//   String text,
//   Color textColor,
//   Color labelColor,
// ) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: .circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withAlpha(3),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: .start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 21,
//             fontWeight: .bold,
//             color: labelColor,
//             letterSpacing: 1.2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           text,
//           style: TextStyle(fontSize: 12, fontWeight: .w500, color: textColor),
//         ),
//       ],
//     ),
//   );
// }
