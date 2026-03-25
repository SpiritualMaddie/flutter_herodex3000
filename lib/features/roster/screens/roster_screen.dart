import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/services/shared_preferences_service.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';

import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';

/// Enum defining which agent alignments are visible in the filter.
enum AgentAlignment { good, bad, neutral }

/// Enum defining how the roster list is sorted by power stat.
enum PowerSort { none, highest, lowest }

/// Roster management screen showing saved agents with filtering and search.
/// 
/// Features:
/// - Multi-select alignment filter (Hero/Villain/Neutral)
/// - Power sorting (Highest/Lowest/Default)
/// - Local search within saved agents
/// - Swipe-to-delete with optimistic UI updates
/// - Pull-to-refresh to reload from Firestore
/// - First-time swipe hint tooltip (auto-dismisses or user taps) TODO: Tooltip button?
/// 
/// Data Flow:
/// 1. Loads all agents from Firestore on mount
/// 2. Applies filters/search/sort locally for performance
/// 3. Swipe-to-delete updates UI immediately, rollback on Firestore failure
/// 
/// TODO: Add neutral agent support with purple accent colors
/// 
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

  // Start with all alignments selected (show everything)
  Set<AgentAlignment> _selectedAlignments = {
    AgentAlignment.good,
    AgentAlignment.bad,
    AgentAlignment.neutral,
  };

  // Current power sort mode (none - show everything)
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

    // Listen to search controller changes and update query
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });

    _checkFirstVisit();
  }

  /// Checks if user has seen the swipe-to-delete hint before.
  /// 
  /// Accessibility improvement: Shows hint on first roster visit when agents exist.
  /// 
  /// Flow:
  /// 1. Check SharedPreferences for 'roster_swipe_hint_seen' flag
  /// 2. Wait 3 seconds for agents to load and user to orient themselves
  /// 3. Show hint if: not seen before AND roster has agents AND widget mounted
  /// 4. Auto-dismiss after 25 seconds
  /// 
  /// Why 3-second delay: Gives user time to see their roster before showing hint
  /// Why 25-second timeout: Long enough to read, short enough not to be annoying
  Future<void> _checkFirstVisit() async {
    final hasSeenHint = _settingsManager.rosterSwipeHintSeen;
    debugPrint(
      "🔵 _checkFirstVisit() - _settingsManager.rosterSwipeHintSeen = ${_settingsManager.rosterSwipeHintSeen}",
    );

    // Wait for agents to load and user to take in the info on screen
    await Future.delayed(const Duration(seconds: 3));
    debugPrint("🔵 _allAgents.length: ${_allAgents.length}");

    if (!hasSeenHint && _allAgents.isNotEmpty && mounted) {
      setState(() => _showSwipeHint = true);

      // Auto-hide after 25 seconds
      Future.delayed(const Duration(seconds: 25), () {
        if (mounted) {
          _dismissSwipeHint();
          debugPrint("🔵 Autohides and calls _dismissSwipeHint");
        }
      });
    }
  }

  /// Dismisses the swipe hint and saves the flag to SharedPreferences.
  /// 
  /// Called when:
  /// - User taps the close button
  /// - User taps anywhere on the hint overlay
  /// - Hint auto-dismisses after timeout
  /// - User performs first swipe-to-delete
  void _dismissSwipeHint() {
    setState(() => _showSwipeHint = false);
    _settingsManager.saveRosterSwipeHintSeen(value: true);
    debugPrint(
      "🔵 _dismissSwipeHint() - _settingsManager.rosterSwipeHintSeen = ${_settingsManager.rosterSwipeHintSeen}",
    );
  }

  /// Derives filtered and sorted agent list from _allAgents.
  /// 
  /// Processing order:
  /// 1. Search filter (by name)
  /// 2. Alignment filter (hero/villain/neutral)
  /// 3. Power sort (highest/lowest/none)
  /// 
  /// Why this order:
  /// - Search first (most restrictive)
  /// - Then alignment (reduces set further)
  /// - Finally sort (only on visible items)
  /// 
  /// Note: Filtering is local/instant - no Firestore calls.
  List<AgentModel> get _filteredAgents {
    var list = _allAgents.toList();

    // 1. Search filter (case-insensitive name match)
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((a) => a.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // 2. Alignment filter
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
        break; // Keep original order
    }

    return list;
  }

  /// Loads all saved agents from Firestore.
  /// 
  /// Called:
  /// - On screen mount (initState)
  /// - On pull-to-refresh gesture
  /// - When returning to this tab (via didChangeDependencies in some setups)
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

  /// Removes an agent from Firestore with optimistic UI update.
  /// 
  /// Flow:
  /// 1. Dismiss swipe hint if showing (user has learned the gesture)
  /// 2. Remove from UI immediately (optimistic)
  /// 3. Delete from Firestore
  /// 4. If Firestore fails, roll back by re-adding to local list
  /// 
  /// Why optimistic updates:
  /// - Feels instant and responsive
  /// - Network failures are rare
  /// - Rollback handles errors gracefully
  Future<void> _removeAgent(AgentModel agent) async {
    // User has performed a swipe, they know how it works
    if (_showSwipeHint) {
      _dismissSwipeHint();
      debugPrint("🔴 _dismissSwipeHint() called in _removeAgents()");
    }

    // Optimistic UI update (remove immediately)
    setState(() {
      _allAgents.removeWhere((a) => a.agentId == agent.agentId);
    });

    try {
      await _agentDataRepo.deleteAgentFromFirestore(agent.agentId);
    } catch (e, st) {
      debugPrint('❌ RosterScreen._removeAgent: $e\n$st');
      
      // Rollback: put agent back in list
      if (!mounted) return;
      setState(() {
        _allAgents.add(agent);
      });

      // Show error to user
      if (mounted) {
        AppSnackbar.error(context, "❌ Failed to remove agent. Try again.");
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
            // Main content
            Column(
              children: [
                // Header with search and filters
                ScreenHeader(
                  title: "AGENTS ROSTER",
                  titleIcon: Icons.shield,
                  searchController: _searchController,
                  searchHint: "Search roster...",
                  currentQuery: _searchQuery,
                  onSearchChanged: (query) {
                    // Search handled by listener in initState
                    // This callback just triggers rebuild
                  },
                  additionalContent: _buildFilters(),
                ),
                
                // Agent list or loading/empty states
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
        
            // Swipe hint overlay (positioned above content when visible)
            if (_showSwipeHint) _buildSwipeHintOverlay(),
          ],
        ),
      ),
    );
  }

  /// Builds the swipe-to-delete hint overlay.
  /// 
  /// Accessibility feature:
  /// - Large touch target (entire overlay is tappable)
  /// - High contrast colors (primary color background)
  /// - Clear icon and text instructions
  /// - Close button for explicit dismissal
  /// 
  /// Positioned at bottom (above nav bar) so it doesn't cover roster.
  Widget _buildSwipeHintOverlay() {
    return Positioned(
      bottom: 80, // Above bottom nav bar
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: _dismissSwipeHint, // Tap anywhere to dismiss
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
                // Swipe icon
                Icon(Icons.swipe_left, color: Theme.of(context).colorScheme.onPrimary, size: 32),
                const SizedBox(width: 16),

                // Text instructions
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

                // Close button
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

  /// Builds alignment and power sort filters.
  /// 
  /// Alignment: Multi-select (can show heroes + villains together)
  /// Power: Single-select (only one sort direction at a time)
  /// 
  /// Why SegmentedButton:
  /// - Material 3 component (modern, consistent)
  /// - Built-in multi/single-select support
  /// - Clear visual feedback for selected states
  Widget _buildFilters() {
    return Column(
      children: [
        // Alignment filter (multi-select)
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
            // Prevent deselecting all (would show nothing)
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

        // Power sort (single-select)
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
          selected: {_powerSort}, // Set with single value for single-select
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

  /// Empty state shown when no agents match filters or roster is empty.
  /// 
  /// Shows different messages depending on context:
  /// - Empty roster: "Go to Search to find allies"
  /// - Filtered out: "Try adjusting filters"
  Widget _buildEmptyState() {
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

  /// Builds scrollable list of agent cards with swipe-to-delete.
  /// 
  /// Features:
  /// - RefreshIndicator: Pull down to reload from Firestore
  /// - ListView.builder: Efficient rendering for large rosters
  /// - AgentCard with list layout: Horizontal cards
  /// - Dismissible gesture: Swipe left to delete
  /// - Success feedback: Green SnackBar on deletion
  Widget _buildRosterList() {
    final agents = _filteredAgents;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: _loadAgents,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when list is short
        padding: const EdgeInsets.all(16),
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agentSummary = AgentSummaryMapper.toSummary(agents[index]);
          return AgentCard(
            agent: agentSummary,
            layout: AgentCardLayout.list,
            onTap: () async {
              // Navigate to details (without save button since already in roster)
              final wasDeleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AgentDetailsScreen(
                    agent: agents[index],
                    showSaveButton: false, // Hide save button
                  ),
                ),
              );

              if(wasDeleted == true && mounted){
                _loadAgents();
              }
            },
            onDismiss: () {
              // Handle swipe-to-delete
              _removeAgent(agents[index]);
              AppSnackbar.success(context, "${agents[index].name} removed from roster ✅");
            },
          );
        },
      ),
    );
  }
}
