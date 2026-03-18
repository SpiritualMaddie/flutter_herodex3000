import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';

///
/// Agent search screen with debounced API calls and shimmer loading.
/// 
/// Features:
/// - 1200ms debounced search (prevents excessive API calls)
/// - Three UI states: Initial (radar), Loading (shimmer), Results (grid)
/// - Grid layout for search results
/// - Navigates to detail screen with save button enabled
/// 
/// Why debounce:
/// - User types "spider" → only searches once after 1200ms pause
/// - Without debounce: Would search 6 times (s, sp, spi, spid, spide, spider)
/// - Saves API quota and improves performance
/// 

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

  // Full agent models from API
  List<AgentModel> _fullAgents = []; 

  // Current search query (for UI state)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Update search query state whenever controller changes
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  /// Handles search input with 1200ms debounce.
  /// 
  /// Flow:
  /// 1. Cancel any pending search timer
  /// 2. If query is empty, clear results immediately
  /// 3. Otherwise, start new timer for 1200ms
  /// 4. When timer fires, perform actual API search
  /// 
  /// Why 1200ms: Balance between responsiveness and API efficiency.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _fullAgents = [];
        _isLoading = false;
      });
      return;
    }
    
    // Show loading state immediately
    setState(() => _isLoading = true);
    
    _debounce = Timer(const Duration(milliseconds: 1200), () {
      _performSearch(query.trim());
    });
  }

  /// Performs actual API search via AgentDataManager.
  /// 
  /// Handles:
  /// - API call via SuperHero API (with CORS proxy on web)
  /// - Empty results (valid API response with no agents)
  /// - Network/parsing errors
  /// - Widget disposal during async operation
  Future<void> _performSearch(String query) async {
    try {
      final agents = await _dataManager.getAgentByNameApi(query);

      if (!mounted) return; // Widget disposed, don't update state

      setState(() {
        _fullAgents = agents;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ SearchScreen._performSearch: $e\n$st');
      if (!mounted) return;
      setState(() {
        _fullAgents = [];
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
    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with search bar
          ScreenHeader(
            title: "AGENT SEARCH",
            titleIcon: Icons.radar,
            searchController: _searchController,
            searchHint: "Search for agents...",
            currentQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
          ),

          // Dynamic content area (changes based on state)
          Expanded(
            child: _isLoading
                ? _buildLoadingState() // Shimmer skeleton
                : _fullAgents.isEmpty
                    ? _buildInitialState() // Radar icon
                    : _buildResultsState(), // Grid of agents
          ),
        ],
      ),
    );
  }

  /// Initial state: Shown before any search is performed.
  /// 
  /// Visual: Large radar icon with "AWAITING INPUT" text.
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radar,
            size: 150,
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
          ),
          const SizedBox(height: 16),
          Text(
            "AWAITING INPUT",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2,
              fontSize: 17,
            ),
          ),
          Text(
            "READY TO SEARCH",
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

  /// Loading state: Shimmer skeleton grid while searching.
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
        baseColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        highlightColor: Theme.of(context).colorScheme.primary.withAlpha(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Results state: Grid of agent cards from search results.
  Widget _buildResultsState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _fullAgents.length,
      itemBuilder: (context, index) {
        final summary = AgentSummaryMapper.toSummary(_fullAgents[index]);
        return AgentCard(
          agent: summary,
          layout: AgentCardLayout.grid,
          onTap: () {
            // Navigate to detail view (with save button)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgentDetailsScreen(
                  agent: _fullAgents[index],
                  showSaveButton: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}