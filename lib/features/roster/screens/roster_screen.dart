import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/managers/agent_data_manager.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_details_screen.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';
import 'package:flutter_herodex3000/presentation/widgets/responsive_scaffold.dart';

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

  bool _isLoading = true;

  // All agents fetched from Firestore — never mutated by filters.
  List<AgentModel> _allAgents = [];

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
    _loadAgents();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  /// Derives the visible list by applying search, alignment filter, then sort.
  /// This runs on every build — it's cheap since roster lists are small.
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
      await _agentDataRepo.deleteAgentFromFirestore(agent.agentId);
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
      child: Column(
        children: [
          // --- TOP SECTION: title + search + filters ---
          _buildTopBar(),
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
    );
  }

  // --- TOP BAR ---
  Widget _buildTopBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "AGENTS ROSTER",
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  ),
                ),
                hintText: "Search roster...",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
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
              // Don't allow deselecting everything
              if (newSelection.isEmpty) return;
              setState(() => _selectedAlignments = newSelection);
            },
            multiSelectionEnabled: true,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary.withAlpha(30);
                }
                return Theme.of(context).colorScheme.surface;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
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
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary.withAlpha(30);
                }
                return Theme.of(context).colorScheme.surface;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
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
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
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
                  backgroundColor: Colors.green.withAlpha(80),
                ),
              );
            },
          );
        },
      ),
    );
  }
}