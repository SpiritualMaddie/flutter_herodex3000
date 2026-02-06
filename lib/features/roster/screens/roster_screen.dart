import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/services/shared_preferences_service.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';

import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';

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
  final AgentDataManager _agentDataRepo = AgentDataManager();
  final TextEditingController _searchController = TextEditingController();
  late final SharedPreferencesService _sharedPrefsService;
  late final SettingsManager _settingsManager;

  bool _isLoading = true;
  List<AgentModel> _allAgents = [];
  bool _showSwipeHint = false;

  // Which alignment checkboxes are active. Start with all selected.
  Set<AgentAlignment> _selectedAlignments = {
    AgentAlignment.good,
    AgentAlignment.bad,
    AgentAlignment.neutral,
  };

  // Current power sort mode.
  PowerSort _powerSort = PowerSort.none;

  // The current search query (lowercased).
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sharedPrefsService = SharedPreferencesService();
    _settingsManager = SettingsManager(_sharedPrefsService);
    _loadAgents();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
    _checkFirstVisit();
  }

  // Check if this is user's first time seeing the roster with items
  Future<void> _checkFirstVisit() async {
    final hasSeenHint = _settingsManager.rosterSwipeHintSeen;
    debugPrint(
      "🔵 _checkFirstVisit() - _settingsManager.rosterSwipeHintSeen = ${_settingsManager.rosterSwipeHintSeen}",
    );

    // Wait a bit for agents to load and let the user take in whats happening
    await Future.delayed(const Duration(seconds: 3));
    debugPrint("🔵 _allAgents.length: ${_allAgents.length}");

    if (!hasSeenHint && _allAgents.isNotEmpty && mounted) {
      setState(() => _showSwipeHint = true);

      // Auto-hide after x seconds
      Future.delayed(const Duration(seconds: 25), () {
        if (mounted) {
          _dismissSwipeHint();
          debugPrint("🔵 Autohides and calls _dismissSwipeHint");
        }
      });
    }
  }

  void _dismissSwipeHint() {
    setState(() => _showSwipeHint = false);
    _settingsManager.saveRosterSwipeHintSeen(value: true);
    debugPrint(
      "🔵 _dismissSwipeHint() - _settingsManager.rosterSwipeHintSeen = ${_settingsManager.rosterSwipeHintSeen}",
    );
  }

  // Derives the visible list by applying search, alignment filter, then sort.
  List<AgentModel> get _filteredAgents {
    var list = _allAgents.toList();

    // 1. Search filter
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // 2. AgentAlignment filter
    list = list.where((a) {
      final alignment = a.biography.alignment.trim().toLowerCase();
      if (alignment == 'good') {
        return _selectedAlignments.contains(AgentAlignment.good);
      }
      if (alignment == 'bad') {
        return _selectedAlignments.contains(AgentAlignment.bad);
      }
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
      final agents = await _agentDataRepo.getAllAgentsFromFirestore();
      if (!mounted) return;
      setState(() {
        _allAgents = agents;
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
    // Dismiss hint if still showing
    if (_showSwipeHint) {
      _dismissSwipeHint();
      debugPrint("🔴 _dismissSwipeHint() called in _removeAgents()");
    }
    // Remove from UI immediately
    setState(() {
      _allAgents.removeWhere((a) => a.agentId == agent.agentId);
    });

    try {
      await _agentDataRepo.deleteAgentFromFirestore(agent.agentId);
    } catch (e, st) {
      debugPrint('❌ RosterScreen._removeAgent: $e\n$st');
      // If Firestore fails, put it back
      if (!mounted) return;
      setState(() {
        _allAgents.add(agent);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                "❌ Failed to remove agent. Try again.",
                style: TextStyle(fontWeight: .bold, letterSpacing: 1.5),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- HEADER with filters ---
                ScreenHeader(
                  title: "AGENTS ROSTER",
                  titleIcon: Icons.shield,
                  searchController: _searchController,
                  searchHint: "Search roster...",
                  currentQuery: _searchQuery,
                  onSearchChanged: (query) {
                    // Search is handled by the listener in initState
                    // This callback is just for triggering the rebuild
                  },
                  additionalContent: _buildFilters(),
                ),
                // --- AGENT LIST or states ---
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : _filteredAgents.isEmpty
                      ? _buildEmptyState()
                      : _buildRosterList(),
                ),
              ],
            ),
        
            // Swipe hint overlay
            if (_showSwipeHint) _buildSwipeHintOverlay(),
          ],
        ),
      ),
    );
  }

  // --- SWIPE HINT OVERLAY ---
  Widget _buildSwipeHintOverlay() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: _dismissSwipeHint,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.swipe_left, color: Theme.of(context).colorScheme.onPrimary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SWIPE LEFT TO REMOVE",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Swipe any agent card left to delete from roster",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withAlpha(200),
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: .bold
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                  onPressed: _dismissSwipeHint,
                  tooltip: 'Dismiss hint',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FILTERS (passed as additionalContent to ScreenHeader) ---
  Widget _buildFilters() {
    return Column(
      children: [
        // Alignment filter
        SegmentedButton<AgentAlignment>(
          segments: const [
            ButtonSegment(
              value: AgentAlignment.good,
              label: Text(
                "HERO",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
              icon: Icon(Icons.shield, size: 14, color: Colors.cyan),
            ),
            ButtonSegment(
              value: AgentAlignment.bad,
              label: Text(
                "VILLAIN",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
              icon: Icon(Icons.warning_amber, size: 14, color: Colors.red),
            ),
            ButtonSegment(
              value: AgentAlignment.neutral,
              label: Text(
                "NEUTRAL",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
              icon: Icon(Icons.remove_circle_outline, size: 14),
            ),
          ],
          selected: _selectedAlignments,
          onSelectionChanged: (newSelection) {
            if (newSelection.isEmpty) return;
            setState(() => _selectedAlignments = newSelection);
          },
          multiSelectionEnabled: true,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary.withAlpha(30);
              }
              return Theme.of(context).colorScheme.surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Theme.of(context).colorScheme.onSurfaceVariant;
            }),
            side: WidgetStateProperty.all(
              BorderSide(
                color: Theme.of(context).colorScheme.primary.withAlpha(40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Power sort
        SegmentedButton<PowerSort>(
          segments: const [
            ButtonSegment(
              value: PowerSort.none,
              label: Text(
                "DEFAULT",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
            ),
            ButtonSegment(
              value: PowerSort.highest,
              label: Text(
                "HIGHEST",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
              icon: Icon(Icons.arrow_upward, size: 14),
            ),
            ButtonSegment(
              value: PowerSort.lowest,
              label: Text(
                "LOWEST",
                style: TextStyle(fontSize: 11, letterSpacing: 1),
              ),
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
                return Theme.of(context).colorScheme.primary.withAlpha(30);
              }
              return Theme.of(context).colorScheme.surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Theme.of(context).colorScheme.onSurfaceVariant;
            }),
            side: WidgetStateProperty.all(
              BorderSide(
                color: Theme.of(context).colorScheme.primary.withAlpha(40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    // Different message depending on whether it's empty roster or empty filter result
    final hasAgentsButFiltered =
        _allAgents.isNotEmpty && _filteredAgents.isEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset("assets/icons/app_icon.png", width: 120),
          ),
          const SizedBox(height: 16),
          Text(
            hasAgentsButFiltered ? "NO MATCHING AGENTS" : "NO AGENTS IN ROSTER",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2,
              fontSize: 17,
            ),
          ),
          Text(
            hasAgentsButFiltered
                ? "TRY ADJUSTING YOUR FILTERS"
                : "GO TO SEARCH TO FIND NEW ALLIES",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- ROSTER LIST ---
  Widget _buildRosterList() {
    final agents = _filteredAgents;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: _loadAgents,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agentSummary = AgentSummaryMapper.toSummary(agents[index]);
          return AgentCard(
            agent: agentSummary,
            layout: AgentCardLayout.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgentDetailsScreen(
                    agent: agents[index],
                    showSaveButton: false,
                  ),
                ),
              );
            },
            onDismiss: () {
              _removeAgent(agents[index]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      "${agents[index].name} removed from roster ✅",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: .bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.green.withAlpha(90),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
