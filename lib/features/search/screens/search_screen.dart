import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/data/managers/agent_data_manager.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/presentation/widgets/responsive_scaffold.dart';
import 'package:flutter_herodex3000/presentation/widgets/screen_header.dart';
import 'package:flutter_herodex3000/presentation/screens/agent_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';

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

  // List of full models
  List<AgentModel> _fullAgents = [];

  // Current search query (for UI state)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _fullAgents = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() => _isLoading = true);
    
    _debounce = Timer(const Duration(milliseconds: 1200), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final agents = await _dataManager.getAgentByNameApi(query);

      if (!mounted) return;

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
          // --- HEADER ---
          ScreenHeader(
            title: "AGENT SEARCH",
            titleIcon: Icons.radar,
            searchController: _searchController,
            searchHint: "Search for agents...",
            currentQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
          ),

          // --- CONTENT AREA ---
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _fullAgents.isEmpty
                    ? _buildInitialState()
                    : _buildResultsState(),
          ),
        ],
      ),
    );
  }

  // VIEW 1: INITIAL STATE (before any search)
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

  // VIEW 2: LOADING STATE (shimmer effect)
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

  // VIEW 3: RESULTS STATE — grid of agent cards
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