import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';

///
/// Mission Control / Dashboard screen showing roster statistics and war updates.
/// 
/// Features:
/// - Real-time statistics: hero count, villain count, total fighting power
/// - War narrative cards that adapt to user's roster composition
/// - Auto-refreshes when tab becomes active (via didChangeDependencies)
/// - Loading states with placeholder "—" characters
/// 
/// Data Flow:
/// 1. Screen loads → fetches all agents from Firestore
/// 2. Calculates stats locally (hero/villain counts, strength, power)
/// 3. Displays stats in cards + generates dynamic war narrative
/// 
/// Note: Does NOT track neutral agents yet (future improvement).
/// 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AgentDataManager _agentdatarepo = AgentDataManager();

  // Loading and stats state
  bool _isLoading = true;
  int _heroCount = 0;
  int _villainCount = 0;
  int _totalStrength = 0;
  int _totalPower = 0;

  /// Called whenever dependencies change, including when returning to this tab.
  /// 
  /// Why use this instead of initState:
  /// - This screen is inside a ShellRoute (bottom nav bar)
  /// - initState only runs once when widget is first created
  /// - didChangeDependencies runs every time tab becomes active
  /// - This ensures stats are fresh when user switches between tabs
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  /// Fetches all agents from Firestore and calculates statistics.
  /// 
  /// Counts:
  /// - Heroes: alignment == 'good'
  /// - Villains: alignment == 'bad'
  /// - Total Strength: sum of all powerstats.strength
  /// - Total Power: sum of all powerstats.power
  /// 
  /// TODO: Add neutral agent tracking (currently excluded from counts).
  Future<void> _loadStats() async {
    try {
      final agents = await _agentdatarepo.getAllAgentsFromFirestore();
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
    //FirebaseService.logEvent("home_screen");
    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title
            const SectionHeader(
              icon: Icons.home,
              title: "HUB",
              titleFontSize: 22,
              padding: EdgeInsets.only(bottom: 20),
            ),

            // Top row: hero and villain count cards
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

            // Fighting power card (combined strength + power)
            _FightingPowerCard(
              isLoading: _isLoading,
              totalStrength: _totalStrength,
              totalPower: _totalPower,
            ),

            // War narrative section
            const SectionHeader(title: "THE INVASION"),

            // Situation report card
            InfoCard(
              icon: Icons.public,
              title: "SITUATION REPORT",
              body: "The invasion continues to spread across the globe. "
                  "Communications are being restored sector by sector. "
                  "The resistance holds firm, but the enemy adapts quickly. "
                  "Every agent we deploy tips the balance further in our favor.",
            ),

            // Recent developments card
            InfoCard(
              icon: Icons.timeline,
              title: "RECENT DEVELOPMENTS",
              body: "Infrastructure in major cities is coming back online. "
                  "Agent recruitment efforts have intensified. "
                  "Intelligence reports suggest the enemy's central command "
                  "may be vulnerable if we can assemble enough firepower. "
                  "Every hero and villain in your roster brings us closer to victory.",
            ),

            // User contribution card (dynamic based on roster)
            InfoCard(
              icon: Icons.trending_up,
              title: "YOUR CONTRIBUTION",
              body: _isLoading
                  ? "Loading your roster data..."
                  : _heroCount + _villainCount == 0
                      ? "Your roster is empty. Head to SEARCH and start recruiting agents to help fight the invasion."
                      : "Your roster contributes ${_heroCount + _villainCount} agent${(_heroCount + _villainCount) > 1 ? 's' : ''} "
                          "with a combined fighting power of ${_totalStrength + _totalPower}. "
                          "Keep recruiting in SEARCH to strengthen the resistance.",
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// PRIVATE WIDGETS (Only used in HomeScreen)
// ===========================================================================

/// Card displaying a single statistic (hero or villain count).
/// 
/// Layout:
/// - Icon in colored circle on left
/// - Label and value on right
/// - Border color matches accent color
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
        color: Theme.of(context).colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withAlpha(24)),
      ),
      child: Row(
        children: [
          // Icon container
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

          // Label and value
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

/// Card showing combined fighting power (strength + power).
/// 
/// Features:
/// - Large total number at top
/// - Visual breakdown bar showing strength vs power ratio
/// - Sub-stats with color-coded labels below bar
/// 
/// Why separate strength and power:
/// - Gives users insight into roster composition
/// - Strength (physical combat) vs Power (special abilities)
/// - Visual bar shows which stat dominates their roster
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
        color: Theme.of(context).colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with "COMBINED" badge
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
                  color: Theme.of(context).colorScheme.primary.withAlpha(40),
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

          // Total fighting power (strength + power combined)
          Text(
            isLoading ? "—" : (totalStrength + totalPower).toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),

          // Visual breakdown bar showing ratio of strength to power
          // Uses flex values to proportionally size each segment
          Row(
            children: [
              // Strength portion (left side)
              Expanded(
                flex: isLoading ? 1 : (totalStrength + 1), // +1 prevents zero flex
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
              // Power portion (right side)
              Expanded(
                flex: isLoading ? 1 : (totalPower + 1), // +1 prevents zero flex
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

          // Labels showing individual strength and power values
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

/// Small label + value pair used in fighting power breakdown.
/// 
/// Shows:
/// - Color square matching the bar segment
/// - Label (STRENGTH or POWER)
/// - Numeric value
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
        // Color indicator (matches bar segment)
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),

        // Label
        Text(label, style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 0.9, fontWeight: .bold)),
        const SizedBox(width: 8),

        // Value
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